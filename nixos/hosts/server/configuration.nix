{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.serverConfiguration = {
    config,
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
      self.nixosModules.homeManagerCore
      self.nixosModules.docker
      self.nixosModules.tailscale
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    networking.hostName = "server";
    networking.useDHCP = lib.mkDefault true;

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "sd_mod" "virtio_pci"];
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;

    # Hardened SSH: key-only auth and no default initial password
    users.users.${config.custom.username}.initialPassword = lib.mkForce null;
    services.openssh.settings.PasswordAuthentication = config.custom.sshAuthorizedKeys == [];

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [22];
      trustedInterfaces = ["tailscale0"];
    };

    # Unattended weekly upgrades disabled by default; keep predictable flake deploys
    environment.systemPackages = with pkgs; [
      htop
      tmux
      ncdu
      docker-compose
    ];
  };
}
