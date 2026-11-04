# `wrappedPrograms/` — Hermetic Wrapped Applications (`nix-wrapper-modules`)

This directory contains standalone, portable program configurations built using [`BirdeeHub/nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules).

---

## Why Wrapper Modules?

In traditional NixOS setups, application dotfiles are either placed in `$HOME` imperatively or managed via Home Manager. `nix-wrapper-modules` uses a superior approach:
1. **Self-Contained Derivations**: Configuration files, environment variables, dependencies, and CLI flags are baked directly into the Nix store derivation.
2. **Zero Dotfile Drift**: The binary runs with its configuration baked in, preventing accidental modification, broken symlinks, or user profile corruption.
3. **Instant Portability**: You can test any wrapped application on *any* Linux system running Nix without altering your host configuration:
   ```bash
   nix run github:lilvirgola/nixconf#myNoctalia
   ```

---

## Current Wrapped Programs

### 1. `myMango` ([`wrappedPrograms/mangowm.nix`](./mangowm.nix))
The primary Wayland compositor based on `mangowc`:
- **Integrated Autostart**:
  - Starts `myNoctalia` shell daemon.
  - Starts `polkit-gnome-authentication-agent-1` for native GTK privilege prompts.
  - Starts `wl-clip-persist --clipboard both` so copied data survives closing source windows.
  - Starts `swayidle` configured to lock the session after 15 minutes (`900s`), suspend after 30 minutes (`1800s`), and lock before sleep.
- **Hardware & Keyboard**:
  - `xkb.layout = "it"` (Italian keyboard layout).
  - Tiling scroller, grid, and master layouts.
- **Full Keybindings Suite**:
  - `SUPER + Return`: Kitty terminal
  - `SUPER + H`: Interactive Keybindings Cheatsheet (`keyhints`)
  - `SUPER + B`: Firefox
  - `SUPER + E`: Thunar file manager
  - `SUPER + Space`: Toggle window floating
  - `SUPER + Shift + S`: Area screenshot with Swappy annotation
  - `SUPER + 1..9`: Switch workspaces
  - `Ctrl + Alt + L`: Lock screen

### 2. `myNoctalia` ([`wrappedPrograms/noctalia.nix`](./noctalia.nix))
The desktop shell and status bar based on `noctalia` (v5):
- **Floating Bar Architecture**:
  - Configured with top screen margins and rounded borders (`margin-top: 10`, `margin-left: 12`, `margin-right: 12`, `border-radius: 12`).
  - Floats smoothly above tiled windows without boxing or cutting off window decorations.
- **Styling**: Catppuccin Mocha color palette with customized opacity and typography.
- **Widgets**:
  - App launcher and taskbar
  - System monitors (CPU usage, memory load, storage gauges)
  - Network and Wi-Fi manager
  - Bluetooth device indicator
  - Audio and volume sliders
  - Battery gauge and power profile switcher
  - Clock, calendar, and notification center

### 3. `myNiri` ([`wrappedPrograms/niri.nix`](./niri.nix))
Optional scrollable-tiling Wayland compositor:
- Fallback compositor paired with `myNoctalia` and `keyhints`.
- Infinite horizontal scrollable tiling strip layout.

### 4. `myKitty` ([`wrappedPrograms/kitty.nix`](./kitty.nix))
The wrapped Kitty terminal emulator:
- Disables the exit confirmation prompt (`confirm_os_window_close = 0`) when closing windows via `SUPER + Q`.

---

## How to Author a Wrapped Program

Create `<program>.nix` in this directory:

```nix
{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.myKitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;
      settings = {
        font_family = "JetBrainsMono Nerd Font";
        font_size = 12.0;
        background_opacity = 0.95;
      };
    };
  };
}
```

Because `flake.nix` uses the Dendritic auto-importer, your new program is immediately available:
- On CLI: `nix run .#myKitty`
- Inside NixOS modules: `self.packages.${pkgs.stdenv.hostPlatform.system}.myKitty`
