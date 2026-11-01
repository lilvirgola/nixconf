{
  flake.nixosModules.laptopFeatures = {pkgs, ...}: {
    hardware.enableRedistributableFirmware = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
      acpi
    ];
  };
}
