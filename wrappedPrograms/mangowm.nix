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

        # Visuals & animations
        blur = 1;
        blur_optimized = 1;
        blur_params = {
          radius = 5;
          num_passes = 2;
        };
        border_radius = 6;
        gappih = 5;
        gappiv = 5;
        gappoh = 10;
        gappov = 10;
        borderpx = 2;
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

        # Keybindings
        bind = [
          "SUPER,r,reload_config"
          "SUPER,Return,spawn,${lib.getExe pkgs.kitty}"
          "SUPER,s,spawn,${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle"
          "SUPER+SHIFT,s,spawn,${pkgs.writeShellScript "screenshot" ''
            ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -
          ''}"
          "SUPER,q,killclient,"
          "SUPER,m,quit"
          "SUPER,f,togglefullscreen,"
          "SUPER,space,togglefloating,"
          "SUPER,Tab,focusstack,next"
          "SUPER,n,switch_layout"

          # Focus navigation
          "SUPER,Left,focusdir,left"
          "SUPER,Right,focusdir,right"
          "SUPER,Up,focusdir,up"
          "SUPER,Down,focusdir,down"

          # Swap windows
          "SUPER+SHIFT,Left,exchange_client,left"
          "SUPER+SHIFT,Right,exchange_client,right"
          "SUPER+SHIFT,Up,exchange_client,up"
          "SUPER+SHIFT,Down,exchange_client,down"

          # Switch workspace (tag 1..9)
          "SUPER,1,view,1,0"
          "SUPER,2,view,2,0"
          "SUPER,3,view,3,0"
          "SUPER,4,view,4,0"
          "SUPER,5,view,5,0"
          "SUPER,6,view,6,0"
          "SUPER,7,view,7,0"
          "SUPER,8,view,8,0"
          "SUPER,9,view,9,0"

          # Move window to workspace (tag 1..9)
          "SUPER+SHIFT,1,tag,1,0"
          "SUPER+SHIFT,2,tag,2,0"
          "SUPER+SHIFT,3,tag,3,0"
          "SUPER+SHIFT,4,tag,4,0"
          "SUPER+SHIFT,5,tag,5,0"
          "SUPER+SHIFT,6,tag,6,0"
          "SUPER+SHIFT,7,tag,7,0"
          "SUPER+SHIFT,8,tag,8,0"
          "SUPER+SHIFT,9,tag,9,0"
        ];

        mousebind = [
          "SUPER,btn_left,moveresize,curmove"
          "SUPER,btn_right,moveresize,curresize"
        ];
      };
    };
  };
}
