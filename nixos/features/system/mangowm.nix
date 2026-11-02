{self, ...}: {
  flake.nixosModules.mangowm = {pkgs, ...}: {
    imports = [
      self.nixosModules.noctalia
    ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs.kdePackages; [
        qtsvg
        qtmultimedia
        qtvirtualkeyboard
      ];
    };

    environment.systemPackages = with pkgs; [
      sddm-astronaut
      bibata-cursors
    ];

    programs.mango = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myMango;
    };
  };
}
