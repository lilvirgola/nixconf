{
  description = "Reverse Engineering & Binary Analysis workspace";

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
          # Disassemblers & Decompilers
          radare2
          rizin
          ghidra-bin

          # Binary inspection & Dumpers
          file
          binwalk
          hexyl
          gdb
          ltrace
          strace
          patchelf
          elfutils

          # Python reverse engineering tooling
          (python3.withPackages (ps: [
            ps.capstone
            ps.unicorn
            ps.pefile
            ps.pyelftools
            ps.pwntools
            ps.pycryptodome
            ps.ropper
          ]))
        ];

        shellHook = ''
          echo "Reverse Engineering devShell active (Rizin, Radare2, Ghidra, Hexyl, Capstone)"
        '';
      };
    });
  };
}

