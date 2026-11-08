# Virgola's NixOS desktop and security suite

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Architecture](https://img.shields.io/badge/Architecture-Dendritic%20Flake--Parts-7c5295.svg)](https://flake.parts)
[![Compositor](https://img.shields.io/badge/Compositor-MangoWM%20(Wayland)-orange.svg)](https://github.com/BirdeeHub/nix-wrapper-modules)
[![Shell](https://img.shields.io/badge/Shell-Noctalia%20v5-purple.svg)](https://github.com/BirdeeHub/nix-wrapper-modules)
[![Theme](https://img.shields.io/badge/Palette-Catppuccin%20Mocha-f5c2e7.svg)](https://github.com/catppuccin/catppuccin)
[![Formatter](https://img.shields.io/badge/Formatter-Alejandra-brightgreen.svg)](https://github.com/kamadorueda/alejandra)

A modular multi-host NixOS configuration built with `flake-parts`, wrapped applications from `nix-wrapper-modules`, and tools for software engineering, reverse engineering, and academic work.

## Machine onboarding

To provision a fresh physical machine or VM, run the onboarding script:

```bash
curl -sSL https://raw.githubusercontent.com/lilvirgola/nixconf/main/bootstrap.sh -o bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh
```

The script:
1. Generates `hardware.nix` with `nixos-generate-config`.
2. Backs up any existing hardware configuration.
3. Prompts for the `virgola` user password.
4. Checks flake formatting and evaluation.
5. Rebuilds the system with `sudo nixos-rebuild switch --flake .#<host>`.

## Repository architecture

Every `.nix` file is an independent module imported through recursive discovery in `flake.nix`, excluding files prefixed with `_` and files in `templates/`.

```text
nixconf/
├── flake.nix                  # Flake entrypoint and recursive module discovery
├── bootstrap.sh               # Hardware detection and onboarding script
├── lib/                       # Supported systems, Alejandra formatter, templates list
├── wrappedPrograms/           # Standalone wrapped apps (MangoWM, Noctalia, Niri)
├── packages/                  # Custom flake packages (ninit, keyhints, mtp, tunnelmole, kssh)
├── templates/                 # 26 project templates (systems, web, docs, CTF)
├── nixos/
│   ├── settings.nix           # User and regional defaults
│   ├── features/              # Composable NixOS modules
│   │   ├── system/            # Base OS, desktop sessions, VPNs, power, audio, Nvidia, Ollama
│   │   └── apps/              # Desktop apps, developer stacks, security suite, gaming
│   └── hosts/                 # Machine configurations
│       ├── laptop/            # Laptop with UEFI, Nvidia, Blueman (#laptop)
│       └── vm/                # Virtual machine with GRUB, QEMU/SPICE (#vm)
└── .github/                   # CI verification and Dependabot updates
```

Each subdirectory has a `README.md` covering its internal structure.

## Desktop environment: MangoWM and Noctalia v5

- Wayland compositor: MangoWM (`mangowc`) with dynamic tiling (master/stack, grid, scroller), floating mode, and multi-monitor workspace switching.
- Desktop shell: Noctalia v5 with a floating top bar, resource graphs, audio controls, network menu, battery indicators, and notification center.
- Styling: Catppuccin Mocha colors across SDDM, Kitty, Rofi, YAD, and GTK apps.
- Background services:
  - `polkit-gnome`: GTK authentication agent.
  - `wl-clip-persist`: Keeps clipboard contents after closing windows.
  - `swayidle`: Locks the screen with Noctalia after 15 minutes (`900s`), suspends after 30 minutes (`1800s`), and locks before system sleep.

## Keybindings cheatsheet (SUPER + H)

Press `SUPER + H` to open the `keyhints` menu:

- Search modal (`rofi`): Filter keybindings by category, shortcut, or description. Pressing `Enter` on an application row launches it directly.
- Table view (`yad`): Run `keyhints --table` or select the table entry to keep a 3-column reference window open.

### Common keybindings

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + H` | Keybindings cheatsheet | Opens searchable keyhints modal |
| `SUPER + Return` | Terminal | Opens Kitty terminal emulator |
| `SUPER + B` | Web browser | Opens Firefox |
| `SUPER + E` | File manager | Opens Thunar file manager |
| `SUPER + Space` | Toggle floating | Switches window between floating and tiled |
| `SUPER + ALT + Space` | Float all | Floats all windows on current workspace |
| `SUPER + F` | Fullscreen | Toggles fullscreen mode |
| `SUPER + N` | Cycle layout | Switches layout between tile, scroller, and grid |
| `SUPER + Shift + S` | Screenshot | Area screenshot with Swappy editor |
| `SUPER + 1..9` | Workspaces | Switch to workspace 1 to 9 |
| `SUPER + Shift + 1..9`| Move window | Move active window to workspace 1 to 9 |
| `SUPER + U` | Scratchpad | Toggles dropdown scratchpad |
| `Ctrl + Alt + L` | Lock screen | Locks session with Noctalia |
| `Ctrl + Alt + P` | Power menu | Opens power, suspend, and reboot dialog |

## Security, reverse engineering, and CTF suite

### Binary exploitation and debugging
- GDB with `pwndbg` integration.
- `pwninit`, `pwninit-ghidra`, and `pwntools`.
- ROP tools: `ropper`, `ropgadget`, and `one_gadget`.
- Binary utilities: `seccomp-tools`, `checksec`, `patchelf`, `elfutils` (`eu-readelf`, `eu-elfcmp`), `ltrace`, `strace`, `file`, `xxd`.

### Reverse engineering and hex inspection
- Ghidra with JDK 21 and headless scripts (`ghidra-auto`).
- Disassemblers and analyzers: `ht`, `rizin`, `radare2`, `imhex`.

### Cryptography and mathematics
- SageMath: `sage` binary package from Nixpkgs cache.
- Python libraries: `pycryptodome`, `gmpy2`, `sympy`, `z3-solver`.
- MTP: Interactive Many-Time Pad XOR cryptanalysis tool (`packages/mtp.nix`).

### Network and web security
- Wireshark and Tshark: Packet capture with non-root dumpcap permissions for user `virgola`, plus `pyshark`.
- Forensics and carving: `binwalk`, `stegsolve`, `john`.
- Web tools: `burpsuite`, `postman`, `ngrok`, `gobuster`, `nmap`.
- Tunnelmole (`tmole`): Open-source reverse tunnel (`packages/tunnelmole.nix`).

## User and system identity (nixos/settings.nix)

User identity and preferences live in [`nixos/settings.nix`](./nixos/settings.nix):

```nix
options.custom = {
  username = "virgola";           # Login name across modules, sudoers, and configs
  userDescription = "Alessandro"; # Full GECOS name
  initialPassword = "nixos";      # Default password for fresh installs
  timezone = "Europe/Rome";       # System timezone
  locale = "en_US.UTF-8";         # Primary locale
  extraLocale = "it_IT.UTF-8";    # Currency, time, and numeric formatting
  keyboardLayout = "it";          # Wayland and X11 keyboard layout
  consoleKeyMap = "it2";          # Linux console TTY keymap

  theme = {
    colorScheme = "dark";         # Dark mode preference
    gtkTheme = "adw-gtk3-dark";   # GTK 3/4 theme
    iconTheme = "Papirus-Dark";   # Icon theme
    cursorTheme = "Bibata-Modern-Classic"; # Cursor theme
    cursorSize = 24;              # Cursor size in pixels
  };
};
```

Updating these options configures:
- User creation and group membership (`wheel`, `networkmanager`, `docker`, `wireshark`, `video`).
- Default shell (`zsh`).
- Ollama service controls in sudoers.
- GTK 3 and GTK 4 configurations (`/etc/xdg/gtk-*/settings.ini`), dconf databases, and environment variables (`GTK_THEME`, `XCURSOR_THEME`, `XCURSOR_SIZE`).

## Project templates (ninit)

Initialize project templates through `ninit`:

```bash
# Interactive menu:
ninit

# Or pass a template directly:
ninit rust my-crate          # Rust with Cargo, rust-analyzer, clippy
ninit py my-fastapi          # Python with uv, ruff, pyright
ninit ts my-app              # TypeScript and Node 22 with pnpm and Biome
ninit cpp my-engine          # C++ with Clang, CMake, Ninja, GDB
ninit pio my-firmware        # Embedded microcontroller with PlatformIO
ninit php my-api             # PHP 8.5 with Composer
ninit ctf-pwn my-pwn         # CTF binary exploitation with Pwntools, Ropper, GDB
ninit go my-service          # Go with gopls, golangci-lint, delve
ninit latex my-thesis        # LaTeX with Tectonic, SyncTeX, Texlab
```

Run `ninit --list` to inspect all 26 available templates, aliases, and starter commands.

## In-memory SSH key management

Manage SSH keys in memory through Bitwarden or Vaultwarden:

```bash
# Upload an SSH key to Bitwarden or Vaultwarden:
ssh-vault-add                        # Uploads ~/.ssh/id_ed25519 as 'id_ed25519'
ssh-vault-add ~/.ssh/id_work work    # Uploads ~/.ssh/id_work as 'work'
ssh-vault-add -g my_new_key          # Generates ~/.ssh/my_new_key and uploads it

# List keys stored in vault:
ssh-vault-list

# Load key into ssh-agent memory:
ssh-vault-load id_ed25519
```

## VPN setup

WireGuard and Fortinet SSL VPNs are supported:

```bash
# WireGuard via NetworkManager:
nmcli connection import type wireguard file ~/my-vpn.conf
nmcli connection up my-vpn
nmcli connection down my-vpn

# Fortinet SSL VPN via OpenFortiVPN CLI:
sudo openfortivpn -c /etc/openfortivpn/config.example
```

You can also configure connections through `nm-connection-editor` with the `networkmanager-openconnect` plugin.

## System maintenance

- Weekly garbage collection: removes store derivations older than 7 days (`nix.gc`).
- Store optimization: hardlinks duplicate files (`nix.optimise`).
- Low-disk protection: prevents builds from exhausting disk space with `min-free = 5 GiB` and `max-free = 10 GiB`.
- Boot entries: keeps the last 10 generations in GRUB and systemd-boot.

## Common commands

```bash
# Rebuild system:
sudo nixos-rebuild switch --flake .#vm      # On VM
sudo nixos-rebuild switch --flake .#laptop  # On laptop

# Format Nix files with Alejandra:
nix fmt .

# Run flake validation:
nix flake check .

# Roll back to previous generation:
sudo nixos-rebuild switch --rollback
```

## License

Maintained by Alessandro De Biasi ([@lilvirgola](https://github.com/lilvirgola)) under the MIT License.
