{
  flake.nixosModules.gamingHardware = {pkgs, ...}: {
    hardware.steam-hardware.enable = true;
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
      dualsensectl
    ];
  };
}
