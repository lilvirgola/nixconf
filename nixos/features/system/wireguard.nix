{self, ...}: {
  flake.nixosModules.wireguard = {
    config,
    pkgs,
    ...
  }: {
    # Loose reverse path filtering is required so VPN client tunnels (WireGuard, Fortinet) don't drop packets
    networking.firewall.checkReversePath = "loose";

    # Passwordless sudo rule for openfortivpn client
    security.sudo.extraRules = [
      {
        users = [config.custom.username];
        commands = [
          {
            command = "${pkgs.openfortivpn}/bin/openfortivpn";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Enable NetworkManager OpenConnect plugin (supports Fortinet SSL VPN protocol natively)
    # and OpenVPN plugin
    networking.networkmanager.plugins = with pkgs; [
      networkmanager-openconnect
      networkmanager-openvpn
    ];

    # Example configuration file for openfortivpn
    environment.etc."openfortivpn/config.example".text = ''
      # OpenFortiVPN Example Configuration
      # Copy to /etc/openfortivpn/config (owned by root:root, mode 600)
      # host = vpn.example.com
      # port = 443
      # username = your_username
      # password = your_password
      # trusted-cert = <sha256-hash-shown-on-first-connect>
      # set-dns = 1
      # set-routes = 1
      # half-internet-routes = 0
    '';

    environment.systemPackages = with pkgs; [
      wireguard-tools
      networkmanagerapplet
      openfortivpn
      openconnect
      zenity
    ];
  };

  flake.nixosModules.vpn = self.nixosModules.wireguard;
}
