{
  flake.nixosModules.desktopApps = {pkgs, ...}: {
    programs.firefox.enable = true;
    programs.dconf.enable = true;

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
