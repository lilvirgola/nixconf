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
      rofi
    ];

    programs.mango = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myMango;
    };

    # Configure wlroots desktop portal for seamless screensharing in MangoWM
    xdg.portal = {
      enable = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 60;
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
          };
        };
      };
    };
  };
}
