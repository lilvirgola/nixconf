# Wrapped applications (`wrappedPrograms/`)

Standalone wrapped binaries built with [`BirdeeHub/nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules). Each wrapper bundles its configuration inside the Nix store derivation and can be run directly with `nix run .#<package>`.

## Programs

### `myMango` (`wrappedPrograms/mangowm.nix`)
- Wayland compositor (`mangowc`) configured with Italian keymap (`xkb_rules_layout = "it"`), tap-to-click, blur, and tile/scroller/grid layouts.
- Autostart daemons: `myNoctalia`, `polkit-gnome-authentication-agent-1`, `wl-clip-persist --clipboard both`, `swayidle` (locks at 15 min, suspends at 30 min, locks before sleep), and `wayland-pipewire-idle-inhibit`.
- Keybindings are shared with `packages/keyhints.nix` via `wrappedPrograms/_keybindings.nix` so the cheatsheet stays in sync with MangoWM.

### `myNoctalia` (`wrappedPrograms/noctalia.nix` and `noctalia.toml`)
- Noctalia v5 shell wrapped with `NOCTALIA_CONFIG_HOME` pointing to the built `noctalia.toml` and `zenity`/`networkmanager` in `PATH`.
- Top floating bar layout:
  - Start: `launcher`, `active_window`
  - Center: `taskbar` (`group_by_workspace = true`, `show_workspace_label = true`, `hide_empty_workspaces = true`, `workspace_group_capsule = true`)
  - End: `media`, `tray`, `volume`, `andrewdems/vpn-manager:bar`, `network`, `bluetooth`, `battery`, `clock`, `control-center`, `session`

### `myNiri` (`wrappedPrograms/niri.nix`)
- Scrollable-tiling Wayland compositor fallback paired with `myNoctalia`, `polkit-gnome`, `wl-clip-persist`, and `xwayland-satellite`.
- Binds launcher (`Mod+D`/`Mod+S`), terminal (`Mod+Return`), browser (`Mod+B`), file manager (`Mod+E`), `keyhints` (`Mod+H`), workspaces `1..9`, column/window focus and move, screenshots (`Mod+Shift+S`, `Print`), volume, media, and brightness keys.

### `myKitty` (`wrappedPrograms/kitty.nix`)
- Kitty terminal wrapped with `confirm_os_window_close = 0`. Kitty SSH configs (`ssh.conf`, `remote_aliases.sh`, `templates/`) live in `home/desktop.nix`.

## Exporting and running

Any `.nix` file in this directory (except `_*`-prefixed helpers like `_keybindings.nix`) is auto-imported as a `flake-parts` module.

```bash
nix run .#myNoctalia
nix run .#myKitty
```
