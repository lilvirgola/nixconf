{inputs, ...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    imports = [
      inputs.nix-gaming.nixosModules.platformOptimizations
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode.enable = true;

    nixpkgs.config.permittedInsecurePackages = [
      "sidequest-1.4.1"
    ];
    nixpkgs.config.problems.handlers = {
      "gtk+".broken = "warn";
    };

    environment.systemPackages = with pkgs; [
      heroic
      lutris
      chiaki-ng
      prismlauncher
      sidequest
      dualsensectl
      mangohud
      protontricks
      winetricks
      wineWow64Packages.waylandFull
    ];
  };
}
