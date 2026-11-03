{
  description = "Modern C / C++ development environment";

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
          # Compilers & Toolchain
          clang
          gcc
          cmake
          ninja
          pkg-config

          # Debuggers & Analysis
          gdb
          valgrind
          clang-tools
        ];

        shellHook = ''
          echo "C / C++ devShell active (CMake $(cmake --version | head -n1), Clang $(clang --version | head -n1))"
        '';
      };
    });
  };
}
