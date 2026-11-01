{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vmConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.vmHardware
      self.nixosModules.base
      self.nixosModules.mangowm
      inputs.vscode-server.nixosModules.default
    ];

    services.vscode-server.enable = true;

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";
    boot.loader.grub.useOSProber = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "nixos";

    # Fix upside-down cursor in QEMU/virtio-gpu with wlroots compositors
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    environment.systemPackages = with pkgs; [
      vscode
    ];
  };
}
