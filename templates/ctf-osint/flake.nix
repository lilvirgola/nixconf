{
  description = "CTF OSINT & Forensics Reconnaissance environment";

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
          requests
          httpx
          beautifulsoup4
          volatility3
          exiftool
          holehe
          socialscan
          sherlock
          maigret
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pythonEnv
          theharvester
          exiftool
          whois
          dnsutils
          curl
          wget
          jq
        ];

        shellHook = ''
          echo "CTF OSINT devShell active (sherlock, theHarvester, holehe, volatility3)"
        '';
      };
    });
  };
}
