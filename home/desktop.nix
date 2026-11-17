{
  pkgs,
  osConfig,
  ...
}: {
  gtk = {
    enable = true;
    theme.name = osConfig.custom.theme.gtkTheme;
    iconTheme.name = osConfig.custom.theme.iconTheme;
    cursorTheme = {
      name = osConfig.custom.theme.cursorTheme;
      size = osConfig.custom.theme.cursorSize;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = osConfig.custom.theme.colorScheme == "dark";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = osConfig.custom.theme.colorScheme == "dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme =
        if osConfig.custom.theme.colorScheme == "dark"
        then "prefer-dark"
        else "default";
    };
  };

  home.pointerCursor = {
    enable = true;
    name = osConfig.custom.theme.cursorTheme;
    package = pkgs.bibata-cursors;
    size = osConfig.custom.theme.cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile = {
    "zathura/zathurarc".text = ''
      set synctex true
      set synctex-editor-command "antigravity --goto %{input}:%{line}"
      set selection-clipboard clipboard
    '';

    "kitty/ssh.conf".source = ../assets/kitty/ssh.conf;
    "kitty/remote_aliases.sh".source = ../assets/kitty/remote_aliases.sh;
    "kitty/templates" = {
      source = ../assets/kitty/templates;
      recursive = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/calendar" = ["org.gnome.Calendar.desktop"];
    };
  };
}
