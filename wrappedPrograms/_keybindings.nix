# Shared keybinding definitions for MangoWM (`wrappedPrograms/mangowm.nix`)
# and the `keyhints` cheatsheet (`packages/keyhints.nix`).
{
  pkgs,
  lib,
  self',
}: let
  noctalia = lib.getExe self'.packages.myNoctalia;
  kitty = lib.getExe self'.packages.myKitty;
  keyhints = lib.getExe self'.packages.keyhints;
  firefox = lib.getExe pkgs.firefox;
  thunar = lib.getExe pkgs.thunar;
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
  swappy = lib.getExe pkgs.swappy;

  screenshotSwappy = pkgs.writeShellScript "screenshot-swappy" ''
    ${grim} -g "$(${slurp})" - | ${swappy} -f -
  '';
  screenshotFull = pkgs.writeShellScript "screenshot-full" ''
    mkdir -p ~/Pictures/Screenshots
    ${grim} "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
  '';
  screenshotArea = pkgs.writeShellScript "screenshot-area" ''
    mkdir -p ~/Pictures/Screenshots
    ${grim} -g "$(${slurp})" "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
  '';

  workspaces = map toString (lib.range 1 9);

  # Structured bindings: each entry produces a MangoWM `bind` line and,
  # when `hint != null`, an item in `keyhints`.
  entries = [
    # Apps
    {
      bind = "SUPER,d,spawn,${noctalia} msg panel-toggle launcher";
      hint = "Apps|SUPER + D|Toggle App Launcher (Noctalia)|launcher";
    }
    {
      bind = "SUPER,s,spawn,${noctalia} msg panel-toggle launcher";
      hint = "Apps|SUPER + S|Toggle App Launcher (Noctalia)|launcher";
    }
    {
      bind = "SUPER,Return,spawn,${kitty}";
      hint = "Apps|SUPER + Return|Launch Terminal (Kitty)|kitty";
    }
    {
      bind = "SUPER,b,spawn,${firefox}";
      hint = "Apps|SUPER + B|Open Firefox Web Browser|browser";
    }
    {
      bind = "SUPER,e,spawn,${thunar}";
      hint = "Apps|SUPER + E|Open File Manager (Thunar)|files";
    }
    {
      bind = "SUPER+ALT,v,spawn,${noctalia} msg panel-toggle clipboard";
      hint = "Apps|SUPER + ALT + V|Open Clipboard History|clipboard";
    }
    {
      bind = "SUPER+ALT,c,spawn,${noctalia} msg panel-toggle launcher";
      hint = "Apps|SUPER + ALT + C|Open Calculator / Launcher|launcher";
    }
    {
      bind = "SUPER+SHIFT,n,spawn,${noctalia} msg panel-toggle control-center";
      hint = "Apps|SUPER + SHIFT + N|Toggle Control Center (Noctalia)|control-center";
    }
    {
      bind = "SUPER+SHIFT,e,spawn,${noctalia} msg panel-toggle session";
      hint = "Apps|SUPER + SHIFT + E|Toggle Session / Power Menu|session";
    }
    {
      bind = "CTRL+ALT,p,spawn,${noctalia} msg panel-toggle session";
      hint = "Apps|CTRL + ALT + P|Toggle Session / Power Menu|session";
    }
    {
      bind = "CTRL+ALT,l,spawn,${noctalia} msg session lock";
      hint = "Apps|CTRL + ALT + L|Lock Screen (Noctalia)|lock";
    }
    {
      bind = "SUPER,h,spawn,${keyhints}";
      hint = "Apps|SUPER + H|Keybindings Cheatsheet (This Menu)|keyhints";
    }

    # Windows
    {
      bind = "SUPER,q,killclient";
      hint = "Windows|SUPER + Q|Close Active Window (killclient)|none";
    }
    {
      bind = "SUPER+SHIFT,q,killclient,force";
      hint = "Windows|SUPER + SHIFT + Q|Force Kill Active Window (SIGKILL)|none";
    }
    {
      bind = "SUPER,r,reload_config";
      hint = "Windows|SUPER + R|Reload Compositor Configuration|none";
    }
    {
      bind = "CTRL+ALT,Delete,quit";
      hint = "Windows|CTRL + ALT + Delete|Quit Compositor / Logout|none";
    }
    {
      bind = "SUPER,space,togglefloating";
      hint = "Windows|SUPER + Space|Toggle Window Floating|none";
    }
    {
      bind = "SUPER+ALT,space,toggle_all_floating";
      hint = "Windows|SUPER + ALT + Space|Toggle All Windows Floating|none";
    }
    {
      bind = "SUPER,f,togglefullscreen";
      hint = "Windows|SUPER + F|Toggle Fullscreen|none";
    }
    {
      bind = "SUPER+SHIFT,f,togglefullscreen";
      hint = "Windows|SUPER + SHIFT + F|Toggle Fullscreen|none";
    }
    {
      bind = "SUPER+CTRL,f,togglemaximizescreen";
      hint = "Windows|SUPER + CTRL + F|Toggle Maximize Screen|none";
    }
    {
      bind = "SUPER,a,toggleoverview";
      hint = "Windows|SUPER + A|Toggle Desktop Overview|none";
    }
    {
      bind = "SUPER,n,switch_layout";
      hint = "Windows|SUPER + N|Switch Window Layout (tile/scroller/grid)|none";
    }
    {
      bind = "SUPER+SHIFT,i,dwindle_toggle_split_direction";
      hint = "Windows|SUPER + SHIFT + I|Dwindle Toggle Split Direction|none";
    }

    # Navigation
    {
      bind = "SUPER,Left,focusdir,left";
      hint = "Navigation|SUPER + Left / Right|Focus Window Left / Right|none";
    }
    {
      bind = "SUPER,Right,focusdir,right";
      hint = null;
    }
    {
      bind = "SUPER,Up,focusdir,up";
      hint = "Navigation|SUPER + Up / Down|Focus Window Up / Down|none";
    }
    {
      bind = "SUPER,Down,focusdir,down";
      hint = null;
    }
    {
      bind = "SUPER,l,focusdir,right";
      hint = "Navigation|SUPER + J / K / L|Vim Focus (Down, Up, Right)|none";
    }
    {
      bind = "SUPER,k,focusdir,up";
      hint = null;
    }
    {
      bind = "SUPER,j,focusdir,down";
      hint = null;
    }
    {
      bind = "SUPER,Tab,focusstack,next";
      hint = "Navigation|SUPER + Tab|Focus Next Window in Stack|none";
    }
    {
      bind = "ALT,Tab,focusstack,next";
      hint = "Navigation|ALT + Tab|Focus Next Window in Stack|none";
    }
    {
      bind = "SUPER+SHIFT,Tab,focusstack,prev";
      hint = "Navigation|SUPER + SHIFT + Tab|Focus Previous Window in Stack|none";
    }

    # Resize & Move
    {
      bind = "SUPER+SHIFT,Left,resizewin,-50,0";
      hint = "Resize & Move|SUPER + SHIFT + Arrows|Resize Window (±50px)|none";
    }
    {
      bind = "SUPER+SHIFT,Right,resizewin,50,0";
      hint = null;
    }
    {
      bind = "SUPER+SHIFT,Up,resizewin,0,-50";
      hint = null;
    }
    {
      bind = "SUPER+SHIFT,Down,resizewin,0,50";
      hint = null;
    }
    {
      bind = "SUPER+SHIFT,h,resizewin,-50,0";
      hint = "Resize & Move|SUPER + SHIFT + HJKL|Resize Window (±50px)|none";
    }
    {
      bind = "SUPER+SHIFT,l,resizewin,50,0";
      hint = null;
    }
    {
      bind = "SUPER+SHIFT,k,resizewin,0,-50";
      hint = null;
    }
    {
      bind = "SUPER+SHIFT,j,resizewin,0,50";
      hint = null;
    }

    {
      bind = "SUPER+ALT,Left,exchange_client,left";
      hint = "Resize & Move|SUPER + ALT + Arrows|Swap Window Position|none";
    }
    {
      bind = "SUPER+ALT,Right,exchange_client,right";
      hint = null;
    }
    {
      bind = "SUPER+ALT,Up,exchange_client,up";
      hint = null;
    }
    {
      bind = "SUPER+ALT,Down,exchange_client,down";
      hint = null;
    }
    {
      bind = "SUPER+ALT,h,exchange_client,left";
      hint = "Resize & Move|SUPER + ALT + HJKL|Swap Window Position|none";
    }
    {
      bind = "SUPER+ALT,l,exchange_client,right";
      hint = null;
    }
    {
      bind = "SUPER+ALT,k,exchange_client,up";
      hint = null;
    }
    {
      bind = "SUPER+ALT,j,exchange_client,down";
      hint = null;
    }

    {
      bind = "SUPER+CTRL,Left,smartmovewin,-50,0";
      hint = "Resize & Move|SUPER + CTRL + Arrows|Move Floating Window (±50px)|none";
    }
    {
      bind = "SUPER+CTRL,Right,smartmovewin,50,0";
      hint = null;
    }
    {
      bind = "SUPER+CTRL,Up,smartmovewin,0,-50";
      hint = null;
    }
    {
      bind = "SUPER+CTRL,Down,smartmovewin,0,50";
      hint = null;
    }

    # Workspaces
    {
      bind = "SUPER,comma,viewtoleft";
      hint = "Workspaces|SUPER + , / SUPER + .|Switch to Previous / Next Workspace|none";
    }
    {
      bind = "SUPER,period,viewtoright";
      hint = null;
    }
    {
      bind = "SUPER,u,toggle_special_tag";
      hint = "Workspaces|SUPER + U|Toggle Scratchpad (Special Workspace)|none";
    }
    {
      bind = "SUPER+SHIFT,u,tag_special_tag";
      hint = "Workspaces|SUPER + SHIFT + U|Move Active Window to Scratchpad|none";
    }

    # Screenshots
    {
      bind = "SUPER+SHIFT,s,spawn,${screenshotSwappy}";
      hint = "Screenshots|SUPER + SHIFT + S|Area Screenshot with Annotation (Swappy)|screenshot-area";
    }
    {
      bind = "none,Print,spawn,${screenshotFull}";
      hint = "Screenshots|Print|Full Screen Screenshot (~/Pictures/Screenshots)|screenshot-full";
    }
    {
      bind = "SHIFT,Print,spawn,${screenshotArea}";
      hint = "Screenshots|SHIFT + Print|Area Screenshot (~/Pictures/Screenshots)|screenshot-area-save";
    }

    # Audio & Media
    {
      bind = "none,XF86AudioRaiseVolume,spawn,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
      hint = "Audio & Media|Volume Up / Down|Raise / Lower Audio Volume (+5% / -5%)|none";
    }
    {
      bind = "none,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      hint = null;
    }
    {
      bind = "none,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      hint = "Audio & Media|Mute / Mic Mute|Toggle Audio / Microphone Mute|none";
    }
    {
      bind = "none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      hint = null;
    }
    {
      bind = "none,XF86AudioPlay,spawn,playerctl play-pause";
      hint = "Audio & Media|Media Play / Pause|Play / Pause Current Track|none";
    }
    {
      bind = "none,XF86AudioNext,spawn,playerctl next";
      hint = "Audio & Media|Media Next / Prev|Next / Previous Media Track|none";
    }
    {
      bind = "none,XF86AudioPrev,spawn,playerctl previous";
      hint = null;
    }
    {
      bind = "none,XF86AudioStop,spawn,playerctl stop";
      hint = "Audio & Media|Media Stop|Stop Current Media Playback|none";
    }

    # Hardware
    {
      bind = "none,XF86MonBrightnessUp,spawn,brightnessctl set +5%";
      hint = "Hardware|Brightness Up / Down|Increase / Decrease Screen Brightness|none";
    }
    {
      bind = "none,XF86MonBrightnessDown,spawn,brightnessctl set 5%-";
      hint = null;
    }
  ];

  workspaceBinds =
    (map (n: "SUPER,${n},view,${n},0") workspaces)
    ++ (map (n: "SUPER+SHIFT,${n},tag,${n},0") workspaces)
    ++ (map (n: "SUPER+CTRL,${n},tagsilent,${n},0") workspaces);

  workspaceHints = [
    "Workspaces|SUPER + 1..9|Switch to Workspace 1..9|none"
    "Workspaces|SUPER + SHIFT + 1..9|Move Active Window to Workspace 1..9|none"
    "Workspaces|SUPER + CTRL + 1..9|Move Window to Workspace Silently|none"
  ];

  mouseHints = [
    "Resize & Move|SUPER + Left Click Drag|Drag & Move Window|none"
    "Resize & Move|SUPER + Right Click Drag|Drag & Resize Window|none"
  ];
in {
  mangoBinds = (map (e: e.bind) entries) ++ workspaceBinds;

  keyhintsItems =
    (builtins.filter (h: h != null) (map (e: e.hint) entries))
    ++ workspaceHints
    ++ mouseHints;
}
