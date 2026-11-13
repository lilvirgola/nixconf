{
  description = "CTF Binary Exploitation (pwn) environment";

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
          pwntools
          ropper
          pycryptodome
          angr
          z3-solver
          keystone-engine
          capstone
          unicorn
          pefile
          pyelftools
          scapy
          requests
          httpx
          ipython
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pythonEnv
          gdb
          gef
          ltrace
          strace
          ropgadget
          one_gadget
          (pwninit.overrideAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ [zstd];
          }))
          checksec
          patchelf
          nasm
          qemu-user
          file
          xxd
          socat
          netcat-gnu
        ];

        shellHook = ''
          echo "CTF Pwn devShell active (pwntools, gdb/gef, ropgadget, one_gadget, angr)"
        '';
      };
    });
  };
}
