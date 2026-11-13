# Application modules in nixos/features/apps/

This directory contains application and developer modules exposed under `flake.nixosModules.<name>`.

## 1. dev.nix (flake.nixosModules.dev)

Development toolchains, container engines, and document tools:

### Languages and runtimes
- Python: `python3`, `uv` with `UV_PYTHON_DOWNLOADS=automatic`, `pip`, `ruff`, and `pyright`. Prebuilt C/C++ Python wheels run through `nix-ld`.
- PHP: PHP 8.5 with standard extensions.
- Java: OpenJDK 21 LTS (`pkgs.jdk21`).
- Go: `go`, `gopls`, `golangci-lint`, `delve`.
- Rust: `rustup` managing `rustc`, `cargo`, `rust-analyzer`, `clippy`, and `rustfmt`.
- C and C++: `gcc`, `clang`, `gnumake`, `cmake`, `pkg-config`, `ninja`.
- Protobuf and gRPC: `buf`, `protobuf`, `grpcurl`, `websocat`, and `act`.

### LaTeX and academic publishing
- TeX Live: `texliveMedium` bundled with `biber` and `chktex`.
- Compilers and language servers: `texlab` and `ltex-ls-plus`.
- SyncTeX: configured between Zathura and editors with `Ctrl+Click` navigation from PDF to LaTeX source.

### Containers and editors
- Docker: `virtualisation.docker.enable = true` and `docker-compose`. User `virgola` has non-root Docker access.
- Distrobox: run containers from other distributions inside the terminal.
- VS Code: `pkgs.vscode` with remote extensions.
- Antigravity AI platform: native `antigravity-ide` and CLI agent `agy` / `antigravity-cli`.

## 2. antigravity.nix (flake.nixosModules.antigravity)

Packaging and NixOS configuration for Antigravity:
- Native execution: runs `antigravity-ide` directly on the host using `nix-ld` and `envfs`, enabling `sudo` commands and SUID binaries in the integrated terminal without Bubblewrap privilege restrictions.
- Optional FHS mode: `programs.antigravity.useFHS = true` provides Bubblewrap filesystem isolation if required.
- CLI binaries: provides `agy` and `antigravity-cli` executables, plus an `antigravity` symlink for Zathura SyncTeX workflows.
- Flake packages: exposes `packages.antigravity-ide`, `packages.antigravity-cli`, and `packages.agy`.

## 3. security.nix (flake.nixosModules.security)

Security, binary analysis, cryptography, and steganography tools:

### Binary exploitation and debugging
- GDB and Pwndbg: `gdb` paired with `pwndbg` from flake inputs.
- Utilities: `pwninit`, `pwninit-ghidra`, `pwntools`, `ropper`, `ropgadget`, `one_gadget`, `seccomp-tools`, `checksec`, `patchelf`, `elfutils` (`eu-readelf`, `eu-elfcmp`), `ltrace`, `strace`, `file`, `xxd`.

### Reverse engineering and hex editors
- Ghidra with JDK 21 and headless scripts (`ghidra-auto`).
- Editors and disassemblers: `ht`, `rizin`, `radare2`, `imhex`.

### Steganography and password cracking
- `binwalk`, `stegsolve`, and `john` (Jumbo suite).

### Network security and traffic analysis
- Wireshark and Tshark: GUI and CLI packet capture with non-root dumpcap permissions for user `virgola`.
- `pyshark`, `nmap`, `netcat-gnu`, `gobuster`.

### Web security and tunneling
- Burp Suite Community edition.
- Postman API client.
- `ngrok` and `tunnelmole` (`tmole`, packaged in `packages/tunnelmole.nix`).

### Cryptography and mathematics
- SageMath: `sage` from the Nixpkgs binary cache.
- Python libraries: `pycryptodome`, `gmpy2`, `sympy`, `z3-solver`.
- MTP: interactive Many-Time Pad cryptanalysis tool (`packages/mtp.nix`).

## 4. desktop.nix (flake.nixosModules.desktopApps)

Desktop and media applications:
- Web and messaging: Firefox, Vesktop (Discord Wayland client with screensharing), Telegram Desktop, Obsidian.
- Graphics and media: GIMP 3, Spotify, VLC, MPV, Pavucontrol.
- File management and theming: Thunar with archive and volume plugins, `gvfs`, `tumbler`, Yazi, and GTK3/GTK4 theming (`adw-gtk3-dark`, `Papirus-Dark`, `Bibata-Modern-Classic` cursors).
- Documents and screenshots: Zathura with SyncTeX, `poppler-utils`, `grim`, `slurp`, and `swappy` (`SUPER + SHIFT + S`).

## 5. gaming.nix (flake.nixosModules.gaming)

Gaming tools and runtime optimizations:
- Steam with Proton-GE and Gamescope compatibility.
- GameMode: CPU and GPU governor scheduling.
