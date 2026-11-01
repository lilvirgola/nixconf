# `nixos/features/` — Reusable NixOS Feature Modules

## What Goes Here?

Every `.nix` file under `nixos/features/` defines one or more reusable NixOS modules under `flake.nixosModules.<name>`.

### Subdirectories
- **[`system/`](./system/)**: Core OS configuration, compositors/desktops, audio, networking, power management, and hardware/GPU drivers.
- **[`apps/`](./apps/)**: User-facing application suites (e.g., gaming/Steam, development environments, media tools).

