{self, ...}: {
  flake.nixosModules.laptopConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.base
      self.nixosModules.mangowm
      self.nixosModules.wireguard
      self.nixosModules.laptopFeatures
      self.nixosModules.nvidia
      self.nixosModules.services
      self.nixosModules.desktopApps
      self.nixosModules.dev
      self.nixosModules.security
      self.nixosModules.gaming
    ];

    networking.hostName = "laptop";

    # Disable SSH server daemon on laptop by default
    services.openssh.enable = false;

    # UEFI Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
