# NixOS configuration structure in nixos/

Configurations specific to NixOS live in this directory, separated into reusable feature modules and host assemblies.

## Directory layout

```text
nixos/
├── settings.nix           # User and regional defaults
├── features/              # Reusable NixOS modules
│   ├── system/            # OS foundation, desktop sessions, shells, networking, power
│   │   ├── base.nix       # Base system, user virgola, nix-ld, fonts, GC and deduplication
│   │   ├── mangowm.nix    # MangoWM Wayland session and autostart
│   │   ├── noctalia.nix   # Noctalia v5 shell
│   │   ├── niri.nix       # Niri scrollable tiling compositor fallback
│   │   ├── wireguard.nix  # WireGuard and Fortinet SSL VPN suite (openfortivpn)
│   │   ├── laptop.nix     # UPower, power-profiles-daemon, lid switch, Blueman
│   │   ├── nvidia.nix     # Nvidia drivers and PRIME offload
│   │   └── zsh.nix        # Zsh shell, Starship prompt, aliases, vault scripts
│   └── apps/              # Application suites and developer stacks
│       ├── dev.nix        # Python (uv, pip), PHP, JDK 21, VS Code, Docker, LaTeX/LuaTeX
│       ├── security.nix   # Pwn, web, reversing, crypto, stego (Ghidra, Pwndbg, Sage, MTP)
│       ├── desktop.nix    # Desktop tools (Firefox, Thunar, GIMP, VLC, Vesktop, Zathura)
│       └── gaming.nix     # Steam, GameMode, Proton-GE optimizations
└── hosts/                 # Machine definitions (flake.nixosConfigurations.<host>)
    ├── vm/                # QEMU/KVM virtual machine (#vm)
    └── laptop/            # Laptop with Nvidia, UEFI, and power profiles (#laptop)
```

## Module organization

### Reusable features (features/)
Files under `features/system/` and `features/apps/` define modules exposed through `flake.nixosModules.<name>`.
- Features define packages, services, udev rules, firewall ports, and PAM modules independently of specific hardware.
- Hosts import the features they need through `imports = [ ... ]`.

### Machine assemblies (hosts/)
Directories under `hosts/<hostname>/` define concrete systems exposed through `flake.nixosConfigurations.<hostname>`.
- A host imports required feature modules.
- Sets machine attributes:
  - `networking.hostName = "<hostname>";`
  - Bootloader configuration (`boot.loader.grub` for VM, `boot.loader.systemd-boot` for laptop)
  - Hardware scan (`hardware.nix`)
  - Host overrides (such as disabling OpenSSH on the laptop)

## System defaults (settings.nix and base.nix)

Hosts import `self.nixosModules.base`, which reads defaults from `nixos/settings.nix`:
- Primary user: set through `config.custom.username` (defaults to `virgola`), with membership in `wheel`, `networkmanager`, `docker`, `wireshark`, `video`, and `audio`.
- Storage maintenance:
  - Weekly garbage collection (`nix.gc` with `--delete-older-than 7d`).
  - Weekly store deduplication (`nix.optimise`) and continuous deduplication (`auto-optimise-store = true`).
  - Low-disk protection: runs garbage collection when free space drops below 5 GiB, aiming for 10 GiB free.
  - Bootloader limits: keeps the last 10 generations in GRUB and systemd-boot.
- Fonts: `Noto Color Emoji`, `Noto Sans CJK`, and `JetBrains Mono Nerd Font` with fontconfig fallbacks across terminals, browsers, Noctalia, and Discord.
- Desktop services: Polkit agent (`security.polkit.enable = true`), GNOME Keyring with PAM unlock, and GVFS for automounting and trash support.
- Prebuilt binary compatibility: `programs.nix-ld.enable = true` configured with glib, OpenSSL, zlib, libGL, and C++ runtimes so prebuilt binaries run without manual patching.

## Rebuild and management commands

```bash
# Apply configuration:
sudo nixos-rebuild switch --flake .#vm      # On VM
sudo nixos-rebuild switch --flake .#laptop  # On laptop

# Test configuration without adding a boot entry:
sudo nixos-rebuild test --flake .#laptop

# Build system derivation without switching:
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link

# Roll back to the previous generation:
sudo nixos-rebuild switch --rollback
```
