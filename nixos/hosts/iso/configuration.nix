{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.isoConfiguration = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      self.nixosModules.core
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    networking.hostName = "nixconf-iso";

    # Keep ISO networking simple and fast
    networking.wireless.enable = lib.mkForce false;
    networking.networkmanager.enable = true;

    # Allow passwordless sudo on live rescue media, keep root SSH disabled
    security.sudo.wheelNeedsPassword = false;
    services.openssh.settings.PermitRootLogin = lib.mkForce "no";

    environment.systemPackages = with pkgs; [
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      parted
      gptfdisk
      btrfs-progs
      cryptsetup
      dosfstools
      e2fsprogs
      ntfs3g
      usbutils
      pciutils
      smartmontools
      testdisk
      nmap
      tcpdump
      tmux
    ];
  };
}
