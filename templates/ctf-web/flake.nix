{
  description = "CTF Web Exploitation & Pentesting environment";

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
          # Web scanning & fuzzing
          ffuf
          sqlmap
          mitmproxy
          socat
          curl
          wget

          # Python web exploitation
          (python3.withPackages (ps: [
            ps.requests
            ps.httpx
            ps.beautifulsoup4
            ps.pycryptodome
            ps.pwntools
            ps.websockets
          ]))
        ];

        shellHook = ''
          echo "CTF Web Exploitation devShell active (ffuf, sqlmap, mitmproxy, httpx)"
        '';
      };
    });
  };
}

