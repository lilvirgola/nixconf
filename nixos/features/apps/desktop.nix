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
      # Music & Media
      spotify
      mpv
      vlc
      pavucontrol

      # Communication & Notes
      vesktop
      telegram-desktop
      obsidian

      # Files, PDFs, Graphics & Screenshots
      gimp
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
