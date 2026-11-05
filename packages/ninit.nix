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
          rust-gui|gui-rust|gpui|bevy|egui) TEMPLATE="rust-gui" ;;
          zig) TEMPLATE="zig" ;;
          typst|typ) TEMPLATE="typst" ;;
          tex) TEMPLATE="latex" ;;
          ts|node|js) TEMPLATE="typescript" ;;
          bun) TEMPLATE="bun" ;;
          c|cpp|c++) TEMPLATE="c-cpp" ;;
          arm|pio|platformio|tinygo) TEMPLATE="embedded" ;;
          php) TEMPLATE="php" ;;
          sh|bash|shellscript) TEMPLATE="shell" ;;
          java|gradle|maven) TEMPLATE="java" ;;
          cs|csharp|dotnet) TEMPLATE="csharp" ;;
          ex|elixir) TEMPLATE="elixir" ;;
          hs|haskell) TEMPLATE="haskell" ;;
          nix|flake) TEMPLATE="nix" ;;
          ctf|exploit|security|pwn) TEMPLATE="pwn" ;;
          rev|reversing|ghidra|radare2|disasm) TEMPLATE="reversing" ;;
          web-sec|ctf-web|webctf|pentest) TEMPLATE="ctf-web" ;;
          crypto|ctf-crypto|cryptography) TEMPLATE="ctf-crypto" ;;
          net|network|pcap|ctf-network|traffic) TEMPLATE="ctf-network" ;;
        esac

        if [ -z "$TEMPLATE" ]; then
          AVAILABLE_TEMPLATES=(
            "python-uv   - Python project with uv, ruff, pyright, and nix-ld"
            "go          - Go project with gopls, golangci-lint, and delve"
            "rust        - Rust project with cargo, rustc, rust-analyzer, clippy, rustfmt"
            "rust-gui    - Rust GUI/Game (GPUI, Bevy, Egui) with Wayland, Vulkan, Fontconfig"
            "zig         - Zig project with zig compiler, zls LSP, and GDB"
            "typst       - Modern typesetting with Typst, typstyle, and tinymist"
            "latex       - LaTeX project with LuaTeX, TeX Live Full, tectonic, and texlab"
            "typescript  - TypeScript & Node.js 22 project with pnpm, tsc, and Biome"
            "bun         - High-performance JavaScript/TypeScript with Bun"
            "c-cpp       - Modern C/C++ project with Clang, CMake, Ninja, GDB, Valgrind"
            "embedded    - Microcontroller project with PlatformIO, ARM GCC, TinyGo"
            "php         - PHP project with PHP 8.5 CLI and Composer"
            "shell       - Bash & POSIX shell scripting with shellcheck and shfmt"
            "java        - Java project with OpenJDK 21, Gradle, and Maven"
            "csharp      - C# / .NET 9 project with dotnet SDK and Omnisharp"
            "elixir      - Elixir project with Erlang/OTP, mix, and rebar3"
            "haskell     - Haskell project with GHC, Cabal, and Haskell Language Server"
            "nix         - Nix flake & packaging with nixd, statix, and alejandra"
            "pwn         - CTF binary exploitation with Pwntools, Ropper, ROPgadget, one_gadget, socat"
            "reversing   - Reverse engineering with Radare2, Rizin, Ghidra, Hexyl, Capstone"
            "ctf-web     - CTF web exploitation with ffuf, sqlmap, mitmproxy, and httpx"
            "ctf-crypto  - CTF cryptography with gmpy2, sympy, z3-solver, pycryptodome, hashcat"
            "ctf-network - CTF network & PCAP analysis with tshark, termshark, tcpdump, scapy"
          )

          if command -v fzf >/dev/null 2>&1; then
            CHOSEN=$(printf '%s\n' "''${AVAILABLE_TEMPLATES[@]}" | fzf --height 45% --reverse --prompt="Select project template > ")
            if [ -z "$CHOSEN" ]; then
              echo "[*] Aborted."
              exit 0
            fi
            TEMPLATE=$(echo "$CHOSEN" | awk '{print $1}')
          else
            echo "Available templates:"
            echo "  1) python-uv (py)     9) bun               17) haskell (hs)"
            echo "  2) go                10) c-cpp (c, cpp)    18) nix"
            echo "  3) rust (rs)         11) embedded (pio)    19) pwn (ctf)"
            echo "  4) rust-gui          12) php               20) reversing (rev)"
            echo "  5) zig               13) shell (sh, bash)  21) ctf-web"
            echo "  6) typst             14) java              22) ctf-crypto (crypto)"
            echo "  7) latex (tex)       15) csharp (cs)       23) ctf-network (net, pcap)"
            echo "  8) typescript (ts)   16) elixir (ex)"
            read -rp "Enter choice [1-23]: " choice
            case "$choice" in
              1|python-uv|py) TEMPLATE="python-uv" ;;
              2|go) TEMPLATE="go" ;;
              3|rust|rs) TEMPLATE="rust" ;;
              4|rust-gui) TEMPLATE="rust-gui" ;;
              5|zig) TEMPLATE="zig" ;;
              6|typst|typ) TEMPLATE="typst" ;;
              7|latex|tex) TEMPLATE="latex" ;;
              8|typescript|ts|node) TEMPLATE="typescript" ;;
              9|bun) TEMPLATE="bun" ;;
              10|c-cpp|c|cpp) TEMPLATE="c-cpp" ;;
              11|embedded|pio|arm) TEMPLATE="embedded" ;;
              12|php) TEMPLATE="php" ;;
              13|shell|sh|bash) TEMPLATE="shell" ;;
              14|java) TEMPLATE="java" ;;
              15|csharp|cs|dotnet) TEMPLATE="csharp" ;;
              16|elixir|ex) TEMPLATE="elixir" ;;
              17|haskell|hs) TEMPLATE="haskell" ;;
              18|nix) TEMPLATE="nix" ;;
              19|pwn|ctf|exploit) TEMPLATE="pwn" ;;
              20|reversing|rev) TEMPLATE="reversing" ;;
              21|ctf-web|web-sec) TEMPLATE="ctf-web" ;;
              22|ctf-crypto|crypto) TEMPLATE="ctf-crypto" ;;
              23|ctf-network|net|pcap) TEMPLATE="ctf-network" ;;
              *) echo "[!] Invalid choice"; exit 1 ;;
            esac
          fi
        fi

        if [ ! -d "$NIXCONF/templates/$TEMPLATE" ]; then
          echo "[!] Unknown template: '$TEMPLATE'. Run ninit without arguments to browse available templates."
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
          rust-gui)
            echo "    Run: cargo run  (Wayland, Vulkan, and graphics libraries preconfigured)"
            ;;
          zig)
            echo "    Run: zig build run"
            ;;
          typst)
            echo "    Run: typst watch main.typ  (or: typst compile main.typ)"
            ;;
          latex)
            echo "    Run: tectonic main.tex  (or: lualatex main.tex / latexmk -pdf main.tex)"
            ;;
          typescript)
            echo "    Run: pnpm install && pnpm dev  (build: pnpm build)"
            ;;
          bun)
            echo "    Run: bun run index.ts  (watch: bun --watch index.ts)"
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
          shell)
            echo "    Run: bash script.sh  (lint: shellcheck script.sh)"
            ;;
          java)
            echo "    Run: gradle run  (or: javac src/Main.java && java -cp src Main)"
            ;;
          csharp)
            echo "    Run: dotnet run"
            ;;
          elixir)
            echo "    Run: elixir main.exs  (or: iex -S mix)"
            ;;
          haskell)
            echo "    Run: runhaskell Main.hs  (or: cabal run)"
            ;;
          nix)
            echo "    Run: nix flake check  (lint: statix check, fmt: alejandra .)"
            ;;
          pwn)
            echo "    Run: python3 exploit.py  (remote: python3 exploit.py REMOTE)"
            ;;
          reversing)
            echo "    Run: rizin <binary>  (or: ghidra / python3 solve.py)"
            ;;
          ctf-web)
            echo "    Run: python3 exploit.py  (fuzz: ffuf -u http://TARGET/FUZZ -w ...)"
            ;;
          ctf-crypto)
            echo "    Run: python3 solve.py  (RSA, SMT solver, discrete log)"
            ;;
          ctf-network)
            echo "    Run: tshark -r <file.pcap>  (or: termshark / python3 analyze_pcap.py <file.pcap>)"
            ;;
        esac
      '';
    };
  in {
    packages.ninit = ninitScript;
  };
}
