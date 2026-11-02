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
        ${lib.getExe self'.packages.myNoctalia} &
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
        sloppyfocus = 1;
        warpcursor = 1;

        # Visuals & window aesthetics (harmonized with Catppuccin / Noctalia)
        blur = 1;
        blur_optimized = 1;
        blur_params = {
          radius = 5;
          num_passes = 2;
        };
        border_radius = 8;
        gappih = 5;
        gappiv = 5;
        gappoh = 10;
        gappov = 10;
        borderpx = 2;
        focuscolor = "0x89b4faff";
        bordercolor = "0x313244ff";
        urgentcolor = "0xf38ba8ff";
        maximizescreencolor = "0xa6e3a1ff";
        scratchpadcolor = "0xf9e2afff";

        # Animations
        animations = 1;
        layer_animations = 1;
        animation_type_open = "slide";
        animation_type_close = "slide";
        animation_duration_open = 400;
        animation_duration_close = 800;

        # Tag rules (workspaces 1-9)
        tagrule = [
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
          "SUPER,d,spawn,${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle"
          "SUPER,s,spawn,${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle"
          "SUPER,Return,spawn,${lib.getExe pkgs.kitty}"
          "SUPER,b,spawn,${lib.getExe pkgs.firefox}"
          "SUPER,e,spawn,${lib.getExe pkgs.thunar}"
          "SUPER+ALT,v,spawn,${lib.getExe self'.packages.myNoctalia} ipc call launcher clipboard"
          "SUPER+ALT,c,spawn,${lib.getExe self'.packages.myNoctalia} ipc call launcher calculator"
          "SUPER+SHIFT,n,spawn,${lib.getExe self'.packages.myNoctalia} ipc call controlCenter toggle"
          "SUPER+SHIFT,e,spawn,${lib.getExe self'.packages.myNoctalia} ipc call sessionMenu toggle"
          "CTRL+ALT,p,spawn,${lib.getExe self'.packages.myNoctalia} ipc call sessionMenu toggle"
          "CTRL+ALT,l,spawn,${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock"

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
          "SUPER,h,focusdir,left"
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
          "SUPER,bracketleft,viewtoleft"
          "SUPER,bracketright,viewtoright"
          "SUPER,comma,viewtoleft"
          "SUPER,period,viewtoright"
          "SUPER+SHIFT,bracketleft,tagtoleft"
          "SUPER+SHIFT,bracketright,tagtoright"

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
          "none,XF86AudioPause,spawn,playerctl play-pause"
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
