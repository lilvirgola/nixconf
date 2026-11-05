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
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # Packet analysis & Capturing
          wireshark-cli  # tshark
          termshark
          tcpdump
          nmap
          socat

          # Python packet parsing & network forensics
          (python3.withPackages (ps: [
            ps.scapy
            ps.pyshark
            ps.dpkt
            ps.pwntools
            ps.requests
            ps.httpx
          ]))
        ];

        shellHook = ''
          echo "CTF Network devShell active (tshark, termshark, tcpdump, scapy, pyshark)"
        '';
      };
    });
  };
}

