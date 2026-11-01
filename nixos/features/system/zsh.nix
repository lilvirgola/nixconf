{
  flake.nixosModules.zsh = {
    pkgs,
    lib,
    ...
  }: let
    agnosterzak = pkgs.stdenv.mkDerivation {
      pname = "agnosterzak-zsh-theme";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "zakaziko99";
        repo = "agnosterzak-ohmyzsh-theme";
        rev = "master";
        hash = "sha256-N3xEJUztZwEt8ERV0Zn1G909Ncg/bIzeYYWOK67ks4o=";
      };
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/share/zsh/themes
        cp agnosterzak.zsh-theme $out/share/zsh/themes/
      '';
    };

    fastfetchConfig = ../../../assets/fastfetch/config-compact-no-source.jsonc;
    asciiCatsDir = ../../../assets/ascii-cats;
  in {
    # Set default user shell to Zsh
    users.defaultUserShell = pkgs.zsh;
    users.users."virgola".shell = pkgs.zsh;

    # Packages required by aliases, prompt and Bitwarden integration
    environment.systemPackages = with pkgs; [
      lsd
      lolcat
    ];

    # Powerline / Nerd fonts required for agnosterzak glyphs
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];

    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "HIST_IGNORE_DUPS"
        "SHARE_HISTORY"
        "HIST_FCNTL_LOCK"
        "APPEND_HISTORY"
      ];

      shellAliases = {
        ls = "lsd";
        l = "ls -l";
        la = "ls -a";
        lla = "ls -la";
        lt = "ls --tree";
        py = "python";
        pip = "pip3";
        ghidra-auto = "ghidra-auto";
        pwninit = "pwninit-ghidra";
        s = "kitten ssh";
      };

      ohMyZsh = {
        enable = true;
        theme = "agnosterzak";
        plugins = [
          "git"
          "buf"
          "ansible"
          "docker"
          "docker-compose"
          "gh"
        ];
        customPkgs = [
          agnosterzak
        ];
      };

      interactiveShellInit = ''
        # Clean standard PATH exports (NixOS-native)
        export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

        # Helper to load SSH keys from Bitwarden/Vaultwarden into ssh-agent in memory
        ssh-vault-load() {
          local key_name="''${1:-id_ed25519}"
          if ! command -v rbw >/dev/null 2>&1 && ! command -v bw >/dev/null 2>&1; then
            echo "[!] Neither rbw nor bw CLI is installed."
            return 1
          fi

          local key_data=""

          # Try rbw first (supports background agent daemon + pinentry)
          if command -v rbw >/dev/null 2>&1; then
            if ! rbw unlocked >/dev/null 2>&1; then
              echo "[*] Unlocking Bitwarden vault..."
              rbw unlock || return 1
            fi
            # 1. Custom field 'private-key'
            key_data=$(rbw get --field private-key "$key_name" 2>/dev/null || true)
            # 2. Custom field 'ssh-key'
            if [[ -z "$key_data" ]]; then
              key_data=$(rbw get --field ssh-key "$key_name" 2>/dev/null || true)
            fi
            # 3. Item notes
            if [[ -z "$key_data" ]]; then
              key_data=$(rbw notes "$key_name" 2>/dev/null || true)
            fi
          fi

          # Fallback to official bw CLI if needed
          if [[ -z "$key_data" ]] && command -v bw >/dev/null 2>&1; then
            key_data=$(bw get item "$key_name" 2>/dev/null | jq -r '.sshKey.privateKey // .fields[]? | select(.name=="private-key" or .name=="ssh-key").value // .notes' 2>/dev/null || true)
          fi

          if [[ -z "$key_data" ]]; then
            echo "[!] Could not find private key for '$key_name' in Bitwarden vault."
            echo "    Make sure the key is in field 'private-key', 'ssh-key', Notes, or an official SSH Key item."
            return 1
          fi

          echo "$key_data" | ssh-add -
          echo "[+] SSH key '$key_name' loaded into ssh-agent successfully!"
        }

        # Fastfetch with random ascii-cat logo piped to lolcat
        FASTFETCH_CONFIG="${fastfetchConfig}"
        CAT_DIR="$HOME/ascii-cats"
        if [ ! -d "$CAT_DIR" ] || ! ls "$CAT_DIR"/*.txt >/dev/null 2>&1; then
          CAT_DIR="${asciiCatsDir}"
        fi

        if ls "$CAT_DIR"/*.txt >/dev/null 2>&1; then
          RANDOM_CAT=$(ls "$CAT_DIR"/*.txt 2>/dev/null | shuf -n 1)
          LOGO_ARG=(--logo "$RANDOM_CAT" --logo-padding 7)
        else
          LOGO_ARG=()
        fi

        if command -v lolcat >/dev/null 2>&1; then
          fastfetch -c "$FASTFETCH_CONFIG" "''${LOGO_ARG[@]}" 2>/dev/null | lolcat
        else
          fastfetch -c "$FASTFETCH_CONFIG" "''${LOGO_ARG[@]}" 2>/dev/null
        fi

        # FZF keybindings (Ctrl+R history, Alt+C directory search)
        if command -v fzf >/dev/null 2>&1; then
          source <(fzf --zsh)
        fi

        # Non-blocking background open function with xdg-open
        unalias open 2>/dev/null
        open() {
          for f in "$@"; do
            xdg-open "$f" >/dev/null 2>&1 &
          done
        }
      '';
    };
  };
}
