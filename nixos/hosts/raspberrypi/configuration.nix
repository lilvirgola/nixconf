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
    };
    services.openssh.settings.PasswordAuthentication = config.custom.sshAuthorizedKeys == [];

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
