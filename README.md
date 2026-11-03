# Virgola's NixOS Desktop & Security Suite

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Architecture](https://img.shields.io/badge/Architecture-Dendritic%20Flake--Parts-7c5295.svg)](https://flake.parts)
[![Compositor](https://img.shields.io/badge/Compositor-MangoWM%20(Wayland)-orange.svg)](https://github.com/BirdeeHub/nix-wrapper-modules)
[![Shell](https://img.shields.io/badge/Shell-Noctalia%20v5-purple.svg)](https://github.com/BirdeeHub/nix-wrapper-modules)
[![Theme](https://img.shields.io/badge/Palette-Catppuccin%20Mocha-f5c2e7.svg)](https://github.com/catppuccin/catppuccin)
[![Formatter](https://img.shields.io/badge/Formatter-Alejandra-brightgreen.svg)](https://github.com/kamadorueda/alejandra)

A modular, multi-host NixOS configuration built with the **Dendritic Pattern** (`flake-parts`), hermetic application wrappers (`nix-wrapper-modules`), and a complete engineering, security, and academic research workstation suite.

---

## ⚡ Quickstart & Automated Machine Onboarding

To provision a fresh physical laptop or virtual machine, run the interactive bootstrapper:

```bash
# Download and execute the bootstrapper:
curl -sSL https://raw.githubusercontent.com/lilvirgola/nixconf/main/bootstrap.sh -o bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh
```

The script will:
1. Probe hardware and generate a clean `hardware.nix` via `nixos-generate-config`.
2. Automatically back up any prior hardware scans.
3. Prompt to set user passwords for `virgola`.
4. Validate flake formatting and evaluation.
5. Rebuild and activate the system with `sudo nixos-rebuild switch --flake .#<host>`.

---

## 🏛️ Architecture: The Dendritic Flake-Parts Pattern

In this repository, **every `.nix` file is a self-contained module** (except `flake.nix` itself, files prefixed with `_`, and standalone project files in `templates/`).
`flake.nix` uses recursive filesystem discovery to automatically import every module in the directory tree—eliminating central import lists and manual merge conflicts.

```text
nixconf/
├── flake.nix                  # Flake entrypoint & recursive module discovery engine
├── bootstrap.sh               # Automated hardware generation & onboarding script
├── lib/                       # Flake infrastructure: supported systems, Alejandra formatter, checks
├── wrappedPrograms/           # Standalone wrapped applications (MangoWM, Noctalia, Niri)
├── packages/                  # Custom flake packages (ninit, keyhints, mtp, tunnelmole)
├── templates/                 # 9 Project templates (Python, TypeScript, C/C++, Embedded, PHP, Pwn, Go, Rust, LaTeX)
├── nixos/
│   ├── settings.nix           # Centralized single source of truth for user & regional settings
│   ├── features/              # Composable NixOS capability modules
│   │   ├── system/            # Base OS, desktop sessions, VPNs, power, audio, Nvidia, Ollama
│   │   └── apps/              # Daily desktop, developer stacks, security suite, gaming
│   └── hosts/                 # Machine assemblies
│       ├── laptop/            # Physical Laptop with UEFI, Nvidia, Blueman, SSH disabled (#laptop)
│       └── vm/                # Virtual Machine with GRUB, QEMU/SPICE, SSH enabled (#vm)
└── .github/                   # Automated CI verification and Dependabot updates
```

Each subdirectory contains its own dedicated [`README.md`](./nixos/README.md) detailing its architecture and module definitions.

---

## 🖥️ Desktop Experience: MangoWM + Noctalia v5

- **Wayland Compositor**: **MangoWM** (`mangowc`), featuring dynamic tiling (master/stack, grid, scroller), full floating toggles, and multi-monitor workspace management.
- **Desktop Shell**: **Noctalia v5** configured as an elegant floating bar with rounded margins, system resource monitors, audio sliders, network management, battery gauges, and notification center.
- **Theme**: Catppuccin Mocha aesthetic across SDDM, Kitty, Rofi, YAD, and GTK applications.
- **Autostart Daemons**:
  - `polkit-gnome`: Native GTK authentication modal for privileged operations.
  - `wl-clip-persist`: Keeps copied clipboard text alive even after closing the source window.
  - `swayidle`: Automatically locks the screen with Noctalia after 15 minutes (`900s`), suspends the machine after 30 minutes (`1800s`), and locks before system sleep.

---

## ⌨️ Interactive Keybindings Cheatsheet (`SUPER + H`)

Never forget a shortcut: pressing **`SUPER + H`** launches the live **`keyhints`** interactive modal:

- **Fuzzy Search & Action Launcher (`rofi`)**: Search any keybind by category, shortcut, or description. Pressing `Enter` on any application row immediately executes the action.
- **Persistent Graphical Cheatsheet (`yad`)**: Selecting the top item or running `keyhints --table` / `keyhints -t` opens a floating 3-column GTK reference table that stays visible while you work.

### Essential Keybindings

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + H` | **Keybindings Cheatsheet** | Opens interactive searchable keyhints modal |
| `SUPER + Return` | **Terminal** | Opens Kitty terminal emulator |
| `SUPER + B` | **Web Browser** | Opens Firefox |
| `SUPER + E` | **File Manager** | Opens Thunar file manager |
| `SUPER + Space` | **Toggle Floating** | Switches active window between floating and tiled |
| `SUPER + ALT + Space` | **Float All** | Floats all windows on current workspace |
| `SUPER + F` | **Fullscreen** | Toggles fullscreen mode |
| `SUPER + N` | **Cycle Layout** | Switches layout (tile / scroller / grid) |
| `SUPER + Shift + S` | **Screenshot** | Interactive area screenshot with Swappy annotation |
| `SUPER + 1..9` | **Workspaces** | Switch to workspace 1–9 |
| `SUPER + Shift + 1..9`| **Move Window** | Move active window to workspace 1–9 |
| `SUPER + U` | **Scratchpad** | Toggles dropdown scratchpad workspace |
| `Ctrl + Alt + L` | **Lock Screen** | Locks session with Noctalia |
| `Ctrl + Alt + P` | **Power Menu** | Opens power, suspend, and reboot menu |

---

## 🛠️ Security, Reverse Engineering & CTF Suite

The configuration provides a complete offensive, defensive, and cryptanalysis laboratory:

### Binary Exploitation (Pwn) & Debugging
- **GDB & Pwndbg**: GDB with cutting-edge Pwndbg integration.
- **Auto-Pwn Tooling**: `pwninit`, `pwninit-ghidra` (auto-generates exploit script with Ghidra decompilation stubs), `pwntools`.
- **ROP & Gadgets**: `ropper`, `ropgadget`, `one_gadget` (finds libc one-gadget RCEs).
- **Sandboxing & ELF**: `rubyPackages.seccomp-tools` (BPF filter inspector), `checksec`, `patchelf`, `elfutils` (`eu-readelf`, `eu-elfcmp`), `ltrace`, `strace`, `file`, `xxd`.

### Reverse Engineering & Hex Editors
- **Ghidra**: NSA software reverse engineering suite with JDK 21.
- **Headless Scripts**: `ghidra-auto` for automated batch binary decompilation.
- **Hex Editors**: `ht` (interactive PE/ELF/hex viewer), `rizin`, `radare2`, `imhex`.

### Cryptography & Mathematics
- **SageMath**: `sage` (SageMath 10.9) fetched precompiled from Nixpkgs binary cache—no 2-hour virtual machine source builds required!
- **PyCryptodome**: Python 3 cryptographic primitives.
- **MTP (Many-Time Pad)**: Interactive XOR key-reuse cryptanalysis solver (`packages/mtp.nix`). Run `mtp <ciphertexts.txt>`.

### Network, Stego & Web Security
- **Wireshark & Tshark**: GUI packet capture with non-root dumpcap permissions for user `virgola`, plus `tshark` CLI and `python3Packages.pyshark`.
- **Steganography**: `binwalk` (firmware carving), `stegsolve` (visual bit plane analyzer), `john` (John the Ripper Jumbo).
- **Web & Ingress**: `burpsuite`, `postman`, `ngrok`, `gobuster`, `nmap`.
- **Tunnelmole (`tmole`)**: Open-source ngrok alternative (`packages/tunnelmole.nix`). Run `tmole 8080` to expose local servers with an instant public HTTPS URL.

---

## 👤 Centralized User & Regional Identity (`nixos/settings.nix`)

All personal identity and regional preferences are centralized in [`nixos/settings.nix`](./nixos/settings.nix). If you are forking this repository or customizing it for another user, you only need to change settings in **this single file**:

```nix
options.custom = {
  username = "virgola";           # Changes login name across all modules, sudoers, and configs
  userDescription = "Alessandro"; # Full GECOS name
  initialPassword = "nixos";      # Default initial password for new systems
  timezone = "Europe/Rome";       # System timezone
  locale = "en_US.UTF-8";         # Primary locale
  extraLocale = "it_IT.UTF-8";    # Currency, time, and numeric formatting
  keyboardLayout = "it";          # Wayland & X11 keyboard layout
  consoleKeyMap = "it2";          # Linux console TTY keymap

  theme = {
    colorScheme = "dark";         # Global dark mode preference (XDG portal & dconf)
    gtkTheme = "adw-gtk3-dark";   # GTK 3/4 theme for Thunar, Pavucontrol, GIMP
    iconTheme = "Papirus-Dark";   # Modern dark icon theme
    cursorTheme = "Bibata-Modern-Classic"; # Global cursor theme
    cursorSize = 24;              # Cursor size in pixels
  };
};
```

When you update these settings:
- User creation and group assignments (`wheel`, `networkmanager`, `docker`, `wireshark`, `video`, etc.) adapt dynamically.
- Default interactive login shell (`zsh`) follows the configured user.
- Ollama passwordless daemon control rules in `sudoers` point to your user.
- Password prompts in `bootstrap.sh` and VM runner query your username.
- **GTK Applications & Desktop Plumbing**: GTK 3 & GTK 4 (`/etc/xdg/gtk-*/settings.ini`), dconf user databases (`org/gnome/desktop/interface`), and environment variables (`GTK_THEME`, `XCURSOR_THEME`, `XCURSOR_SIZE`) automatically sync, ensuring Thunar, Pavucontrol, GIMP, and file pickers seamlessly open in dark mode without bright light-theme flashes.

---

## 🚀 Developer Toolchains & Templates (`ninit`)

Scaffold new reproducible development environments with a single command:

```bash
# Launch interactive template picker (fzf):
ninit

# Or scaffold directly by name or alias:
ninit rust my-crate          # Rust with Cargo, rust-analyzer, clippy
ninit py my-fastapi          # Python with uv, ruff, pyright
ninit ts my-app              # TypeScript & Node 22 with pnpm and Biome
ninit cpp my-engine          # Modern C++20 with Clang, CMake, Ninja, GDB
ninit pio my-firmware        # Embedded microcontroller with PlatformIO, ARM GCC, TinyGo
ninit php my-api             # Modern PHP 8.4 with Composer
ninit pwn my-exploit         # CTF / binary exploitation harness with Pwntools, Ropper, GDB
ninit go my-service          # Go with gopls, golangci-lint, delve
ninit latex my-thesis        # LaTeX / LuaTeX with Tectonic, SyncTeX, Texlab
```

### Supported Stacks & Languages
- **Python**: `uv` package manager with `UV_PYTHON_DOWNLOADS=automatic`, `python3Packages.pip`, `ruff`, `pyright`. Prebuilt C/C++ wheels run natively via `nix-ld`.
- **TypeScript & Node.js**: Node.js 22 LTS, `pnpm`, `typescript`, `@biomejs/biome`, and `tsx`.
- **C / C++**: Clang, GCC, CMake, Ninja, GDB, Valgrind, and `clang-tools` (clangd, clang-format).
- **Embedded & Hardware**: PlatformIO Core (`pio`), `gcc-arm-embedded`, `tinygo`, `avrdude`, and `openocd`.
- **PHP**: PHP 8.4 CLI with Composer.
- **Cyber Security & CTF**: Python with `pwntools`, `pycryptodome`, `ropper`, `gdb`, `checksec`, `patchelf`.
- **Java**: OpenJDK 21 LTS (`jdk21`).
- **Protobuf & APIs**: `buf` CLI (`.proto` code generation, linting, and breaking change detection), `protobuf` compiler, `grpcurl`, `websocat`, and local GitHub Actions runner `act`.
- **LaTeX / Academic**: `tectonic` standalone compiler, `texliveMedium` (with `biber` & `chktex`), `texlab` LSP, `ltex-ls-plus`, and **Zathura SyncTeX** (Ctrl+Click in PDF navigates directly to LaTeX source code line).
- **Containers**: Docker daemon (`virtualisation.docker.enable = true`), `docker-compose`, and `distrobox`.
- **IDEs**: Visual Studio Code (`vscode`) and Antigravity AI IDE (`antigravity-ide`) with CLI agent (`agy`).

---

## 🔐 Bitwarden / Vaultwarden In-Memory SSH Agent

Manage SSH keys securely in memory without keeping unencrypted private keys on disk:

```bash
# 1. Add / upload an SSH key to Bitwarden or Vaultwarden:
ssh-vault-add                        # Uploads ~/.ssh/id_ed25519 as 'id_ed25519'
ssh-vault-add ~/.ssh/id_work work    # Uploads ~/.ssh/id_work as 'work'
ssh-vault-add -g my_new_key          # Generates ~/.ssh/my_new_key and uploads it
# (You will be prompted to safely shred the unencrypted private key from disk)

# 2. List keys stored in your vault:
ssh-vault-list

# 3. Load a key on-demand into ssh-agent memory:
ssh-vault-load id_ed25519            # (or run without arguments for default key)
```

---

## 🌐 WireGuard & Fortinet SSL VPN Suite

Both WireGuard and FortiGate SSL VPNs are supported out-of-the-box:

```bash
# WireGuard via NetworkManager:
nmcli connection import type wireguard file ~/my-vpn.conf
nmcli connection up my-vpn
nmcli connection down my-vpn

# Fortinet SSL VPN via OpenFortiVPN CLI:
sudo openfortivpn -c /etc/openfortivpn/config.example
```
*(Or configure graphically via `nm-connection-editor` with the `networkmanager-openconnect` plugin).*

---

## 🧹 System Hygiene & Maintenance

- **Automated Weekly Garbage Collection**: Automatically cleans store derivations older than 7 days (`nix.gc`).
- **Store Deduplication**: Hardlinks duplicate files weekly (`nix.optimise`) and performs continuous deduplication (`auto-optimise-store = true`).
- **Low-Disk Protection**: Prevents out-of-disk crashes during large builds with `min-free = 5 GiB` and `max-free = 10 GiB`.
- **Boot Clutter Guard**: Caps bootloader generations at the last 10 versions on both GRUB and systemd-boot.

---

## 📋 Common Management Commands

```bash
# Rebuild & activate the current machine:
sudo nixos-rebuild switch --flake .#vm      # On VM
sudo nixos-rebuild switch --flake .#laptop  # On Laptop

# Format all Nix files with Alejandra:
nix fmt .

# Run flake validation suite:
nix flake check .

# Roll back to the previous generation:
sudo nixos-rebuild switch --rollback
```

---

## 📄 License

This repository is maintained by **Alessandro De Biasi** ([@lilvirgola](https://github.com/lilvirgola)) and is released under the **MIT License**.
