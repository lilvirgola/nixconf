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
        antigravity = "antigravity-ide";
        agy = "agy";
        ninit = "ninit";
        nix-template = "ninit";
        keyhints = "keyhints";
        keys = "keyhints";
        openfortivpn = "sudo openfortivpn";
        ssh-vault-save = "ssh-vault-add";
        ssh-vault-push = "ssh-vault-add";
        ssh-vault-ls = "ssh-vault-list";
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
                  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
                    echo "Usage: ssh-vault-load [KEY_NAME]"
                    echo
                    echo "Load an SSH private key from Bitwarden / Vaultwarden into ssh-agent."
                    echo
                    echo "Arguments:"
                    echo "  KEY_NAME    Name of the vault item (default: id_ed25519)"
                    echo
                    echo "Options:"
                    echo "  -l, --list  List all items in the vault"
                    echo "  -h, --help  Show this help message"
                    echo
                    echo "Examples:"
                    echo "  ssh-vault-load             # Loads 'id_ed25519'"
                    echo "  ssh-vault-load id_rsa      # Loads 'id_rsa'"
                    echo "  ssh-vault-load -l          # Lists all items in vault"
                    return 0
                  fi

                  if [[ "$1" == "-l" || "$1" == "--list" ]]; then
                    ssh-vault-list
                    return $?
                  fi

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
                  ssh-add -l
                }

                # Helper to add / save SSH keys into Bitwarden / Vaultwarden
                ssh-vault-add() {
                  local key_path=""
                  local key_name=""
                  local force=false
                  local gen_new=false
                  local del_local=false

                  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
                    echo "Usage: ssh-vault-add [OPTIONS] [KEY_PATH_OR_NAME] [KEY_NAME]"
                    echo
                    echo "Save an SSH private/public key pair into Bitwarden / Vaultwarden."
                    echo
                    echo "Arguments:"
                    echo "  KEY_PATH_OR_NAME   Path to private key file, or name in ~/.ssh/ (default: ~/.ssh/id_ed25519)"
                    echo "  KEY_NAME           Custom item name in Bitwarden (defaults to key filename)"
                    echo
                    echo "Options:"
                    echo "  -f, --force        Overwrite item in vault if it already exists"
                    echo "  -g, --generate     Generate a new Ed25519 key if the specified file does not exist"
                    echo "  -d, --delete-local Remove unencrypted private key from disk after successful upload"
                    echo "  -h, --help         Show this help message"
                    echo
                    echo "Examples:"
                    echo "  ssh-vault-add                           # Uploads ~/.ssh/id_ed25519 as 'id_ed25519'"
                    echo "  ssh-vault-add ~/.ssh/id_rsa             # Uploads ~/.ssh/id_rsa as 'id_rsa'"
                    echo "  ssh-vault-add ~/.ssh/id_work work_key   # Uploads ~/.ssh/id_work as 'work_key'"
                    echo "  ssh-vault-add -g my_new_key             # Generates ~/.ssh/my_new_key and saves to vault"
                    return 0
                  fi

                  while [[ $# -gt 0 ]]; do
                    case "$1" in
                      -f|--force)
                        force=true
                        shift
                        ;;
                      -g|--generate)
                        gen_new=true
                        shift
                        ;;
                      -d|--delete-local)
                        del_local=true
                        shift
                        ;;
                      -*)
                        echo "[!] Unknown option: $1"
                        return 1
                        ;;
                      *)
                        if [[ -z "$key_path" ]]; then
                          key_path="$1"
                        elif [[ -z "$key_name" ]]; then
                          key_name="$1"
                        fi
                        shift
                        ;;
                    esac
                  done

                  if [[ -z "$key_path" ]]; then
                    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
                      key_path="$HOME/.ssh/id_ed25519"
                      key_name="id_ed25519"
                    elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
                      key_path="$HOME/.ssh/id_rsa"
                      key_name="id_rsa"
                    else
                      key_path="$HOME/.ssh/id_ed25519"
                      key_name="id_ed25519"
                    fi
                  else
                    key_path="''${key_path/#\~/$HOME}"
                    if [[ ! -f "$key_path" && -f "$HOME/.ssh/$key_path" ]]; then
                      if [[ -z "$key_name" ]]; then
                        key_name="$key_path"
                      fi
                      key_path="$HOME/.ssh/$key_path"
                    fi
                    if [[ -z "$key_name" ]]; then
                      key_name="$(basename "$key_path")"
                    fi
                  fi

                  if [[ ! -f "$key_path" ]]; then
                    if [[ "$gen_new" == true ]]; then
                      echo "[*] Generating new Ed25519 key at '$key_path'..."
                      mkdir -p "$(dirname "$key_path")"
                      ssh-keygen -t ed25519 -f "$key_path" -C "$key_name" || return 1
                    else
                      echo -n "[?] Key '$key_path' not found. Generate a new Ed25519 key? [y/N]: "
                      read -r answer
                      if [[ "$answer" =~ ^[Yy]$ ]]; then
                        mkdir -p "$(dirname "$key_path")"
                        ssh-keygen -t ed25519 -f "$key_path" -C "$key_name" || return 1
                      else
                        echo "[!] Aborted: key file not found."
                        return 1
                      fi
                    fi
                  fi

                  if ! grep -q "PRIVATE KEY" "$key_path" 2>/dev/null; then
                    echo "[!] Error: '$key_path' does not appear to be a valid private key."
                    return 1
                  fi

                  local priv_key
                  priv_key="$(cat "$key_path")"

                  local pub_key=""
                  if [[ -f "''${key_path}.pub" ]]; then
                    pub_key="$(cat "''${key_path}.pub")"
                  else
                    pub_key="$(ssh-keygen -y -f "$key_path" 2>/dev/null || true)"
                  fi

                  local saved=false

                  # Try official bw CLI first
                  if command -v bw >/dev/null 2>&1; then
                    local bw_status
                    bw_status="$(bw status 2>/dev/null | jq -r '.status // empty' 2>/dev/null || true)"

                    if [[ "$bw_status" == "unauthenticated" ]]; then
                      echo "[*] Bitwarden CLI is not logged in."
                      echo "    Tip: If using Vaultwarden, run: bw config server <YOUR_VAULT_URL>"
                      echo "    Logging in to Bitwarden..."
                      bw login || true
                      bw_status="$(bw status 2>/dev/null | jq -r '.status // empty' 2>/dev/null || true)"
                    fi

                    if [[ "$bw_status" == "locked" ]]; then
                      echo "[*] Vault is locked. Enter master password to unlock:"
                      local session
                      session="$(bw unlock --raw)" || true
                      if [[ -n "$session" ]]; then
                        export BW_SESSION="$session"
                        bw_status="unlocked"
                      fi
                    fi

                    if [[ "$bw_status" == "unlocked" ]]; then
                      echo "[*] Preparing item '$key_name' for Bitwarden vault..."
                      local existing_id
                      existing_id="$(bw list items --search "$key_name" 2>/dev/null | jq -r --arg n "$key_name" '.[] | select(.name==$n) | .id' 2>/dev/null | head -n1 || true)"

                      if [[ -n "$existing_id" && "$existing_id" != "null" && "$force" != true ]]; then
                        echo -n "[?] Item '$key_name' already exists in vault (ID: $existing_id). Overwrite? [y/N]: "
                        read -r ans
                        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
                          echo "[!] Aborted. (Use -f to overwrite without prompt)"
                          return 1
                        fi
                      fi

                      local item_json
                      item_json="$(jq -n \
                        --arg name "$key_name" \
                        --arg priv "$priv_key" \
                        --arg pub "$pub_key" \
                        '{
                          type: 2,
                          name: $name,
                          notes: $priv,
                          fields: [
                            { name: "private-key", value: $priv, type: 1 },
                            { name: "public-key", value: $pub, type: 0 }
                          ],
                          secureNote: { type: 0 }
                        }')"

                      if [[ -n "$existing_id" && "$existing_id" != "null" ]]; then
                        echo "[*] Updating existing item in vault..."
                        echo "$item_json" | jq --arg id "$existing_id" '.id = $id' | bw encode | bw edit item "$existing_id" >/dev/null && saved=true
                      else
                        echo "[*] Creating new item in vault..."
                        echo "$item_json" | bw encode | bw create item >/dev/null && saved=true
                      fi

                      if [[ "$saved" == true ]]; then
                        bw sync >/dev/null 2>&1 || true
                      fi
                    fi
                  fi

                  # Fallback to rbw if bw was not available or not logged in
                  if [[ "$saved" != true ]] && command -v rbw >/dev/null 2>&1; then
                    if ! rbw unlocked >/dev/null 2>&1; then
                      echo "[*] Unlocking rbw vault..."
                      rbw unlock || true
                    fi

                    if rbw unlocked >/dev/null 2>&1; then
                      echo "[*] Saving key '$key_name' into rbw..."
                      local existing_rbw
                      existing_rbw="$(rbw list 2>/dev/null | grep -E "^''${key_name}$" || true)"
                      if [[ -n "$existing_rbw" && "$force" != true ]]; then
                        echo -n "[?] Item '$key_name' already exists in rbw. Overwrite? [y/N]: "
                        read -r ans
                        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
                          echo "[!] Aborted."
                          return 1
                        fi
                        rbw remove "$key_name" 2>/dev/null || true
                      fi

                      local tmp_editor
                      tmp_editor="$(mktemp)"
                      chmod +x "$tmp_editor"
                      cat << 'TMP_EOF' > "$tmp_editor"
        #!/usr/bin/env bash
        file="$1"
        printf "\n%s\n" "$SSH_VAULT_KEY_DATA" > "$file"
        TMP_EOF

                      SSH_VAULT_KEY_DATA="$priv_key" EDITOR="$tmp_editor" rbw add "$key_name" >/dev/null 2>&1
                      local ret=$?
                      rm -f "$tmp_editor"

                      if [[ $ret -eq 0 ]]; then
                        saved=true
                        rbw sync >/dev/null 2>&1 || true
                      fi
                    fi
                  fi

                  if [[ "$saved" == true ]]; then
                    if command -v rbw >/dev/null 2>&1 && rbw unlocked >/dev/null 2>&1; then
                      rbw sync >/dev/null 2>&1 || true
                    fi
                    echo "[+] SSH key '$key_name' successfully saved to Bitwarden / Vaultwarden!"
                    if [[ -n "$pub_key" ]]; then
                      echo "    Public key: $pub_key"
                    fi

                    if [[ "$del_local" == true ]]; then
                      rm -f "$key_path"
                      echo "[*] Local private key '$key_path' removed."
                    else
                      echo -n "[?] Remove unencrypted local private key from disk? [y/N]: "
                      read -r del_ans
                      if [[ "$del_ans" =~ ^[Yy]$ ]]; then
                        rm -f "$key_path"
                        echo "[*] Local private key '$key_path' removed."
                      else
                        echo "[*] Local private key kept at '$key_path'."
                      fi
                    fi
                    echo "[+] Load key into ssh-agent anytime with: ssh-vault-load $key_name"
                  else
                    echo "[!] Could not save key to Bitwarden. Please ensure 'bw' or 'rbw' is logged in."
                    return 1
                  fi
                }

                # Helper to list SSH keys / items in Bitwarden
                ssh-vault-list() {
                  if command -v rbw >/dev/null 2>&1 && rbw unlocked >/dev/null 2>&1; then
                    echo "[*] Items in Bitwarden vault (rbw):"
                    rbw list
                  elif command -v bw >/dev/null 2>&1; then
                    echo "[*] Items in Bitwarden vault (bw):"
                    bw list items 2>/dev/null | jq -r '.[].name' 2>/dev/null
                  else
                    echo "[!] Please unlock rbw ('rbw unlock') or bw ('bw unlock') first."
                  fi
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
