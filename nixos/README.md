# `nixos/` — NixOS Configurations & Modular Architecture

Everything specific to **NixOS** lives under this directory, structured according to a clean separation of concerns between reusable feature definitions and concrete machine assemblies.

---

## Architecture Overview

```text
nixos/
├── settings.nix           # Centralized single source of truth for user & regional settings
├── features/              # Composable, reusable NixOS modules
│   ├── system/                # OS plumbing, desktop sessions, shells, networking, power
│   │   ├── base.nix           # Core system, user virgola, nix-ld, fonts, GC & deduplication
│   │   ├── mangowm.nix        # MangoWM Wayland compositor session & autostart
│   │   ├── noctalia.nix       # Noctalia v5 shell & desktop environment
│   │   ├── niri.nix           # Niri scrollable tiling compositor fallback
│   │   ├── wireguard.nix      # WireGuard & Fortinet SSL VPN suite (openfortivpn)
│   │   ├── laptop.nix         # UPower, power-profiles-daemon, lid switch, Blueman
│   │   ├── nvidia.nix         # Proprietary Nvidia drivers & PRIME offload
│   │   └── zsh.nix            # Zsh interactive shell, Starship, power aliases & vault scripts
│   └── apps/                  # Application suites & developer workflows
│       ├── dev.nix            # Python (uv, pip), PHP, JDK 21, VS Code, Docker, LaTeX/LuaTeX
│       ├── security.nix       # Pwn, Web, Reversing, Crypto, Stego (Ghidra, Pwndbg, Sage, MTP)
│       ├── desktop.nix        # Daily desktop tools (Firefox, Thunar, GIMP, VLC, Vesktop, Zathura)
│       └── gaming.nix         # Steam, GameMode, Proton-GE optimizations
└── hosts/                     # Machine entrypoints (flake.nixosConfigurations.<host>)
    ├── vm/                    # QEMU/KVM Virtual Machine (#vm)
    └── laptop/                # Physical Laptop with Nvidia, UEFI & Power (#laptop)
```

---

## 1. The Two-Layer Pattern

### Layer 1: Reusable Features (`features/`)
Each file under `features/system/` or `features/apps/` declares one or more reusable NixOS modules exposed via `flake.nixosModules.<name>`.
- **Pure & Parameter-Free**: Features define *what* a capability requires (packages, systemd services, udev rules, firewall ports, PAM modules) without tying itself to a specific hardware device.
- **Composable**: Any host can pick and choose features simply by importing them in `imports = [ ... ]`.

### Layer 2: Machine Assemblies (`hosts/`)
Each directory under `hosts/<hostname>/` defines a concrete system exposed via `flake.nixosConfigurations.<hostname>`.
- A host imports the specific feature modules it requires.
- It sets machine-specific attributes:
  - `networking.hostName = "<hostname>";`
  - Bootloader selection (`boot.loader.grub` for VM, `boot.loader.systemd-boot` for Laptop)
  - Generated hardware scan (`hardware.nix`)
  - Machine-specific overrides (such as `services.openssh.enable = false;` on laptop)

---

## 2. Core System Defaults (`settings.nix` & `base.nix`)

All hosts import `self.nixosModules.base`, which sources centralized user and regional settings from `nixos/settings.nix`:
- **Primary User**: Configured via `config.custom.username` (defaults to `virgola` / Alessandro), member of `wheel`, `networkmanager`, `docker`, `wireshark`, `video`, `audio`.
- **Storage Hygiene**:
  - Weekly automated garbage collection (`nix.gc` with `--delete-older-than 7d`).
  - Weekly store deduplication (`nix.optimise`) and live store deduplication (`auto-optimise-store = true`).
  - Low-disk guards: Automatic GC triggered if free space drops below 5 GiB, targeting 10 GiB free.
  - Bootloader generation limits: Capped at the last 10 generations on both GRUB and systemd-boot.
- **Font Stack**: System-wide `Noto Color Emoji`, `Noto Sans CJK`, and `JetBrains Mono Nerd Font` with explicit fontconfig fallbacks to guarantee zero missing glyphs across terminals, browsers, Noctalia bar, and Discord.
- **Desktop Plumbing**: Polkit authorization daemon (`security.polkit.enable = true`), GNOME Keyring with PAM auto-unlock on login/SDDM, and GVFS for automounting and Thunar trash support.
- **Dynamic Binary Compatibility**: `programs.nix-ld.enable = true` configured with glib, openssl, zlib, libGL, and C++ runtimes so prebuilt binaries (uv wheels, foreign tools) execute natively without manual patchelf.

---

## 3. Host Rebuild & Management Commands

Apply or test changes directly from the repository root:

```bash
# 1. Switch active system configuration:
sudo nixos-rebuild switch --flake .#vm      # On VM
sudo nixos-rebuild switch --flake .#laptop  # On Laptop

# 2. Test configuration without creating a boot entry:
sudo nixos-rebuild test --flake .#laptop

# 3. Build toplevel derivation without applying (dry run check):
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link

# 4. Roll back to the previous generation:
sudo nixos-rebuild switch --rollback
```
