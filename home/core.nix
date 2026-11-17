{
  pkgs,
  osConfig,
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
      mkdir -p $out/share/oh-my-zsh/custom/themes
      cp agnosterzak.zsh-theme $out/share/oh-my-zsh/custom/themes/
    '';
  };

  fastfetchConfig = ../assets/fastfetch/config-compact-no-source.jsonc;
  asciiCatsDir = ../assets/ascii-cats;
in {
  home.username = osConfig.custom.username;
  home.homeDirectory = "/home/${osConfig.custom.username}";
  home.stateVersion = osConfig.system.stateVersion;

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings.init.defaultBranch = "main";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      share = true;
      append = true;
    };

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
      antigravity = "antigravity-ide";
      agy = "agy";
      ninit = "ninit";
      nix-template = "ninit";
      keyhints = "keyhints";
      keys = "keyhints";
      openfortivpn = "sudo openfortivpn";
      ollama-up = "sudo systemctl start ollama && echo '✓ Ollama CUDA daemon online (http://localhost:11434)'";
      ollama-down = "sudo systemctl stop ollama && echo '✓ Ollama daemon stopped (VRAM released)'";
      ollama-stat = "systemctl status ollama";
      ssh-vault-save = "ssh-vault-add";
      ssh-vault-push = "ssh-vault-add";
      ssh-vault-ls = "ssh-vault-list";
      bwu = "bw unlock";
      bwl = "bw lock";
      rbwu = "rbw unlock";
      rbwl = "rbw lock";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnosterzak";
      custom = "${agnosterzak}/share/oh-my-zsh/custom";
      plugins = [
        "git"
        "buf"
        "ansible"
        "docker"
        "docker-compose"
        "gh"
        "sudo"
        "extract"
        "colored-man-pages"
        "copypath"
        "copyfile"
        "systemd"
        "python"
        "rust"
        "golang"
        "zoxide"
      ];
    };

    initContent = ''
      export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
      export GPG_TTY=$(tty)

      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        local user_runtime="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        if [[ -S "$user_runtime/ssh-agent" ]]; then
          export SSH_AUTH_SOCK="$user_runtime/ssh-agent"
        fi
      fi

      # Bitwarden CLI (bw) wrapper: exports/unsets BW_SESSION in the current shell
      bw() {
        case "''${1:-}" in
          unlock)
            shift
            if [[ " $* " =~ " --check " || " $* " =~ " -h " || " $* " =~ " --help " ]]; then
              command bw unlock "$@"
              return $?
            fi
            local session
            session=$(command bw unlock --raw "$@")
            local exit_code=$?
            if [[ $exit_code -eq 0 && -n "$session" ]]; then
              export BW_SESSION="$session"
              if [[ " $* " =~ " --raw " ]]; then
                echo "$session"
              else
                echo "[✓] Vault unlocked and BW_SESSION exported into current shell." >&2
              fi
            else
              return $exit_code
            fi
            ;;
          login)
            shift
            if [[ " $* " =~ " --check " || " $* " =~ " -h " || " $* " =~ " --help " ]]; then
              command bw login "$@"
              return $?
            fi
            local session
            session=$(command bw login --raw "$@")
            local exit_code=$?
            if [[ $exit_code -eq 0 && -n "$session" ]]; then
              export BW_SESSION="$session"
              if [[ " $* " =~ " --raw " ]]; then
                echo "$session"
              else
                echo "[✓] Logged in and BW_SESSION exported into current shell." >&2
              fi
            else
              return $exit_code
            fi
            ;;
          lock)
            command bw lock "$@"
            local exit_code=$?
            unset BW_SESSION
            echo "[*] Vault locked and BW_SESSION cleared."
            return $exit_code
            ;;
          logout)
            command bw logout "$@"
            local exit_code=$?
            unset BW_SESSION
            echo "[*] Logged out and BW_SESSION cleared."
            return $exit_code
            ;;
          *)
            if [[ -t 0 && -z "''${BW_SESSION:-}" && -n "''${1:-}" && "$1" != "status" && "$1" != "config" && "$1" != "help" && "$1" != "--help" && "$1" != "-h" && "$1" != "--version" && "$1" != "-v" ]]; then
              local st
              st=$(command bw status 2>/dev/null | jq -r '.status // empty' 2>/dev/null || true)
              if [[ "$st" == "locked" ]]; then
                echo "[*] Bitwarden vault is locked. Unlocking..."
                local session
                session=$(command bw unlock --raw)
                if [[ -n "$session" ]]; then
                  export BW_SESSION="$session"
                  echo "[✓] Vault unlocked and BW_SESSION exported."
                else
                  return 1
                fi
              fi
            fi
            command bw "$@"
            ;;
        esac
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

      # FZF-Tab interactive fuzzy tab completion
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
      zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ''${(P)word}'
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview 'ps -fp $word'
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'
      zstyle ':fzf-tab:*' continuous-trigger '/'

      unalias open 2>/dev/null
      open() {
        for f in "$@"; do
          xdg-open "$f" >/dev/null 2>&1 &
        done
      }

      s() {
        kssh "$@"
      }
      compdef _ssh s=ssh
      compdef _ssh kssh=ssh

      kitten() {
        if [[ "$1" == "ssh" ]]; then
          shift
          s "$@"
        else
          builtin command kitten "$@"
        fi
      }

      _kitten() {
        local curcontext="$curcontext"
        if (( CURRENT == 2 )); then
          _values 'kitten subcommand' 'ssh[Connect to SSH host using kitten]'
        elif [[ "''${words[2]}" == "ssh" ]]; then
          local service=ssh
          words=("ssh" "''${(@)words[3,-1]}")
          CURRENT=$(( CURRENT - 1 ))
          _ssh "$@"
        fi
      }
      compdef _kitten kitten

      _ssh_hosts() {
        _hosts "$@"
      }

      _setup_ssh_hosts() {
        local -a _all_hosts
        if [[ -r "$HOME/.ssh/config" ]]; then
          _all_hosts+=(''\${(s: :)$(sed -ne 's/^[Hh][Oo][Ss][Tt][[:space:]]\+//p' "$HOME/.ssh/config" 2>/dev/null | tr '\n' ' ' | sed -e 's/[*?][^ ]*//g')})
        fi
        if [[ -r "$HOME/.ssh/known_hosts" ]]; then
          _all_hosts+=(''\${(f)"$(grep -v '^[|#]' "$HOME/.ssh/known_hosts" 2>/dev/null | cut -d' ' -f1 | tr ',' '\n' | sed -e 's/\[//g' -e 's/\].*//g' | sort -u)"})
        fi
        if [[ -r "$HOME/.config/kitty/ssh_hosts.conf" ]]; then
          _all_hosts+=(''\${(s: :)$(sed -ne 's/^[[:space:]]*hostname[[:space:]]\+//p' "$HOME/.config/kitty/ssh_hosts.conf" 2>/dev/null | tr '\n' ' ' | sed -e 's/[*?][^ ]*//g')})
        fi
        if (( ''${#_all_hosts} )); then
          zstyle ':completion:*:hosts' hosts ''${(u)_all_hosts}
        fi
        zstyle ':completion:*:*:(s|ssh|kitten):*' tag-order 'hosts' 'users'
      }
      _setup_ssh_hosts

      zstyle ':fzf-tab:complete:(s|ssh|kitten):*' fzf-preview 'grep -A 8 -i -w "Host $word" ~/.ssh/config 2>/dev/null || grep -B 1 -A 5 -w "$word" ~/.config/kitty/ssh_hosts.conf 2>/dev/null || true'
    '';
  };
}
