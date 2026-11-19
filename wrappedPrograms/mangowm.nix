{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    kb = import ./_keybindings.nix {inherit pkgs lib self';};
  in {
    packages.myMango = inputs.wrapper-modules.wrappers.mangowc.wrap {
      inherit pkgs;
      autostart_sh = ''
        # Desktop shell (keeps MANGO_INSTANCE_SIGNATURE so Noctalia uses Mango IPC,
        # which provides per-window tag info needed for app icons in the taskbar)
        ${lib.getExe self'.packages.myNoctalia} &

        # Polkit graphical authentication agent
        ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

        # Clipboard persistence (keeps copied items after closing window)
        ${lib.getExe pkgs.wl-clip-persist} --clipboard both &

        # Inactivity auto-locker and sleep (15 min lock, 30 min suspend)
        ${lib.getExe pkgs.swayidle} -w \
          timeout 900 '${lib.getExe self'.packages.myNoctalia} msg session lock' \
          timeout 1800 'systemctl suspend' \
          before-sleep '${lib.getExe self'.packages.myNoctalia} msg session lock' &

        # Inhibit idle lock and sleep while media/game audio is playing
        ${lib.getExe pkgs.wayland-pipewire-idle-inhibit} &
      '';
      settings = {
        # Keyboard layout matching Italian keymap
        xkb_rules_layout = "it";
        repeat_rate = 25;
        repeat_delay = 600;

        # Trackpad & mouse
        tap_to_click = 1;
        tap_and_drag = 1;
        drag_lock = 1;
        trackpad_disable_while_typing = 1;
        sloppy_focus = 1;
        warp_cursor = 1;

        # Visuals & window aesthetics (harmonized with Catppuccin / Noctalia)
        blur = 1;
        blur_optimized = 1;
        blur_params_radius = 5;
        blur_params_num_passes = 2;
        border_radius = 8;
        gap_inner_horizontal = 5;
        gap_inner_vertical = 5;
        gap_outer_horizontal = 10;
        gap_outer_vertical = 10;
        border_px = 2;
        focus_color = "0x89b4faff";
        border_color = "0x313244ff";
        urgent_color = "0xf38ba8ff";
        maximized_screen_color = "0xa6e3a1ff";
        scratchpad_color = "0xf9e2afff";

        # Animations
        animations = 1;
        layer_animations = 1;
        animation_type_open = "slide";
        animation_type_close = "slide";
        animation_duration_open = 400;
        animation_duration_close = 800;

        # Tag rules (workspaces 1-9)
        tag_rule = [
          "id:1,layout_name:tile"
          "id:2,layout_name:tile"
          "id:3,layout_name:tile"
          "id:4,layout_name:tile"
          "id:5,layout_name:tile"
          "id:6,layout_name:tile"
          "id:7,layout_name:tile"
          "id:8,layout_name:tile"
          "id:9,layout_name:tile"
        ];

        # Comprehensive Keybindings (synced with keyhints via _keybindings.nix)
        bind = kb.mangoBinds;

        # Mouse Drag & Resize Bindings
        mousebind = [
          "SUPER,btn_left,moveresize,curmove"
          "SUPER,btn_right,moveresize,curresize"
        ];
      };
    };
  };
}
