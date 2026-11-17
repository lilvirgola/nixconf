# Feature modules (`nixos/features/`)

Modules under `nixos/features/` are auto-discovered by `flake.nix` and exposed as `flake.nixosModules.<name>`.

## Subdirectories

- `core/`: `base.nix` (`core`, headless-safe OS), `desktop.nix` (`desktop`, audio/fonts/NetworkManager/Polkit/terminals), `home-manager.nix` (`homeManagerCore`, `homeManagerDesktop`).
- `system/`: `mangowm.nix`, `niri.nix`, `noctalia.nix`, `laptop.nix` (`laptopFeatures`), `nvidia.nix`, `wireguard.nix` (also aliased as `vpn`).
- `services/`: `tailscale.nix`, `mullvad.nix`, `ollama.nix`, `docker.nix`, `virtualisation.nix`, `printing.nix`, `gaming-hardware.nix` (`gamingHardware`).
- `apps/`: `desktop.nix` (`desktopApps`), `dev.nix` (`dev`), `security.nix` (`security`), `gaming.nix` (`gaming`), `antigravity.nix` (`antigravity`).

## Conventions

- Keep features independent of specific host hardware so they work across VMs, laptops, desktops, and servers.
- Use `lib.mkDefault` for settings that a host may want to override (such as `services.openssh.enable`).
- Gate GPU/CUDA behavior on `config.custom.enableCuda` rather than assuming Nvidia hardware is present.
- Add required user groups (`docker`, `libvirtd`, `wireshark`) inside the feature module that enables the service, not in `core`.
