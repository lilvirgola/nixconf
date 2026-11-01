{self, ...}: {
  flake.nixosModules.mangowm = {pkgs, ...}: {
    imports = [
      self.nixosModules.noctalia
    ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    programs.mango = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myMango;
    };
  };
}
