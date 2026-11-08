{
  description = "CTF Cryptography (crypto) environment";

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
          pycryptodome
          cryptography
          gmpy2
          sympy
          z3-solver
          numpy
          scipy
          pwntools
          tqdm
          ipython
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          openssl
          hashcat
          john
          z3
          pythonEnv
        ];

        shellHook = ''
          echo "CTF Cryptography devShell active (gmpy2, sympy, z3-solver, pycryptodome, hashcat)"
        '';
      };
    });
  };
}
