# Application modules (`nixos/features/apps/`)

Application suites exposed as `flake.nixosModules.<name>`.

## Modules

### `desktop.nix` (`flake.nixosModules.desktopApps`)
- Browsers and communication: `firefox`, `librewolf`, `vesktop`, `telegram-desktop`, `obsidian`.
- Media and graphics: `mpv`, `vlc`, `spotify`, `pavucontrol`, `picard`, `obs-studio`, `yt-dlp`, `gimp`, `inkscape`, `imv`, and `blender` (wrapped with CUDA and Nvidia offload env vars when `custom.enableCuda` is true).
- Files and documents: `thunar` (with archive and volume plugins), `gvfs`, `tumbler`, `yazi`, `zathura`, `poppler-utils`, `ffmpegthumbnailer`, `grim`, `slurp`, `swappy`, `gnome-calendar`, `libreoffice`, `qalculate-gtk`, `qbittorrent`, plus `adw-gtk3` and `papirus-icon-theme`.

### `dev.nix` (`flake.nixosModules.dev`)
- Core daily tooling: `antigravity` (`programs.antigravity.enable = true`), `docker` (with `docker-compose` and `distrobox`), `uv`, `python3` (with `dbus-python`, `pygobject3`, `cryptography`, `pyopenssl`), `vscode`, `gcc`, `gnumake`, `cmake`, `pkg-config`, `act`, and PlatformIO udev rules.
- Language-specific toolchains (Rust, Go, LaTeX, Embedded, SDR, Godot, Java, C#, Haskell, CTF) live in `templates/` and load per project via `ninit` and `direnv`.

### `antigravity.nix` (`flake.nixosModules.antigravity`)
- Packages `antigravity-ide`, `antigravity-cli`, and `agy` via an overlay and `perSystem.packages`.
- Runs natively on the host with `nix-ld` and `envfs` by default (`useFHS = false`) so `sudo` works in the integrated terminal.

### `security.nix` (`flake.nixosModules.security`)
- Reversing and binary exploitation: `ghidra`, `ghidra-auto`, `gdb` + `pwndbg`, `pwninit`, `pwninit-ghidra`, `pwntools`, `ropper`, `ropgadget`, `one_gadget`, `seccomp-tools`, `rizin`, `radare2`, `imhex`, `jadx`, `ht`, `checksec`, `patchelf`, `elfutils`, `bpftrace`, `strace`, `ltrace`.
- Network, web, and forensics: `wireshark` (adds user to `wireshark` group), `tshark`, `termshark`, `nmap`, `netcat-gnu`, `burpsuite`, `postman`, `gobuster`, `ngrok`, `tunnelmole`, `binwalk`, `stegsolve`, `zsteg`, `john`.
- Cryptography: `sage`, `pycryptodome`, `mtp`.

### `gaming.nix` (`flake.nixosModules.gaming`)
- Imports `nix-gaming.nixosModules.platformOptimizations`.
- Enables Steam (`gamescopeSession`, `proton-ge-bin`, Remote Play and dedicated server firewall ports) and `gamemode`.
- Installs `heroic`, `lutris`, `chiaki-ng`, `prismlauncher`, `mangohud`, `protontricks`, `winetricks`, and `wineWow64Packages.waylandFull`.

### `vr.nix` (`flake.nixosModules.vr`)
- Enables `services.wivrn` for Meta Quest 3 PCVR streaming (`autoStart = false`, `openFirewall = true`, `highPriority = true`, `steam.importOXRRuntimes = true`). Start the server on demand with `wivrn-dashboard`.
- Enables CUDA encoding (`cudaSupport = true`) and Nvidia PRIME offload env vars in `monadoEnvironment` when `custom.enableCuda` is true.
- Ensures Avahi mDNS firewall port is open and installs `xrizer` (OpenVR-to-OpenXR) and `android-tools` (`adb` for wired USB tethering and sideloading).
