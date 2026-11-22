{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.desktopConfiguration = {
    pkgs,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.disko.nixosModules.disko
      ./_disko.nix
      self.nixosModules.core
      self.nixosModules.desktop
      self.nixosModules.mangowm
      self.nixosModules.wireguard
      self.nixosModules.tailscale
      self.nixosModules.printing
      self.nixosModules.gamingHardware
      self.nixosModules.desktopApps
      self.nixosModules.dev
      self.nixosModules.gaming
      self.nixosModules.vr
      self.nixosModules.android
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    networking.hostName = "desktop";

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    hardware.enableRedistributableFirmware = true;
  };
}
