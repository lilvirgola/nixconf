{self, ...}: {
  flake.nixosModules.laptopConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.base
      self.nixosModules.mangowm
      self.nixosModules.laptopFeatures
      self.nixosModules.nvidia
    ];

    networking.hostName = "laptop";

    # UEFI Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
