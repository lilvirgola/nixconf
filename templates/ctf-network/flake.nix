{
  description = "CTF Network & PCAP Forensics environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pythonEnv = pkgs.python3.withPackages (p:
        with p; [
          scapy
          pyshark
          dpkt
          requests
          httpx
          ipython
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          wireshark-cli
          termshark
          tcpdump
          nmap
          socat
          pythonEnv
        ];

        shellHook = ''
          echo "CTF Network devShell active (tshark, termshark, tcpdump, scapy, pyshark)"
        '';
      };
    });
  };
}
