# System and hardware modules (`nixos/features/system/`)

This directory holds display session, VPN, and laptop/GPU hardware modules exposed as `flake.nixosModules.<name>`. Headless base OS settings live in `nixos/features/core/`.

## Modules

### `mangowm.nix` (`flake.nixosModules.mangowm`)
- Display manager: SDDM running on X11 (`services.xserver.enable = true`, `wayland.enable = false`) with `sddm-astronaut-theme` so multi-monitor setups render across all connected displays before login.
- Session: `myMango` Wayland compositor (`programs.mango`), `rofi`, and `xdg.portal.wlr` screencast support with `slurp`.

### `niri.nix` (`flake.nixosModules.niri`)
- Scrollable-tiling Wayland compositor fallback (`myNiri`) with SDDM and `noctalia`.

### `noctalia.nix` (`flake.nixosModules.noctalia`)
- Installs `myNoctalia`, `gtk3`, `xdg-utils`, `wl-clipboard`, `cliphist`, and `pwvucontrol`.
- Enables D-Bus, UPower, and `power-profiles-daemon`.

### `wireguard.nix` (`flake.nixosModules.wireguard`, alias `vpn`)
- Installs `wireguard-tools`, `openfortivpn`, `openconnect`, `networkmanagerapplet`, and `zenity`.
- Enables NetworkManager OpenConnect and OpenVPN plugins, sets `networking.firewall.checkReversePath = "loose"`, adds a passwordless sudo rule for `openfortivpn`, and writes `/etc/openfortivpn/config.example`.

### `laptop.nix` (`flake.nixosModules.laptopFeatures`)
- Hardware firmware (`enableRedistributableFirmware`) and AMD CPU microcode updates.
- MediaTek MT7921 Bluetooth resume reset service (`mt7921-bt-resume`), BlueZ, and `blueman`.
- Fingerprint daemon (`fprintd`), Logitech wireless (`solaar`), Btrfs/NTFS filesystem support, and logind lid-switch suspend (`HandleLidSwitchDocked = "ignore"`).
- Installs `acpi`.

### `nvidia.nix` (`flake.nixosModules.nvidia`)
- Proprietary open kernel drivers (`hardware.nvidia.open = true`) with PRIME offload (`PCI:5:0:0` AMD iGPU and `PCI:1:0:0` Nvidia dGPU).
- Sets `custom.enableCuda = true` so `ollama`, `blender`, and `wivrn` enable CUDA support on this host.
- Installs `mesa-demos` (`glxinfo`) and `nvidia-vaapi-driver` (`libva-utils`), providing `nvidia-offload`.
