# Project devShell templates in templates/

This directory contains project templates exposed through `flake.templates.<name>` and used by `ninit` or `nix flake init -t`.

## Starting a project

### Automated scaffolding with ninit

Run `ninit` to select a template interactively or pass the template name directly:

```bash
# Interactive picker:
ninit

# Direct template initialization:
ninit rust my-crate          # Scaffolds Rust template in ./my-crate
ninit rust-gui my-gpui-app   # Scaffolds Rust GUI (GPUI, Bevy, Egui) in ./my-gpui-app
ninit zig my-zig-app         # Scaffolds Zig and ZLS template in ./my-zig-app
ninit typst my-doc           # Scaffolds Typst and Tinymist template in ./my-doc
ninit py my-fastapi          # Scaffolds Python uv template in ./my-fastapi
ninit go my-microservice     # Scaffolds Go template in ./my-microservice
ninit bun my-bun-app         # Scaffolds Bun JS/TS template in ./my-bun-app
ninit ts my-frontend         # Scaffolds TypeScript and Node 22 template in ./my-frontend
ninit latex my-thesis        # Scaffolds LaTeX/LuaTeX template in ./my-thesis
ninit cpp my-engine          # Scaffolds C/C++ template in ./my-engine
ninit pio my-firmware        # Scaffolds embedded PlatformIO template in ./my-firmware
ninit php my-api             # Scaffolds PHP and Composer template in ./my-api
ninit shell my-script        # Scaffolds shell scripting template in ./my-script
ninit java my-java-app       # Scaffolds Java template in ./my-java-app
ninit cs my-dotnet-app       # Scaffolds C# and .NET 9 template in ./my-dotnet-app
ninit elixir my-elixir-app   # Scaffolds Elixir and Erlang template in ./my-elixir-app
ninit haskell my-haskell     # Scaffolds Haskell and HLS template in ./my-haskell
ninit nix my-flake           # Scaffolds Nix packaging template in ./my-flake
ninit ctf-base my-base-ctf   # Scaffolds CTF base and forensics template in ./my-base-ctf
ninit ctf-pwn my-pwn-ctf     # Scaffolds CTF binary exploitation template in ./my-pwn-ctf
ninit ctf-rev my-rev-ctf     # Scaffolds CTF reverse engineering template in ./my-rev-ctf
ninit ctf-crypto my-crypto   # Scaffolds CTF cryptography template in ./my-crypto
ninit ctf-web my-web-ctf     # Scaffolds CTF web exploitation template in ./my-web-ctf
ninit ctf-osint my-osint-lab # Scaffolds CTF OSINT and recon template in ./my-osint-lab
ninit ctf-network my-pcap    # Scaffolds CTF network and PCAP template in ./my-pcap
ninit ctf-full my-all-in-one # Scaffolds full CTF workspace in ./my-all-in-one
```

`ninit` handles initialization steps:
1. Creates the target directory.
2. Copies template files (`flake.nix`, `.envrc`, starter code, and configs).
3. Initializes a Git repository if one does not exist.
4. Adds `.direnv/`, `result`, and `result-*` to `.gitignore`.
5. Stages files with `git add -A`.
6. Runs `direnv allow` to activate the devShell.

## Available templates

### Systems and general purpose
- `rust`: Cargo, rustc, rust-analyzer, clippy, rustfmt, OpenSSL, starter `Cargo.toml` and `src/main.rs`.
- `rust-gui`: Rust GUI and game development (GPUI, Bevy, Egui, Winit) configured with Wayland, Vulkan, libxkbcommon, Fontconfig, and `LD_LIBRARY_PATH`.
- `zig`: Zig compiler, `zls` language server, GDB, starter `build.zig` and `src/main.zig`.
- `c-cpp`: Clang, GCC, CMake, Ninja, GDB, Valgrind, `clang-tools` (clangd, clang-format).
- `go`: Go, `gopls` language server, `golangci-lint`, `delve` debugger, starter `go.mod` and `main.go`.
- `python-uv`: Python, `uv`, `ruff`, `pyright`, `nix-ld` compatibility, starter `pyproject.toml` and `main.py`.
- `embedded`: PlatformIO Core (`pio`), ARM Embedded GCC, TinyGo, Avrdude, OpenOCD.

### Web, scripting, and runtimes
- `typescript`: Node.js 22 LTS, `pnpm`, `typescript`, `biome` linter and formatter, `package.json`, `tsconfig.json`.
- `bun`: Bun runtime, package manager, test runner, starter `package.json` and `index.ts`.
- `php`: PHP CLI, Composer, PSR-4 autoloading starter `composer.json` and `public/index.php`.
- `shell`: Bash and POSIX shell scripting with `shellcheck` and `shfmt`.

### Document and typesetting
- `typst`: Document typesetting with `typst`, `typstyle` formatter, and `tinymist` LSP.
- `latex`: TeX Live, LuaTeX, `texlab` LSP, `zathura` viewer with SyncTeX.

### Enterprise and functional languages
- `java`: OpenJDK 21, Gradle, Maven, configured `JAVA_HOME`.
- `csharp`: .NET 9 SDK, `omnisharp-roslyn`, configured `DOTNET_ROOT` and starter `.csproj`.
- `elixir`: Elixir, Erlang/OTP, `rebar3`.
- `haskell`: GHC, Cabal, Haskell Language Server (`haskell-language-server`).
- `nix`: Nix flake development with `nixd` LSP, `statix`, `deadnix`, and `alejandra` formatter.

### Security and CTF suite
- `ctf-base`: CTF foundation with `gdb`, `strace`, `ltrace`, `binwalk`, `exiftool`, `nasm`, `patchelf`, `socat`, `netcat`, and `pwntools`.
- `ctf-pwn`: Binary exploitation with `gdb`, `gef`, `checksec`, `patchelf`, `one_gadget`, `ropgadget`, `pwninit`, `qemu-user`, `socat`, `pwntools`, `angr`, `keystone-engine`, `scapy`, and `z3-solver`.
- `ctf-rev`: Reverse engineering and binary analysis with `ghidra-bin`, `rizin`, `radare2`, `jadx`, `apktool`, `binwalk`, `hexyl`, `capstone`, `unicorn`, `angr`, `lief`, and `z3-solver`.
- `ctf-crypto`: Cryptography with `hashcat`, `john`, `z3`, `openssl`, `gmpy2`, `sympy`, `z3-solver`, `numpy`, and `pycryptodome`.
- `ctf-web`: Web penetration testing with `ffuf`, `gobuster`, `sqlmap`, `nikto`, `mitmproxy`, `nmap`, `requests`, `httpx`, and `beautifulsoup4`.
- `ctf-osint`: OSINT and reconnaissance with `sherlock`, `theHarvester`, `holehe`, `socialscan`, `maigret`, `exiftool`, and `volatility3`.
- `ctf-network`: Network packet and PCAP analysis with `wireshark-cli` (`tshark`), `termshark`, `tcpdump`, `nmap`, `scapy`, `pyshark`, and `dpkt`.
- `ctf-full`: CTF environment combining tools from base, pwn, rev, crypto, web, osint, and network.
