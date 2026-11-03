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
          rs) TEMPLATE="rust" ;;
          tex) TEMPLATE="latex" ;;
          ts|node|js) TEMPLATE="typescript" ;;
          c|cpp|c++) TEMPLATE="c-cpp" ;;
          arm|pio|platformio|tinygo) TEMPLATE="embedded" ;;
          php) TEMPLATE="php" ;;
          ctf|exploit|security) TEMPLATE="pwn" ;;
        esac

        if [ -z "$TEMPLATE" ]; then
          AVAILABLE_TEMPLATES=(
            "python-uv   - Python project with uv, ruff, pyright, and nix-ld"
            "go          - Go project with gopls, golangci-lint, and delve"
            "rust        - Rust project with cargo, rustc, rust-analyzer, clippy"
            "latex       - LaTeX project with LuaTeX, TeX Live, tectonic, and texlab"
            "typescript  - TypeScript & Node 22 project with pnpm, tsc, and Biome"
            "c-cpp       - Modern C/C++ project with Clang, CMake, Ninja, and GDB"
            "embedded    - Microcontroller project with PlatformIO, ARM GCC, TinyGo"
            "php         - Modern PHP project with PHP 8.4 CLI and Composer"
            "pwn         - CTF / binary exploitation with Pwntools, Ropper, GDB"
          )

          if command -v fzf >/dev/null 2>&1; then
            CHOSEN=$(printf '%s\n' "''${AVAILABLE_TEMPLATES[@]}" | fzf --height 35% --reverse --prompt="Select project template > ")
            if [ -z "$CHOSEN" ]; then
              echo "[*] Aborted."
              exit 0
            fi
            TEMPLATE=$(echo "$CHOSEN" | awk '{print $1}')
          else
            echo "Available templates:"
            echo "  1) python-uv (py)"
            echo "  2) go"
            echo "  3) rust (rs)"
            echo "  4) latex (tex)"
            echo "  5) typescript (ts, node)"
            echo "  6) c-cpp (c, cpp)"
            echo "  7) embedded (pio, arm)"
            echo "  8) php"
            echo "  9) pwn (ctf, exploit)"
            read -rp "Enter choice [1-9]: " choice
            case "$choice" in
              1|python-uv|py) TEMPLATE="python-uv" ;;
              2|go) TEMPLATE="go" ;;
              3|rust|rs) TEMPLATE="rust" ;;
              4|latex|tex) TEMPLATE="latex" ;;
              5|typescript|ts|node) TEMPLATE="typescript" ;;
              6|c-cpp|c|cpp) TEMPLATE="c-cpp" ;;
              7|embedded|pio|arm) TEMPLATE="embedded" ;;
              8|php) TEMPLATE="php" ;;
              9|pwn|ctf|exploit) TEMPLATE="pwn" ;;
              *) echo "[!] Invalid choice"; exit 1 ;;
            esac
          fi
        fi

        if [ ! -d "$NIXCONF/templates/$TEMPLATE" ]; then
          echo "[!] Unknown template: '$TEMPLATE'. Available: python-uv, go, rust, latex, typescript, c-cpp, embedded, php, pwn"
          exit 1
        fi

        if [ -z "$TARGET_DIR" ] && [ -t 0 ]; then
          CURRENT_DIR="$(pwd)"
          echo ""
          echo "Select target directory:"
          echo "  1) Current folder ($CURRENT_DIR)"
          echo "  2) Create a new folder"
          read -rp "Enter choice [1/2] (default: 1) or folder name: " dir_choice
          case "$dir_choice" in
            ""|1)
              TARGET_DIR="."
              ;;
            2)
              read -rp "Enter new folder name: " new_dir
              while [ -z "$new_dir" ]; do
                read -rp "Folder name cannot be empty. Enter folder name: " new_dir
              done
              TARGET_DIR="$new_dir"
              ;;
            *)
              TARGET_DIR="$dir_choice"
              ;;
          esac
        fi

        if [ -n "$TARGET_DIR" ] && [ "$TARGET_DIR" != "." ]; then
          mkdir -p "$TARGET_DIR"
          cd "$TARGET_DIR"
        fi

        echo "[+] Initializing '$TEMPLATE' template in $(pwd)..."

        nix flake init -t "$NIXCONF#$TEMPLATE"

        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git init -q
          echo "[+] Initialized empty Git repository."
        fi

        # Ensure .direnv/ is ignored so it is not tracked by Git
        if [ ! -f .gitignore ]; then
          printf ".direnv/\nresult\nresult-*\n" > .gitignore
        elif ! grep -q "^\.direnv" .gitignore; then
          printf "\n# Direnv\n.direnv/\n" >> .gitignore
        fi

        # Nix flakes require flake.nix to be tracked in Git for evaluation
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git add -A
          echo "[+] Staged template files in Git."
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
          typescript)
            echo "    Run: pnpm install && pnpm dev  (build: pnpm build)"
            ;;
          c-cpp)
            echo "    Run: cmake -B build -G Ninja && ninja -C build && ./build/main"
            ;;
          embedded)
            echo "    Run: pio run  (upload: pio run -t upload)"
            ;;
          php)
            echo "    Run: composer install && php -S localhost:8000 -t public"
            ;;
          pwn)
            echo "    Run: python3 exploit.py  (remote: python3 exploit.py REMOTE)"
            ;;
        esac
      '';
    };
  in {
    packages.ninit = ninitScript;
  };
}
