# System and hardware modules in nixos/features/system/

This directory contains system-level modules exposed under `flake.nixosModules.<name>` for core OS plumbing, display managers, Wayland compositors, desktop shells, VPN connections, power management, and hardware drivers.

## Modules

### 1. base.nix (flake.nixosModules.base)
Base configuration imported by every host:
- User setup: configures user `virgola` with membership in `wheel`, `networkmanager`, `docker`, `wireshark`, `video`, and `audio`.
- Storage maintenance:
  - Weekly garbage collection (`nix.gc.automatic = true; options = "--delete-older-than 7d"`).
  - Weekly hardlink deduplication (`nix.optimise.automatic = true`) and continuous deduplication (`nix.settings.auto-optimise-store = true`).
  - Low-disk protection (`min-free = 5 GiB`, `max-free = 10 GiB`).
- Fonts and glyphs: installs `noto-fonts`, `noto-fonts-cjk-sans`, and `noto-fonts-color-emoji` with fontconfig fallback rules across monospace, sans-serif, and serif font families.
- Desktop plumbing: Polkit privilege escalation, GNOME Keyring with PAM unlock, and disabled `gcr-ssh-agent` to avoid conflicts with `programs.ssh.startAgent`.
- Prebuilt binary compatibility (`nix-ld`): enables running unpatched Linux binaries and precompiled Python wheels through `stdenv.cc.cc`, `zlib`, `openssl`, `glib`, and `libGL`.
- CLI utilities: `git`, `gh`, `curl`, `wget`, `kitty`, `btop`, `fastfetch`, `ripgrep`, `fd`, `fzf`, `jq`, `bitwarden-cli`, `rbw`, `ninit`, `keyhints`, and `kssh`.

### 2. mangowm.nix (flake.nixosModules.mangowm)
Desktop session configuration:
- Display manager: SDDM under Wayland with Catppuccin Mocha theme.
- Session: registers `mangowc` in `/run/current-system/sw/share/wayland-sessions`.
- Background daemons: Noctalia floating bar, `polkit-gnome`, `wl-clip-persist`, and `swayidle` (locks after 15 minutes, suspends after 30 minutes, locks before sleep).
- Keybindings: binds shortcuts for `keyhints`, Kitty, Firefox, Thunar, window management, tiling layouts, and session controls.

### 3. noctalia.nix (flake.nixosModules.noctalia)
Noctalia shell configuration:
- Bar: floating top bar with Catppuccin Mocha styling.
- Widgets: clock, system monitors (CPU, memory, storage), audio volume sliders, network menu, battery indicators, and application launcher.
- System services: D-Bus, UPower, `power-profiles-daemon`, and Wayland clipboard tools (`wl-clipboard`, `cliphist`).

### 4. wireguard.nix (flake.nixosModules.wireguard)
VPN and network configuration:
- WireGuard: `wireguard-tools` and NetworkManager WireGuard connection plugins.
- Fortinet SSL VPN: `openfortivpn` CLI, `openconnect`, and the `networkmanager-openconnect` plugin. Example configuration at `/etc/openfortivpn/config.example`.
- Firewall: sets `networking.firewall.checkReversePath = "loose"` so multi-homed VPN tunnels keep reverse-path traffic.

### 5. laptop.nix (flake.nixosModules.laptopFeatures)
Hardware and power features for laptops:
- Bluetooth: BlueZ with `powerOnBoot = true` and `services.blueman.enable = true`.
- Power management: UPower, `power-profiles-daemon`, and lid switch rules that suspend on close unless docked to an external display.
- Hardware utilities: `brightnessctl`, `acpi`, and `linux-firmware`.

### 6. nvidia.nix (flake.nixosModules.nvidia)
Nvidia graphics configuration:
- Proprietary kernel drivers (`videoDrivers = [ "nvidia" ]`).
- Power management and suspend/resume hooks.
- PRIME offload template for hybrid GPU setups.

### 7. zsh.nix (flake.nixosModules.zsh)
Interactive shell configuration:
- Zsh with Oh-My-Zsh, `agnosterzak` theme, syntax highlighting, and autosuggestions.
- Bitwarden SSH helpers: `ssh-vault-add`, `ssh-vault-load`, and `ssh-vault-list`.
- Aliases: `keyhints`, `ninit`, `kssh`, `openfortivpn`, `lsd`, `btop`, `fastfetch`.
