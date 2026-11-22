# Host definitions (`nixos/hosts/`)

Each subdirectory under `nixos/hosts/<name>/` defines a `flake.nixosConfigurations.<name>` target.

## Supported hosts

| Host | Arch | Boot / Disk | Included stack |
| :--- | :--- | :--- | :--- |
| `laptop` | `x86_64-linux` | `systemd-boot`, LUKS + Btrfs (`hardware.nix` + `_disko.nix`) | `core`, `desktop`, `mangowm`, `nvidia`, `laptopFeatures`, `wireguard`, `tailscale`, `mullvad`, `ollama`, `virtualisation`, `printing`, `gamingHardware`, `desktopApps`, `dev`, `security`, `gaming`, `vr`, `android` |
| `desktop` | `x86_64-linux` | `systemd-boot`, `disko` Btrfs (`_disko.nix`) | `core`, `desktop`, `mangowm`, `wireguard`, `tailscale`, `printing`, `gamingHardware`, `desktopApps`, `dev`, `gaming`, `vr`, `android` |
| `vm` | `x86_64-linux` | GRUB (`/dev/vda`), `qemu-guest`, SPICE, `_disko.nix` | `core`, `desktop`, `mangowm`, `wireguard`, `desktopApps`, `dev`, `security`, `vscode-server` |
| `vm-minimal` | `x86_64-linux` | GRUB + EFI, `disko` ext4 (`_disko.nix`) | `core`, `homeManagerCore`, `qemuGuest` |
| `server` | `x86_64-linux` | `systemd-boot`, `disko` Btrfs (`_disko.nix`) | `core`, `homeManagerCore`, `docker`, `tailscale`, firewall + hardened SSH |
| `raspberrypi` | `aarch64-linux` | `sd-image-aarch64` + `nixos-hardware` Pi 4 | `core`, `homeManagerCore`, `tailscale`, `docker`, firewall + hardened SSH |
| `iso` | `x86_64-linux` | `installation-cd-minimal` | `core`, `disko`, partitioning/rescue tools |

## Files inside a host directory

- `default.nix`: Declares `flake.nixosConfigurations.<name>` (and optional `perSystem.packages` like `raspberrypi-sd` or `iso`).
- `configuration.nix`: Imports feature modules and sets host-specific overrides (`networking.hostName`, bootloader, firewall).
- `hardware.nix` / `_disko.nix`: Hardware scan or `disko` disk layout. Prefixing `_disko.nix` with `_` prevents `flake.nix` from auto-importing it as a `flake-parts` module.

## Adding a new host

1. Create `nixos/hosts/<name>/default.nix`, `configuration.nix`, and `_disko.nix` (or `hardware.nix`).
2. Stage the new directory with `git add nixos/hosts/<name>`.
3. Verify evaluation with `nix eval .#nixosConfigurations.<name>.config.system.build.toplevel.drvPath`.
4. Add `<name>` to `.github/workflows/check.yml` and `bootstrap.sh`.
