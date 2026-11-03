{self, ...}: {
  flake.nixosModules.mangowm = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.noctalia
    ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = lib.mkDefault true;
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
