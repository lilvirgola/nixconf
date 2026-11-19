# nixconf

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Architecture](https://img.shields.io/badge/Architecture-Flake--Parts%20%2B%20Home%20Manager-7c5295.svg)](https://flake.parts)
[![Compositor](https://img.shields.io/badge/Compositor-MangoWM%20(Wayland)-orange.svg)](https://github.com/BirdeeHub/nix-wrapper-modules)
[![Formatter](https://img.shields.io/badge/Formatter-Alejandra-brightgreen.svg)](https://github.com/kamadorueda/alejandra)

NixOS and Home Manager flake configuration for workstations, VMs, headless servers, a Raspberry Pi 4, and a custom rescue ISO.

## Hosts

| Host | Arch | Role | Disk / Boot |
| :--- | :--- | :--- | :--- |
| `laptop` | `x86_64-linux` | Primary laptop (AMD + Nvidia PRIME, MangoWM, gaming, security) | UEFI systemd-boot, LUKS + Btrfs (`_disko.nix` for fresh installs) |
| `desktop` | `x86_64-linux` | Workstation without laptop or Nvidia quirks | UEFI systemd-boot, Btrfs via `disko` |
| `vm` | `x86_64-linux` | Graphical QEMU/KVM VM (MangoWM, SPICE, VS Code Server) | GRUB, `qemu-guest`, `_disko.nix` available |
| `vm-minimal` | `x86_64-linux` | Headless CLI-only VM for fast evaluation and testing | GRUB + EFI, `disko` ext4 |
| `server` | `x86_64-linux` | Headless homelab server (Docker, Tailscale, hardened SSH) | UEFI systemd-boot, `disko` Btrfs |
| `raspberrypi` | `aarch64-linux` | Raspberry Pi 4 headless server (`nixos-hardware` + SD image) | `sd-image-aarch64` (`nix build .#raspberrypi-sd`) |
| `iso` | `x86_64-linux` | Custom live/rescue USB with `disko`, `ninit`, `kssh`, disk tools | Bootable ISO (`nix build .#iso`) |

## Repository layout

Every `.nix` file outside `templates/` and `home/` (and not prefixed with `_`) is auto-imported as a `flake-parts` module by `flake.nix`.

```text
nixconf/
├── flake.nix                  # Flake inputs (nixpkgs, home-manager, disko, nixos-hardware)
├── bootstrap.sh               # Interactive installer and host provisioning script
├── .githooks/pre-commit       # Alejandra formatting + statix/deadnix check on staged .nix files
├── lib/                       # Supported systems, formatter, lint checks, devShell, templates
├── home/                      # Home Manager modules (core CLI + desktop dotfiles)
├── wrappedPrograms/           # Standalone wrapped apps (myKitty, myMango, myNiri, myNoctalia)
├── packages/                  # Custom packages (ninit, keyhints, kssh, ssh-vault, mtp, tunnelmole)
├── templates/                 # 26 project templates for `ninit` / `nix flake init`
├── nixos/
│   ├── settings.nix           # User identity, SSH keys, locale, and theme options
│   ├── features/
│   │   ├── core/              # Headless-safe base OS, Home Manager wiring, desktop base
│   │   ├── system/            # Display sessions & hardware (mangowm, niri, noctalia, laptop, nvidia, wireguard)
│   │   ├── services/          # Single-purpose services (tailscale, mullvad, ollama, docker, virtualisation, printing)
│   │   └── apps/              # desktopApps, dev (lean), security, gaming, antigravity
│   └── hosts/                 # Per-machine assemblies and _disko.nix layouts
└── .github/workflows/         # CI flake check, host evaluation, and weekly lockfile updates
```

## Quick start

### Existing NixOS host

```bash
sudo nixos-rebuild switch --flake .#laptop
```

### Fresh install with `bootstrap.sh`

```bash
curl -sSL https://raw.githubusercontent.com/lilvirgola/nixconf/main/bootstrap.sh -o bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh --host server --disko
```

See [INSTALL.md](./INSTALL.md) for manual partitioning, Raspberry Pi SD flashing, and custom ISO builds.

## Architecture notes

- **Hybrid Home Manager + `wrapper-modules`:** Home Manager (`nixosModules.home-manager`) manages user dotfiles (`zsh`, `git`, `ssh`, `direnv`, `gtk`, `dconf`, `zathura`, and `~/.config/kitty/*` SSH profiles), while `wrappedPrograms/` wraps `myKitty`, `myMango`, `myNiri`, and `myNoctalia` as standalone binaries without config overlap.
- **Headless vs. graphical split:** `nixos/features/core/base.nix` (`core`) contains only headless-safe OS configuration. PipeWire, fonts, NetworkManager, Polkit, and terminals live in `nixos/features/core/desktop.nix` (`desktop`).
- **CUDA isolation:** `nvidia.nix` sets `custom.enableCuda = true`. Both `ollama.nix` and `desktopApps` (Blender) check this flag so non-Nvidia hosts do not pull CUDA packages.
- **Lean `dev.nix` + `ninit` templates:** Global packages in `dev.nix` stay minimal (`uv`, `python3`, `vscode`, `antigravity`, `docker`, `gcc`, `cmake`). Language-specific toolchains (Rust, Go, LaTeX, Embedded, SDR, CTF) live in `templates/` and load per project via `ninit` and `direnv`.

## Common commands

```bash
# Enter dev shell (also enables .githooks/pre-commit)
nix develop

# Format all Nix files
nix fmt .

# Run formatting, statix, deadnix, and flake evaluation checks
nix flake check

# Build or run QEMU VMs
nix build .#vm
nix run .#vm-minimal

# Deploy remotely over SSH / Tailscale
nix run .#deploy -- server
nix run .#deploy -- raspberrypi virgola@raspberrypi --remote-build

# Build Raspberry Pi 4 SD image (on aarch64-linux or with binfmt)
nix build .#raspberrypi-sd

# Build custom rescue ISO
nix build .#iso
```

## Keybindings (MangoWM)

Press `SUPER + H` to open the searchable `keyhints` menu (`rofi`), or run `keyhints --table` for a persistent `yad` reference window.

| Shortcut | Action |
| :--- | :--- |
| `SUPER + Return` | Open Kitty terminal |
| `SUPER + D` / `SUPER + S` | Toggle Noctalia app launcher |
| `SUPER + B` | Open Firefox |
| `SUPER + E` | Open Thunar |
| `SUPER + Q` | Close active window |
| `SUPER + Space` | Toggle floating |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + N` | Cycle layout (`tile`, `scroller`, `grid`) |
| `SUPER + Shift + S` | Area screenshot with Swappy |
| `SUPER + 1..9` | Switch workspace |
| `SUPER + Shift + 1..9` | Move window to workspace |
| `Ctrl + Alt + L` | Lock screen |
| `Ctrl + Alt + P` | Session / power menu |

## Security and CTF tooling

`nixos/features/apps/security.nix` provides `ghidra`, `ghidra-auto`, `pwndbg`, `pwninit`, `pwninit-ghidra`, `pwntools`, `ropper`, `ropgadget`, `one_gadget`, `seccomp-tools`, `imhex`, `rizin`, `radare2`, `wireshark` (non-root `dumpcap` via the `wireshark` group), `burpsuite`, `sage`, `mtp`, and `tunnelmole`.

Bitwarden SSH helpers (`ssh-vault-add`, `ssh-vault-load`, `ssh-vault-list`) are packaged in `packages/ssh-vault.nix` and load keys into `ssh-agent` without leaving unencrypted private keys on disk.
