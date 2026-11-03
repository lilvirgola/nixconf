{
  description = "PHP 8.4 + Composer development environment";

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
          php
          phpPackages.composer
        ];

        shellHook = ''
          echo "PHP + Composer devShell active ($(php -v | head -n1), Composer $(composer --version | head -n1))"
        '';
      };
    });
  };
}
