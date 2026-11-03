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
      self.nixosModules.wireguard
      self.nixosModules.desktopApps
      self.nixosModules.dev
      self.nixosModules.security
      inputs.vscode-server.nixosModules.default
    ];

    services.vscode-server.enable = true;

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";
    boot.loader.grub.useOSProber = true;
    boot.loader.grub.configurationLimit = 10;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "nixos";

    # Ensure password works in the VM even if nixos.qcow2 already exists
    users.users."virgola".password = "nixos";
    users.users."root".password = "nixos";

    # VM runner configuration (applied when running ./result/bin/run-nixos-vm)
    virtualisation.vmVariant = {
      virtualisation.memorySize = 4096; # 4 GiB RAM instead of default 1 GiB
      virtualisation.cores = 4; # 4 CPU cores
      virtualisation.qemu.options = [
        "-vga"
        "virtio"
      ];
      # Run SDDM greeter via X11 inside VM so Astronaut theme renders reliably without Weston DRM crashes
      services.xserver.enable = true;
      services.displayManager.sddm.wayland.enable = false;
    };

    # Fix display, software rasterizer & cursor in QEMU with wlroots compositors
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
    };

    environment.systemPackages = with pkgs; [
      vscode
    ];
  };
}
