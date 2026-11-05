# `nixos/features/apps/` — Application Feature Modules

This directory contains reusable application and developer suites (`flake.nixosModules.<name>`).

---

## 1. `dev.nix` (`flake.nixosModules.dev`)

Complete multi-language developer stack, container engines, and documentation compilers:

### Languages & Runtimes
- **Python**: `python3`, `uv` (fast Python package manager with `UV_PYTHON_DOWNLOADS=automatic`), `python3Packages.pip`, `ruff` (linter/formatter), `pyright` (LSP). Prebuilt C/C++ Python wheels work out-of-the-box thanks to `nix-ld`.
- **PHP**: PHP 8.5 with standard extensions.
- **Java**: OpenJDK 21 LTS (`pkgs.jdk21`).
- **Go**: `go`, `gopls`, `golangci-lint`, `delve`.
- **Rust**: `rustup` managing `rustc`, `cargo`, `rust-analyzer`, `clippy`, and `rustfmt`.
- **C/C++**: `gcc`, `clang`, `gnumake`, `cmake`, `pkg-config`, `ninja`.
- **Protobuf & gRPC APIs**: `buf` (Protobuf code generation, linter, and schema registry CLI), `protobuf`, `grpcurl`, `websocat`, `act`.

### LaTeX & Academic Publishing
- **TeX Live Suite**: `texliveMedium` bundled with `biber` (bibliography) and `chktex` (linter).
- **Compilers & Language Servers**: `tectonic` (modern standalone LaTeX engine), `texlab` (LSP), and `ltex-ls-plus` (grammar & spell check).
- **SyncTeX Bidirectional Sync**: Configured between Zathura and editors (`Ctrl+Click` in PDF navigates directly to LaTeX source line).

### Containers & Editors
- **Docker Engine**: `virtualisation.docker.enable = true` + `docker-compose`. User `virgola` has non-root Docker access.
- **Distrobox**: Launch arbitrary Linux distributions (Ubuntu, Fedora, Arch) inside your terminal.
- **Visual Studio Code**: `pkgs.vscode` with extensions and remote support.
- **Antigravity AI Platform**: Native host-integrated `antigravity-ide` (with `sudo` support, Wayland flags, and optional FHS mode) and CLI agent `agy` / `antigravity-cli`.

---

## 2. `antigravity.nix` (`flake.nixosModules.antigravity`)

Dedicated modular packaging and NixOS configuration for Google's Antigravity AI platform:
- **Native Host Execution (Default)**: Runs `antigravity-ide` directly on the host using `nix-ld` and `envfs`. Avoids Bubblewrap `PR_SET_NO_NEW_PRIVS` restrictions, allowing `sudo` commands and SUID binaries to execute seamlessly in the integrated terminal.
- **Toggleable FHS Sandbox**: `programs.antigravity.useFHS = true` is available if full Bubblewrap filesystem virtualization is desired.
- **CLI Dual Executables**: Packages both `agy` and `antigravity-cli` executables, plus an `antigravity` symlink for Zathura SyncTeX and terminal workflows.
- **Flake Packages**: Exposes `.packages.antigravity-ide`, `.packages.antigravity-cli`, and `.packages.agy` under `perSystem.packages`.

---

## 2. `security.nix` (`flake.nixosModules.security`)

Comprehensive Cyber Security, Binary Exploitation (Pwn), Reverse Engineering, Cryptography, and Steganography suite:

### Binary Exploitation (Pwn) & Debugging
- **GDB & Pwndbg**: Standard `gdb` paired with cutting-edge `pwndbg` from flake inputs.
- **Exploitation Utilities**:
  - `pwninit`: Auto-patches glibc, downloads symbols, and stubs exploit scripts.
  - `pwninit-ghidra`: Automated wrapper that stubs `solve.py` with Ghidra headless decompilation.
  - `python3Packages.pwntools`: The premier Python binary exploitation framework.
  - `python3Packages.ropper` & `ropgadget`: ROP/JOP/SYS gadget finders.
  - `one_gadget`: Best tool for finding `execve("/bin/sh")` one-gadgets in `libc.so.6`.
  - `rubyPackages.seccomp-tools`: Disassembler and inspector for Linux kernel BPF seccomp sandbox filters.
  - `checksec`, `patchelf`, `elfutils` (`eu-readelf`, `eu-elfcmp`), `ltrace`, `strace`, `file`, `xxd`.

### Reverse Engineering & Hex Editors
- **Ghidra**: NSA software reverse engineering suite with JDK 21 runtime.
- **Headless Automation**: `ghidra-auto` for automated batch binary decompilation.
- **Hex & Binary Editors**: `ht` (interactive PE/ELF/hex viewer), `rizin`, `radare2`, `imhex`.

### Steganography & Password Cracking
- **Binwalk**: Firmware analysis, extraction, and file signature carving.
- **Stegsolve**: Visual steganography analyzer and bit plane extractor.
- **John the Ripper**: `john` (Jumbo suite) for cracking hashes, archives, and keys.

### Network Security & Traffic Analysis
- **Wireshark**: GUI packet analyzer with non-root packet capture permissions for user `virgola`.
- **Tshark**: Wireshark CLI packet analysis suite (`tshark`, `dumpcap`, `mergecap`).
- **Pyshark**: Python packet parsing wrapper for Tshark.
- **Scanning & Discovery**: `nmap`, `netcat-gnu`, `gobuster`.

### Web Security & Ingress Tunneling
- **Burp Suite Community**: Web vulnerability assessment and proxy.
- **Postman**: API development, inspection, and testing platform.
- **Ngrok**: Secure introspection tunnels to expose local servers.
- **Tunnelmole (`tmole`)**: Open-source ngrok alternative packaged in `packages/tunnelmole.nix`. Run `tmole <port>` to get instant public HTTPS URLs.

### Cryptography & Mathematics
- **SageMath**: `sage` (SageMath 10.9) precompiled and cached from Nixpkgs Hydra—no 2-hour virtual machine source builds required!
- **PyCryptodome**: `python3Packages.pycryptodome` for modern cryptography in Python.
- **MTP (Many-Time Pad)**: Interactive XOR key-reuse cryptanalysis solver (`packages/mtp.nix`). Run `mtp <ciphertexts.txt>`.

---

## 3. `desktop.nix` (`flake.nixosModules.desktopApps`)

Essential daily productivity, graphics, media, and document applications:
- **Web & Communication**: Firefox, Vesktop (Discord Wayland client with screensharing and rich presence), Telegram Desktop, Obsidian.
- **Graphics & Media**: GIMP 3, Spotify, VLC, MPV, Pavucontrol (audio control).
- **File Management & Theming**: Thunar with archive and volume plugins, `gvfs` (trash and auto-mounting), `tumbler` (thumbnails), Yazi terminal file manager, and system-wide GTK3/GTK4 theming (`adw-gtk3-dark`, `Papirus-Dark`, `Bibata-Modern-Classic` cursors, and dconf `prefer-dark` settings configured via `nixos/settings.nix`).
- **PDFs & Screenshots**: Zathura with SyncTeX, `poppler-utils`, `grim`, `slurp`, and `swappy` (`SUPER + SHIFT + S`).

---

## 4. `gaming.nix` (`flake.nixosModules.gaming`)

Dedicated gaming optimizations:
- **Steam**: Valve Steam with Proton-GE and Gamescope compatibility.
- **GameMode**: Feral Interactive GameMode for dynamic CPU/GPU governor scheduling.
