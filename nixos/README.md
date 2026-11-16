# NixOS configurations (`nixos/`)

This directory holds shared system settings, composable feature modules, and concrete host definitions.

## Layout

```text
nixos/
├── settings.nix               # custom.* options (user, SSH keys, locale, theme, enableCuda)
├── features/
│   ├── core/
│   │   ├── base.nix           # Headless-safe core OS (nix, zram, zsh, ssh, nix-ld, envfs)
│   │   ├── desktop.nix        # Graphical base (PipeWire, fonts, NetworkManager, Polkit, terminals)
│   │   └── home-manager.nix   # Wires home/core.nix and home/desktop.nix via HM NixOS module
│   ├── system/                # Display sessions & hardware (mangowm, niri, noctalia, laptop, nvidia, wireguard)
│   ├── services/              # Single-purpose services (tailscale, mullvad, ollama, docker, virtualisation, printing, gaming-hardware)
│   └── apps/                  # Application suites (desktopApps, dev, security, gaming, antigravity)
└── hosts/                     # Flake targets (laptop, desktop, vm, vm-minimal, server, raspberrypi, iso)
```

## How composition works

1. Every host imports `self.nixosModules.core`, which pulls in `nixos/settings.nix` and configures Nix GC/optimise, ZRAM, timezone/locale, `zsh`, hardened `openssh`, `nix-ld`, and `envfs`.
2. Installed hosts import `self.nixosModules.homeManagerCore` (or `self.nixosModules.desktop`, which imports `homeManagerDesktop`) so user dotfiles under `home/` stay in sync with `nixos/settings.nix`.
3. Services and hardware modules are opt-in per host. Features add their own required user groups (for example `docker`, `libvirtd`, `wireshark`) rather than hardcoding all groups in `core`.

## Common commands

```bash
# Apply configuration on the current host
sudo nixos-rebuild switch --flake .#laptop

# Test without adding a boot entry
sudo nixos-rebuild test --flake .#laptop

# Evaluate a host without building
nix eval .#nixosConfigurations.server.config.system.build.toplevel.drvPath

# Roll back to the previous generation
sudo nixos-rebuild switch --rollback
```
