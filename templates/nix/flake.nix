{
  description = "Nix development & packaging environment";

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
          nixd
          statix
          deadnix
          alejandra
          nix-output-monitor
          nvd
        ];

        shellHook = ''
          echo "Nix devShell active (LSP: nixd, Formatter: alejandra, Linter: statix)"
        '';
      };
    });
  };
}
