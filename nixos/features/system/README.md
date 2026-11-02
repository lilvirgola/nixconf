# `nixos/features/system/` — System & Hardware Feature Modules

This directory contains system-level NixOS modules (`flake.nixosModules.<name>`) responsible for core OS plumbing, display managers, Wayland compositors, desktop shells, VPN/networking, power management, and hardware drivers.

---

## Module Index

### 1. `base.nix` (`flake.nixosModules.base`)
The essential foundation imported by every machine:
- **User Setup**: Configures user `virgola` with groups `wheel`, `networkmanager`, `docker`, `wireshark`, `video`, `audio`.
- **Automated Storage Hygiene**:
  - Weekly garbage collection (`nix.gc.automatic = true; options = "--delete-older-than 7d"`).
  - Weekly hardlink deduplication (`nix.optimise.automatic = true`) and live optimization (`nix.settings.auto-optimise-store = true`).
  - Low-disk space protection (`min-free = 5 GiB`, `max-free = 10 GiB`).
- **Typography & Glyph Support**:
  - Installs `noto-fonts`, `noto-fonts-cjk-sans`, and `noto-fonts-color-emoji`.
  - Configures fontconfig fallbacks linking `Noto Color Emoji` into monospace, sans-serif, and serif font stacks to eliminate missing glyph boxes across Noctalia bar, terminals, Firefox, and Discord.
- **Desktop Plumbing**:
  - `security.polkit.enable = true` for privilege escalation.
  - `services.gnome.gnome-keyring.enable = true` with PAM auto-unlock on login and SDDM.
  - `services.gnome.gcr-ssh-agent.enable = false` to avoid conflicts with native `programs.ssh.startAgent`.
- **Dynamic Binary Compatibility (`nix-ld`)**:
  - Enables running unpatched Linux binaries, Node.js pkg executables, and precompiled Python wheels out-of-the-box with `stdenv.cc.cc`, `zlib`, `openssl`, `glib`, `libGL`, `sqlite`, etc.
- **Base Power Tools**: Installs `git`, `gh`, `curl`, `wget`, `kitty`, `btop`, `fastfetch`, `ripgrep`, `fd`, `fzf`, `jq`, `bitwarden-cli`, `rbw`, `ninit`, and `keyhints`.

---

### 2. `mangowm.nix` (`flake.nixosModules.mangowm`)
Configures the primary desktop environment:
- **Display Manager**: SDDM enabled under Wayland with the modern Catppuccin Mocha theme.
- **Session**: Registers `mangowc` as a native Wayland session in `/run/current-system/sw/share/wayland-sessions`.
- **Autostart Daemons**:
  - `myNoctalia`: Noctalia v5 floating bar & widgets.
  - `polkit-gnome`: Graphical authentication prompt agent.
  - `wl-clip-persist --clipboard both`: Preserves clipboard contents when source windows are closed.
  - `swayidle`: Automatically locks the screen after 15 minutes (`900s`), suspends the machine after 30 minutes (`1800s`), and locks before system sleep.
- **Keybindings**: Binds `SUPER + H` to `keyhints`, `SUPER + Enter` to Kitty, `SUPER + B` to Firefox, `SUPER + E` to Thunar, window management, tiling layouts, and session controls.

---

### 3. `noctalia.nix` (`flake.nixosModules.noctalia`)
Configures the Noctalia v5 shell:
- **Bar Configuration**: Configured as an elegant floating bar with padding, rounded corners, and Catppuccin Mocha theme.
- **Widgets**: Date/time, system monitors (CPU, memory, storage), audio volume sliders, network status, battery indicator, and application launcher.
- **System Services**: Enables D-Bus, UPower, `power-profiles-daemon`, GTK launch integration, and Wayland clipboard protocols (`wl-clipboard`, `cliphist`).

---

### 4. `wireguard.nix` (`flake.nixosModules.wireguard`)
Complete secure networking and VPN suite:
- **WireGuard**: Installs `wireguard-tools` and enables NetworkManager WireGuard connection plugins.
- **OpenFortiVPN & Fortinet SSL VPN**:
  - Installs `openfortivpn` CLI tool for PPP+SSL FortiGate tunnels.
  - Installs `openconnect` and enables the `networkmanager-openconnect` plugin.
  - Generates template config `/etc/openfortivpn/config.example`.
- **Firewall**: Sets `networking.firewall.checkReversePath = "loose"` so multi-homed VPN tunnels don't drop reverse-path traffic.

---

### 5. `laptop.nix` (`flake.nixosModules.laptopFeatures`)
Hardware and power features tailored for mobile workstations:
- **Bluetooth**: Enables BlueZ with `powerOnBoot = true` and `services.blueman.enable = true` for graphical device pairing and audio routing.
- **Power Management**:
  - `services.upower.enable = true`
  - `services.power-profiles-daemon.enable = true` (Balanced, Performance, Power Saver modes)
  - `services.logind.settings.Login`: Suspends on lid close, ignores lid close when connected to a display dock.
- **Backlight & Hardware**: Installs `brightnessctl`, `acpi`, and `linux-firmware`.

---

### 6. `nvidia.nix` (`flake.nixosModules.nvidia`)
Dedicated graphics drivers for Nvidia GPUs:
- **Drivers**: Proprietary Nvidia kernel drivers (`videoDrivers = [ "nvidia" ]`).
- **Power Management**: Experimental power management and suspend/resume hooks enabled.
- **PRIME Offload**: Configured template for hybrid Intel/AMD + Nvidia graphics offloading.

---

### 7. `zsh.nix` (`flake.nixosModules.zsh`)
Interactive command line experience:
- **Framework**: Oh-My-Zsh with `agnosterzak` theme, fast syntax highlighting, and autosuggestions.
- **Vaultwarden / Bitwarden SSH Integration**:
  - `ssh-vault-add`: Uploads or generates SSH keys into Bitwarden vault.
  - `ssh-vault-load`: Loads vault keys into in-memory `ssh-agent` without storing private keys on disk.
  - `ssh-vault-list`: Lists all SSH keys saved in vault.
- **Helpful Aliases**: `keyhints`, `ninit`, `openfortivpn = "sudo openfortivpn"`, `lsd`, `btop`, `fastfetch`.
