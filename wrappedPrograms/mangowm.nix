{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
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

        # Comprehensive Keybindings (JaKooLit Hyprland Parity)
        bind = [
          # App Launchers & Default Applications
          "SUPER,d,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle launcher"
          "SUPER,s,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle launcher"
          "SUPER,Return,spawn,${lib.getExe self'.packages.myKitty}"
          "SUPER,b,spawn,${lib.getExe pkgs.firefox}"
          "SUPER,e,spawn,${lib.getExe pkgs.thunar}"
          "SUPER+ALT,v,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle clipboard"
          "SUPER+ALT,c,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle launcher"
          "SUPER+SHIFT,n,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle control-center"
          "SUPER+SHIFT,e,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle session"
          "CTRL+ALT,p,spawn,${lib.getExe self'.packages.myNoctalia} msg panel-toggle session"
          "CTRL+ALT,l,spawn,${lib.getExe self'.packages.myNoctalia} msg session lock"
          "SUPER,h,spawn,${lib.getExe self'.packages.keyhints}"

          # Window Control & Layouts
          "SUPER,q,killclient"
          "SUPER,r,reload_config"
          "CTRL+ALT,Delete,quit"
          "SUPER,space,togglefloating"
          "SUPER+ALT,space,toggle_all_floating"
          "SUPER,f,togglefullscreen"
          "SUPER+SHIFT,f,togglefullscreen"
          "SUPER+CTRL,f,togglemaximizescreen"
          "SUPER,a,toggleoverview"
          "SUPER,n,switch_layout"
          "SUPER+SHIFT,i,dwindle_toggle_split_direction"

          # Focus Navigation (Arrows & Vim HJKL)
          "SUPER,Left,focusdir,left"
          "SUPER,Right,focusdir,right"
          "SUPER,Up,focusdir,up"
          "SUPER,Down,focusdir,down"
          "SUPER,l,focusdir,right"
          "SUPER,k,focusdir,up"
          "SUPER,j,focusdir,down"
          "SUPER,Tab,focusstack,next"
          "ALT,Tab,focusstack,next"
          "SUPER+SHIFT,Tab,focusstack,prev"

          # Resize Windows
          "SUPER+SHIFT,Left,resizewin,-50,0"
          "SUPER+SHIFT,Right,resizewin,50,0"
          "SUPER+SHIFT,Up,resizewin,0,-50"
          "SUPER+SHIFT,Down,resizewin,0,50"
          "SUPER+SHIFT,h,resizewin,-50,0"
          "SUPER+SHIFT,l,resizewin,50,0"
          "SUPER+SHIFT,k,resizewin,0,-50"
          "SUPER+SHIFT,j,resizewin,0,50"

          # Swap Windows (Tiled)
          "SUPER+ALT,Left,exchange_client,left"
          "SUPER+ALT,Right,exchange_client,right"
          "SUPER+ALT,Up,exchange_client,up"
          "SUPER+ALT,Down,exchange_client,down"
          "SUPER+ALT,h,exchange_client,left"
          "SUPER+ALT,l,exchange_client,right"
          "SUPER+ALT,k,exchange_client,up"
          "SUPER+ALT,j,exchange_client,down"

          # Move Floating Windows
          "SUPER+CTRL,Left,smartmovewin,-50,0"
          "SUPER+CTRL,Right,smartmovewin,50,0"
          "SUPER+CTRL,Up,smartmovewin,0,-50"
          "SUPER+CTRL,Down,smartmovewin,0,50"

          # Workspaces 1..9 (Switch)
          "SUPER,1,view,1,0"
          "SUPER,2,view,2,0"
          "SUPER,3,view,3,0"
          "SUPER,4,view,4,0"
          "SUPER,5,view,5,0"
          "SUPER,6,view,6,0"
          "SUPER,7,view,7,0"
          "SUPER,8,view,8,0"
          "SUPER,9,view,9,0"

          # Workspaces 1..9 (Move active window)
          "SUPER+SHIFT,1,tag,1,0"
          "SUPER+SHIFT,2,tag,2,0"
          "SUPER+SHIFT,3,tag,3,0"
          "SUPER+SHIFT,4,tag,4,0"
          "SUPER+SHIFT,5,tag,5,0"
          "SUPER+SHIFT,6,tag,6,0"
          "SUPER+SHIFT,7,tag,7,0"
          "SUPER+SHIFT,8,tag,8,0"
          "SUPER+SHIFT,9,tag,9,0"

          # Workspaces 1..9 (Move silently)
          "SUPER+CTRL,1,tagsilent,1,0"
          "SUPER+CTRL,2,tagsilent,2,0"
          "SUPER+CTRL,3,tagsilent,3,0"
          "SUPER+CTRL,4,tagsilent,4,0"
          "SUPER+CTRL,5,tagsilent,5,0"
          "SUPER+CTRL,6,tagsilent,6,0"
          "SUPER+CTRL,7,tagsilent,7,0"
          "SUPER+CTRL,8,tagsilent,8,0"
          "SUPER+CTRL,9,tagsilent,9,0"

          # Next / Previous Workspace Cycle
          "SUPER,comma,viewtoleft"
          "SUPER,period,viewtoright"

          # Special Workspace (Scratchpad)
          "SUPER,u,toggle_special_tag"
          "SUPER+SHIFT,u,tag_special_tag"

          # Screenshots
          "SUPER+SHIFT,s,spawn,${pkgs.writeShellScript "screenshot-swappy" ''
            ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -
          ''}"
          "none,Print,spawn,${pkgs.writeShellScript "screenshot-full" ''
            mkdir -p ~/Pictures/Screenshots
            ${lib.getExe pkgs.grim} "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          ''}"
          "SHIFT,Print,spawn,${pkgs.writeShellScript "screenshot-area" ''
            mkdir -p ~/Pictures/Screenshots
            ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          ''}"

          # Audio Volume & Microphone (wpctl)
          "none,XF86AudioRaiseVolume,spawn,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          "none,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          "none,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

          # Media Player Controls (playerctl)
          "none,XF86AudioPlay,spawn,playerctl play-pause"
          "none,XF86AudioNext,spawn,playerctl next"
          "none,XF86AudioPrev,spawn,playerctl previous"
          "none,XF86AudioStop,spawn,playerctl stop"

          # Display Brightness (brightnessctl)
          "none,XF86MonBrightnessUp,spawn,brightnessctl set +5%"
          "none,XF86MonBrightnessDown,spawn,brightnessctl set 5%-"
        ];

        # Mouse Drag & Resize Bindings
        mousebind = [
          "SUPER,btn_left,moveresize,curmove"
          "SUPER,btn_right,moveresize,curresize"
        ];
      };
    };
  };
}
