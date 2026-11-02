{
  flake.nixosModules.laptopFeatures = {pkgs, ...}: {
    hardware.enableRedistributableFirmware = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
      acpi
    ];
  };
}
