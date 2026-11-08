{
  description = "CTF Reverse Engineering (rev) workspace";

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
          capstone
          unicorn
          pefile
          pyelftools
          lief
          angr
          z3-solver
          r2pipe
          pwntools
          ipython
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pythonEnv
          ghidra-bin
          rizin
          radare2
          jadx
          apktool
          file
          binwalk
          hexyl
          gdb
          strace
          ltrace
          patchelf
        ];

        shellHook = ''
          echo "CTF Reverse Engineering devShell active (Ghidra, Rizin, Radare2, Jadx, Apktool)"
        '';
      };
    });
  };
}
