{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.raspberrypiConfiguration = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (inputs.nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      self.nixosModules.core
      self.nixosModules.homeManagerCore
      self.nixosModules.tailscale
      self.nixosModules.docker
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    networking.hostName = "raspberrypi";
    networking.networkmanager.enable = true;

    # Disable nix-ld on aarch64 headless Pi unless needed; keep memory footprint lean
    programs.nix-ld.enable = lib.mkForce false;

    # Hardened SSH: key-only auth and no default initial password
    users.users.${config.custom.username} = {
      extraGroups = ["networkmanager"];
      initialPassword = lib.mkForce null;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM5kUX2P605n93HxM5Af6+EsA8R/Hb+NqpiywKsNgye virgola@LaptopVirgola"
      ];
    };
    services.openssh.settings.PasswordAuthentication = config.custom.sshAuthorizedKeys == [];

    # sd-image.nix enables all-hardware (Rockchip/Allwinner modules like dw-hdmi that don't
    # exist in linux_rpi4) and profiles/base.nix enables ZFS (unnecessary kernel module build).
    hardware.enableAllHardware = lib.mkForce false;
    boot.supportedFilesystems.zfs = lib.mkForce false;
    boot.initrd.availableKernelModules = [
      "vc4"
      "uas"
    ];

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [22];
      trustedInterfaces = ["tailscale0"];
    };

    hardware.enableRedistributableFirmware = true;

    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
      htop
      tmux
      ncdu
    ];
  };
}
