{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vmMinimalConfiguration = {
    config,
    pkgs,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      inputs.disko.nixosModules.disko
      ./_disko.nix
      self.nixosModules.core
      self.nixosModules.homeManagerCore
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    networking.hostName = "vm-minimal";
    networking.useDHCP = lib.mkDefault true;

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
    boot.loader.grub = {
      enable = true;
      device = "/dev/vda";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    services.qemuGuest.enable = true;

    users.users.${config.custom.username} = {
      initialPassword = lib.mkForce null;
      password = "nixos";
    };

    virtualisation.vmVariant = {
      virtualisation.memorySize = 2048;
      virtualisation.cores = 2;
      virtualisation.graphics = false;
    };

    environment.systemPackages = with pkgs; [
      htop
      tmux
    ];
  };
}
