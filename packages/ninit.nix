{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    ninitScript = pkgs.writeShellApplication {
      name = "ninit";
      runtimeInputs = with pkgs; [
        fzf
        git
        direnv
        coreutils
        gawk
      ];
      text = ''
        NIXCONF=""
        if [ -n "''${NIXCONF_DIR:-}" ] && [ -d "$NIXCONF_DIR/templates" ]; then
          NIXCONF="$NIXCONF_DIR"
        elif [ -d "$HOME/nixconf/templates" ]; then
          NIXCONF="$HOME/nixconf"
        elif [ -d "/etc/nixos/templates" ]; then
          NIXCONF="/etc/nixos"
        else
          echo "[!] Could not locate nixconf templates directory."
          exit 1
        fi

        TEMPLATE="''${1:-}"
        TARGET_DIR="''${2:-}"

        case "$TEMPLATE" in
          py|python|uv) TEMPLATE="python-uv" ;;
          golang) TEMPLATE="go" ;;
          tex) TEMPLATE="latex" ;;
        esac

        if [ -z "$TEMPLATE" ]; then
          AVAILABLE_TEMPLATES=(
            "python-uv - Python project with uv, ruff, pyright, and nix-ld"
            "go        - Go project with gopls, golangci-lint, and delve"
            "rust      - Rust project with cargo, rustc, rust-analyzer, clippy"
            "latex     - LaTeX project with LuaTeX, TeX Live, tectonic, and texlab"
          )

          if command -v fzf >/dev/null 2>&1; then
            CHOSEN=$(printf '%s\n' "''${AVAILABLE_TEMPLATES[@]}" | fzf --height 30% --reverse --prompt="Select project template > ")
            if [ -z "$CHOSEN" ]; then
              echo "[*] Aborted."
              exit 0
            fi
            TEMPLATE=$(echo "$CHOSEN" | awk '{print $1}')
          else
            echo "Available templates:"
            echo "  1) python-uv (py)"
            echo "  2) go"
            echo "  3) rust"
            echo "  4) latex"
            read -rp "Enter choice [1-4]: " choice
            case "$choice" in
              1|python-uv|py) TEMPLATE="python-uv" ;;
              2|go) TEMPLATE="go" ;;
              3|rust) TEMPLATE="rust" ;;
              4|latex) TEMPLATE="latex" ;;
              *) echo "[!] Invalid choice"; exit 1 ;;
            esac
          fi
        fi

        if [ ! -d "$NIXCONF/templates/$TEMPLATE" ]; then
          echo "[!] Unknown template: '$TEMPLATE'. Available: python-uv, go, rust, latex"
          exit 1
        fi

        if [ -n "$TARGET_DIR" ]; then
          mkdir -p "$TARGET_DIR"
          cd "$TARGET_DIR"
        fi

        echo "[+] Initializing '$TEMPLATE' template in $(pwd)..."

        nix flake init -t "$NIXCONF#$TEMPLATE"

        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git init -q
          echo "[+] Initialized empty Git repository."
        fi

        if command -v direnv >/dev/null 2>&1 && [ -f .envrc ]; then
          direnv allow
          echo "[+] Enabled direnv environment."
        fi

        echo ""
        echo "[✓] Project initialized successfully from template '$TEMPLATE'!"
        case "$TEMPLATE" in
          python-uv)
            echo "    Run: uv run main.py"
            ;;
          go)
            echo "    Run: go run ."
            ;;
          rust)
            echo "    Run: cargo run"
            ;;
          latex)
            echo "    Run: tectonic main.tex  (or: lualatex main.tex / latexmk -pdf main.tex)"
            ;;
        esac
      '';
    };
  in {
    packages.ninit = ninitScript;
  };
}
