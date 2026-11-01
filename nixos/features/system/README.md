# `nixos/features/system/` — System & Hardware Feature Modules

## What Goes Here?

System-level NixOS modules (`flake.nixosModules.<name>`) covering OS basics, display managers, Wayland compositors, desktop shells, power management, and hardware drivers.

### Current Modules
- [`base.nix`](./base.nix) (`flake.nixosModules.base`): Locale (`Europe/Rome`, Italian keymap), PipeWire audio, user `virgola`, OpenSSH, `nix-ld`, and core CLI/terminal tools.
- [`noctalia.nix`](./noctalia.nix) (`flake.nixosModules.noctalia`): Installs `myNoctalia` and enables D-Bus, UPower, `power-profiles-daemon`, `gtk3` (`gtk-launch`), `xdg-utils`, and clipboard tools.
- [`mangowm.nix`](./mangowm.nix) (`flake.nixosModules.mangowm`): Imports `noctalia`, enables SDDM (Wayland), and enables `programs.mango` with the wrapped `myMango` package.
- [`niri.nix`](./niri.nix) (`flake.nixosModules.niri`): Optional Niri compositor module (also paired with `noctalia` and SDDM).
- [`laptop.nix`](./laptop.nix) (`flake.nixosModules.laptopFeatures`): Redistributable firmware, Bluetooth, UPower, `power-profiles-daemon`, `brightnessctl`, and `acpi`.
- [`nvidia.nix`](./nvidia.nix) (`flake.nixosModules.nvidia`): Nvidia GPU drivers, modesetting, power management, and optional Optimus PRIME template.

