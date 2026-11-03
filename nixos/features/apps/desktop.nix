{
  flake.nixosModules.desktopApps = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.firefox.enable = true;

    # Global GTK & Dconf Theme Integration (driven by centralized custom.theme settings)
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme =
                if config.custom.theme.colorScheme == "dark"
                then "prefer-dark"
                else "default";
              gtk-theme = config.custom.theme.gtkTheme;
              icon-theme = config.custom.theme.iconTheme;
              cursor-theme = config.custom.theme.cursorTheme;
              cursor-size = lib.gvariant.mkInt32 config.custom.theme.cursorSize;
            };
          };
        }
      ];
    };

    # System-wide GTK 3 & GTK 4 configuration for Thunar, GIMP, Pavucontrol & File dialogs
    environment.etc."xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=${config.custom.theme.gtkTheme}
      gtk-icon-theme-name=${config.custom.theme.iconTheme}
      gtk-cursor-theme-name=${config.custom.theme.cursorTheme}
      gtk-cursor-theme-size=${toString config.custom.theme.cursorSize}
      gtk-application-prefer-dark-theme=${
        if config.custom.theme.colorScheme == "dark"
        then "1"
        else "0"
      }
    '';

    environment.etc."xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=${config.custom.theme.gtkTheme}
      gtk-icon-theme-name=${config.custom.theme.iconTheme}
      gtk-cursor-theme-name=${config.custom.theme.cursorTheme}
      gtk-cursor-theme-size=${toString config.custom.theme.cursorSize}
      gtk-application-prefer-dark-theme=${
        if config.custom.theme.colorScheme == "dark"
        then "1"
        else "0"
      }
    '';

    environment.sessionVariables = {
      XCURSOR_THEME = config.custom.theme.cursorTheme;
      XCURSOR_SIZE = toString config.custom.theme.cursorSize;
      GTK_THEME = config.custom.theme.gtkTheme;
    };

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.tumbler.enable = true;
    services.gvfs.enable = true;

    # Zathura SyncTeX configuration for live bidirectional editor sync
    environment.etc."xdg/zathura/zathurarc".text = ''
      set synctex true
      set synctex-editor-command "antigravity --goto %{input}:%{line}"
      set selection-clipboard clipboard
    '';

    environment.systemPackages = with pkgs; [
      # GTK Themes, Icons & Cursors
      adw-gtk3
      papirus-icon-theme
      bibata-cursors
      # Web Browsers
      brave

      # Music & Media
      spotify
      mpv
      vlc
      pavucontrol
      picard
      obs-studio
      yt-dlp

      # Communication & Notes
      vesktop
      telegram-desktop
      obsidian

      # Productivity & Office
      libreoffice
      qalculate-gtk
      qbittorrent

      # Files, PDFs, Graphics & Screenshots
      gimp
      inkscape
      yazi
      zathura
      poppler-utils
      ffmpegthumbnailer
      grim
      slurp
      swappy
    ];
  };
}
