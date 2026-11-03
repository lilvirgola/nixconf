{
  description = "Embedded microcontroller (PlatformIO, ARM GCC, TinyGo) development environment";

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
          platformio
          gcc-arm-embedded
          tinygo
          avrdude
          openocd
        ];

        shellHook = ''
          echo "Embedded Microcontroller devShell active (PlatformIO $(pio --version))"
        '';
      };
    });
  };
}
