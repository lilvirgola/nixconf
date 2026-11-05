# `templates/` — Project DevShell Templates

This directory houses reproducible, zero-friction project templates exposed via `flake.templates.<name>` and consumable with the automated `ninit` CLI tool or `nix flake init -t`.

---

## Three Ways to Start a Project on NixOS

### Method 1: Automated Scaffold (`ninit`) — Recommended!

The fastest, recommended method to bootstrap a new repository:

```bash
# 1. Interactive picker with fzf:
ninit

# 2. Or specify template and project name directly:
ninit rust my-crate          # Scaffolds Rust template in ./my-crate
ninit rust-gui my-gpui-app   # Scaffolds Rust GUI (GPUI, Bevy, Egui) in ./my-gpui-app
ninit zig my-zig-app         # Scaffolds Zig & ZLS template in ./my-zig-app
ninit typst my-doc           # Scaffolds Typst & Tinymist template in ./my-doc
ninit py my-fastapi          # Scaffolds Python uv template in ./my-fastapi
ninit go my-microservice     # Scaffolds Go template in ./my-microservice
ninit bun my-bun-app         # Scaffolds Bun JS/TS template in ./my-bun-app
ninit ts my-frontend         # Scaffolds TypeScript & Node 22 template in ./my-frontend
ninit latex my-thesis        # Scaffolds LaTeX/LuaTeX template in ./my-thesis
ninit cpp my-engine          # Scaffolds Modern C/C++ template in ./my-engine
ninit pio my-firmware        # Scaffolds Embedded & PlatformIO template in ./my-firmware
ninit php my-api             # Scaffolds PHP & Composer template in ./my-api
ninit shell my-script        # Scaffolds Shellcheck & shfmt template in ./my-script
ninit java my-java-app       # Scaffolds Java & Gradle/Maven template in ./my-java-app
ninit cs my-dotnet-app       # Scaffolds C# & .NET 9 template in ./my-dotnet-app
ninit elixir my-elixir-app   # Scaffolds Elixir & Erlang template in ./my-elixir-app
ninit haskell my-haskell     # Scaffolds Haskell & HLS template in ./my-haskell
ninit nix my-flake           # Scaffolds Nix packaging & LSP template in ./my-flake
ninit pwn my-pwn-ctf         # Scaffolds Binary Exploitation template in ./my-pwn-ctf
ninit rev my-reversing-lab   # Scaffolds Reverse Engineering template in ./my-reversing-lab
ninit ctf-web my-web-ctf     # Scaffolds CTF Web Exploitation template in ./my-web-ctf
ninit crypto my-crypto-ctf   # Scaffolds CTF Cryptography template in ./my-crypto-ctf
ninit net my-pcap-lab        # Scaffolds CTF Network / PCAP template in ./my-pcap-lab
```

`ninit` handles all boilerplate automatically:
1. Creates the target directory.
2. Copies all template files (`flake.nix`, `.envrc`, starter code, and config files).
3. Initializes a Git repository with `git init`.
4. Runs `direnv allow` so the isolated `devShell` activates instantly.

---

## Available Templates (23 Total)

### Systems & General Purpose
1. **`rust`**: Cargo, rustc, rust-analyzer, clippy, rustfmt, OpenSSL, starter `Cargo.toml` and `src/main.rs`.
2. **`rust-gui`**: Rust GUI/Game dev (GPUI, Bevy, Egui, Winit) preconfigured with Wayland, Vulkan, libxkbcommon, Fontconfig, and `LD_LIBRARY_PATH`.
3. **`zig`**: Zig compiler, `zls` language server, GDB, starter `build.zig` and `src/main.zig`.
4. **`c-cpp`**: Clang, GCC, CMake, Ninja, GDB, Valgrind, `clang-tools` (clangd, clang-format).
5. **`go`**: Go, `gopls` language server, `golangci-lint`, `delve` debugger, starter `go.mod` and `main.go`.
6. **`python-uv`**: Python, `uv`, `ruff`, `pyright`, `nix-ld` compatibility, starter `pyproject.toml` and `main.py`.
7. **`embedded`**: PlatformIO Core (`pio`), ARM Embedded GCC, TinyGo, Avrdude, OpenOCD.

### Web, Scripting & Runtimes
8. **`typescript`**: Node.js 22 LTS, `pnpm`, `typescript`, `biome` linter/formatter, `package.json`, `tsconfig.json`.
9. **`bun`**: Bun ultra-fast runtime, package manager, test runner, starter `package.json` and `index.ts`.
10. **`php`**: PHP CLI, Composer, PSR-4 autoloading starter `composer.json` and `public/index.php`.
11. **`shell`**: Bash & POSIX shell scripting with `shellcheck` linter and `shfmt` formatter.

### Document & Typesetting
12. **`typst`**: Modern document typesetting with `typst`, `typstyle` formatter, and `tinymist` LSP.
13. **`latex`**: TeX Live Full, LuaTeX, `tectonic`, `texlab` LSP, `zathura` viewer with bidirectional SyncTeX.

### Enterprise & Functional Languages
14. **`java`**: OpenJDK 21, Gradle, Maven, preconfigured `JAVA_HOME`.
15. **`csharp`**: .NET 9 SDK, `omnisharp-roslyn`, preconfigured `DOTNET_ROOT` and starter `.csproj`.
16. **`elixir`**: Elixir, Erlang/OTP, `rebar3`.
17. **`haskell`**: GHC, Cabal, Haskell Language Server (`haskell-language-server`).
18. **`nix`**: Nix flake development with `nixd` LSP, `statix` linter, `deadnix`, and `alejandra` formatter.

### Security, CTF & Reverse Engineering (Personalized)
19. **`pwn`**: Binary exploitation with Python `pwntools`, `pycryptodome`, `ropper`, `ropgadget`, `one_gadget`, `gdb`, `checksec`, `patchelf`, `socat`.
20. **`reversing`**: Reverse engineering & binary analysis with `radare2`, `rizin`, `ghidra-bin`, `hexyl`, `binwalk`, `capstone`, `unicorn`, `pefile`.
21. **`ctf-web`**: Web penetration testing & CTF with `ffuf`, `sqlmap`, `mitmproxy`, `socat`, `requests`, `httpx`, `beautifulsoup4`.
22. **`ctf-crypto`**: Cryptanalysis & mathematical CTF with `gmpy2`, `sympy`, `z3-solver`, `pycryptodome`, `cryptography`, `hashcat`, and `john`.
23. **`ctf-network`**: Network packet & PCAP forensics with `wireshark-cli` (`tshark`), `termshark`, `tcpdump`, `scapy`, `pyshark`, and `dpkt`.
