{
  flake.nixosModules.desktopApps = {pkgs, ...}: {
    programs.firefox.enable = true;
    programs.thunar.enable = true;

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

      # Files, PDFs & Screenshots
      yazi
      zathura
      grim
      slurp
      swappy
    ];
  };
}
