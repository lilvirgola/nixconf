# Wrapped applications in wrappedPrograms/

This directory contains standalone program wrappers built using [`BirdeeHub/nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules).

## Wrapper modules design

Wrapped applications bundle their configuration directly into the Nix store derivation:
1. Self-contained derivations: configuration files, environment variables, dependencies, and CLI flags are built into the package output.
2. Configuration immutability: the binary runs with fixed settings, avoiding issues with missing dotfiles or broken symlinks.
3. Portability: wrapped applications can run on any Linux system with Nix:
   ```bash
   nix run github:lilvirgola/nixconf#myNoctalia
   ```

## Programs

### 1. myMango ([wrappedPrograms/mangowm.nix](./mangowm.nix))
Wayland compositor based on `mangowc`:
- Autostart services:
  - `myNoctalia` shell daemon.
  - `polkit-gnome-authentication-agent-1` for GTK privilege prompts.
  - `wl-clip-persist --clipboard both` so copied data survives closing source windows.
  - `swayidle` configured to lock the session after 15 minutes (`900s`), suspend after 30 minutes (`1800s`), and lock before sleep.
- Keyboard configuration:
  - Italian keyboard layout (`xkb.layout = "it"`).
  - Tiling layouts: scroller, grid, and master.
- Keybindings:
  - `SUPER + Return`: Kitty terminal
  - `SUPER + H`: keybindings cheatsheet (`keyhints`)
  - `SUPER + B`: Firefox
  - `SUPER + E`: Thunar file manager
  - `SUPER + Space`: toggle window floating
  - `SUPER + Shift + S`: area screenshot with Swappy
  - `SUPER + 1..9`: switch workspaces
  - `Ctrl + Alt + L`: lock screen

### 2. myNoctalia ([wrappedPrograms/noctalia.nix](./noctalia.nix))
Desktop shell and status bar based on Noctalia v5:
- Floating bar: configured with top screen margins and rounded borders (`margin-top: 10`, `margin-left: 12`, `margin-right: 12`, `border-radius: 12`).
- Styling: Catppuccin Mocha color palette.
- Widgets:
  - App launcher and taskbar
  - System monitors (CPU, memory, storage)
  - Network and Wi-Fi status
  - Bluetooth device indicator
  - Audio and volume sliders
  - Battery indicator and power profile selector
  - Clock, calendar, and notification center

### 3. myNiri ([wrappedPrograms/niri.nix](./niri.nix))
Scrollable-tiling Wayland compositor:
- Fallback compositor paired with `myNoctalia` and `keyhints`.
- Horizontal scrollable tiling layout.

### 4. myKitty ([wrappedPrograms/kitty.nix](./kitty.nix))
Wrapped Kitty terminal emulator:
- Disables the window close confirmation prompt (`confirm_os_window_close = 0`) when closing windows through `SUPER + Q`.

## Writing a wrapped program

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

The program is exported automatically:
- Command line: `nix run .#myKitty`
- In NixOS modules: `self.packages.${pkgs.stdenv.hostPlatform.system}.myKitty`
