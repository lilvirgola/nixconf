{
  description = "Cyber Security, Binary Exploitation & CTF development environment";

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
          # Python + Exploitation & Cryptography
          (python3.withPackages (ps: [
            ps.pwntools
            ps.pycryptodome
            ps.ropper
          ]))

          # Binary Analysis & Debugging
          gdb
          checksec
          patchelf
          elfutils
          strace
          ltrace
          one_gadget
          ropgadget
          socat
        ];

        shellHook = ''
          echo "Binary Exploitation & CTF devShell active (Pwntools, Ropper, Pycryptodome, GDB)"
        '';
      };
    });
  };
}
