# `nixos/features/apps/` — Application Feature Modules

## What Goes Here?

Reusable NixOS modules (`flake.nixosModules.<name>`) for user-facing applications, development stacks, security/reverse-engineering tools, and gaming setups.

### Current Modules
- [`desktop.nix`](./desktop.nix) (`flake.nixosModules.desktopApps`):
  - **Web & Comms**: Firefox, Vesktop (Wayland Discord), Telegram Desktop, Obsidian
  - **Media & Audio**: Spotify, MPV, VLC, Pavucontrol
  - **Files, Docs & Screenshots**: Thunar, Yazi, Zathura, `grim` + `slurp` + `swappy` (`SUPER+SHIFT+S` in MangoWM)
- [`dev.nix`](./dev.nix) (`flake.nixosModules.dev`):
  - **Python**: `uv`, `python3`, `ruff`, `pyright` (with `UV_PYTHON_DOWNLOADS=automatic` + `nix-ld`)
  - **Go**: `go`, `gopls`, `golangci-lint`, `delve`
  - **Rust**: `rustup` (`cargo`, `rustc`, `rust-analyzer`, `clippy`, `rustfmt`)
  - **C/C++ & Build**: `gcc`, `clang`, `gnumake`, `cmake`, `pkg-config`, `ninja`
  - **Containers**: Docker (`virtualisation.docker.enable = true`) & `distrobox`
  - **AI Development**: Antigravity IDE (`antigravity-ide-fhs`) & Antigravity CLI (`agy` via `antigravity-cli`)
- [`security.nix`](./security.nix) (`flake.nixosModules.security`):
  - **Reverse Engineering**: Ghidra, Cutter, Rizin, Radare2, ImHex
  - **Pwn & Debugging**: `gdb`, `pwndbg` (run `pwndbg` directly in terminal), `checksec`, `patchelf`, `binwalk`, `ltrace`, `strace`, `file`, `xxd`, `ropgadget`, `one_gadget`
  - **Network & Web**: Wireshark (with non-root packet capture via `wireshark` group), `nmap`, `netcat`, `gobuster`, `burpsuite`
- [`gaming.nix`](./gaming.nix) (`flake.nixosModules.gaming`):
  - **Steam**: `programs.steam` with Proton-GE, Gamescope session, and `nix-gaming` platform optimizations
  - **Launchers & Utilities**: Heroic Games Launcher, GameMode, MangoHud, Protontricks
