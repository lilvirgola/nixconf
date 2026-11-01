{self, ...}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    imports = [
      self.nixosModules.noctalia
    ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };
}
