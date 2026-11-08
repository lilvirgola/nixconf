{
  description = "CTF Web Exploitation (web) environment";

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
          websockets
          tqdm
          ipython
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          ffuf
          gobuster
          sqlmap
          nikto
          mitmproxy
          nmap
          socat
          curl
          wget
          pythonEnv
        ];

        shellHook = ''
          echo "CTF Web Exploitation devShell active (ffuf, sqlmap, nikto, gobuster, mitmproxy)"
        '';
      };
    });
  };
}
