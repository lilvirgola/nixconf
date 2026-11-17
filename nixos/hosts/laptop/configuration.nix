{self, ...}: {
  flake.nixosModules.laptopConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.core
      self.nixosModules.desktop
      self.nixosModules.mangowm
      self.nixosModules.wireguard
      self.nixosModules.laptopFeatures
      self.nixosModules.nvidia
      self.nixosModules.tailscale
      self.nixosModules.mullvad
      self.nixosModules.ollama
      self.nixosModules.virtualisation
      self.nixosModules.printing
      self.nixosModules.gamingHardware
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
