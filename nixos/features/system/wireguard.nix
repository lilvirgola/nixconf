{
  flake.nixosModules.wireguard = {pkgs, ...}: {
    # Loose reverse path filtering is required so WireGuard client tunnels don't drop packets
    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = with pkgs; [
      wireguard-tools
      networkmanagerapplet
    ];
  };
}
