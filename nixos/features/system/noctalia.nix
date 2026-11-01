{self, ...}: {
  flake.nixosModules.noctalia = {pkgs, ...}: {
    services.dbus.enable = true;
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia
      gtk3 # Provides gtk-launch for .desktop entries
      xdg-utils
      wl-clipboard
      cliphist
      pwvucontrol
    ];
  };
}
