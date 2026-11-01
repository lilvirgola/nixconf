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

    environment.systemPackages = with pkgs; [
      heroic
      mangohud
      protontricks
    ];
  };
}
