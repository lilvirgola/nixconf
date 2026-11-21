{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    noctalia = lib.getExe self'.packages.myNoctalia;
    kitty = lib.getExe self'.packages.myKitty;
    keyhints = lib.getExe self'.packages.keyhints;
    firefox = lib.getExe pkgs.firefox;
    thunar = lib.getExe pkgs.thunar;
    grim = lib.getExe pkgs.grim;
    slurp = lib.getExe pkgs.slurp;
    swappy = lib.getExe pkgs.swappy;
    jq = lib.getExe pkgs.jq;

    forceKill = pkgs.writeShellScript "niri-force-kill" ''
      pid=$(niri msg -j focused-window | ${jq} -r '.pid // empty')
      [ -n "$pid" ] && kill -9 "$pid"
    '';
    screenshotSwappy = pkgs.writeShellScript "niri-screenshot-swappy" ''
      ${grim} -g "$(${slurp})" - | ${swappy} -f -
    '';
    screenshotFull = pkgs.writeShellScript "niri-screenshot-full" ''
      mkdir -p ~/Pictures/Screenshots
      ${grim} "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
    '';
    screenshotArea = pkgs.writeShellScript "niri-screenshot-area" ''
      mkdir -p ~/Pictures/Screenshots
      ${grim} -g "$(${slurp})" "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
    '';
  in {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          noctalia
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "${lib.getExe pkgs.wl-clip-persist} --clipboard both"
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb.layout = "it";

        layout.gaps = 5;

        binds = {
          # Apps & Shell
          "Mod+Return".spawn-sh = kitty;
          "Mod+D".spawn-sh = "${noctalia} msg panel-toggle launcher";
          "Mod+S".spawn-sh = "${noctalia} msg panel-toggle launcher";
          "Mod+B".spawn-sh = firefox;
          "Mod+E".spawn-sh = thunar;
          "Mod+Alt+V".spawn-sh = "${noctalia} msg panel-toggle clipboard";
          "Mod+Shift+N".spawn-sh = "${noctalia} msg panel-toggle control-center";
          "Mod+Shift+E".spawn-sh = "${noctalia} msg panel-toggle session";
          "Ctrl+Alt+P".spawn-sh = "${noctalia} msg panel-toggle session";
          "Ctrl+Alt+L".spawn-sh = "${noctalia} msg session lock";
          "Mod+H".spawn-sh = keyhints;

          # Windows & Columns
          "Mod+Q".close-window = [];
          "Mod+Shift+Q".spawn-sh = toString forceKill;
          "Mod+F".fullscreen-window = [];
          "Mod+Space".toggle-window-floating = [];
          "Mod+R".switch-preset-column-width = [];
          "Mod+A".toggle-overview = [];

          # Focus Navigation
          "Mod+Left".focus-column-left = [];
          "Mod+Right".focus-column-right = [];
          "Mod+Up".focus-window-up = [];
          "Mod+Down".focus-window-down = [];
          "Mod+J".focus-window-down = [];
          "Mod+K".focus-window-up = [];
          "Mod+L".focus-column-right = [];

          # Move Windows / Columns
          "Mod+Shift+Left".move-column-left = [];
          "Mod+Shift+Right".move-column-right = [];
          "Mod+Shift+Up".move-window-up = [];
          "Mod+Shift+Down".move-window-down = [];

          # Workspaces 1..9
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;

          "Mod+Shift+1".move-column-to-workspace = 1;
          "Mod+Shift+2".move-column-to-workspace = 2;
          "Mod+Shift+3".move-column-to-workspace = 3;
          "Mod+Shift+4".move-column-to-workspace = 4;
          "Mod+Shift+5".move-column-to-workspace = 5;
          "Mod+Shift+6".move-column-to-workspace = 6;
          "Mod+Shift+7".move-column-to-workspace = 7;
          "Mod+Shift+8".move-column-to-workspace = 8;
          "Mod+Shift+9".move-column-to-workspace = 9;

          # Screenshots
          "Mod+Shift+S".spawn-sh = toString screenshotSwappy;
          "Print".spawn-sh = toString screenshotFull;
          "Shift+Print".spawn-sh = toString screenshotArea;

          # Audio & Media
          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86AudioPlay".spawn-sh = "playerctl play-pause";
          "XF86AudioNext".spawn-sh = "playerctl next";
          "XF86AudioPrev".spawn-sh = "playerctl previous";
          "XF86AudioStop".spawn-sh = "playerctl stop";

          # Brightness
          "XF86MonBrightnessUp".spawn-sh = "brightnessctl set +5%";
          "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 5%-";
        };
      };
    };
  };
}
