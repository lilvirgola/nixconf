{
  description = "LaTeX & LuaTeX development environment";

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
          (texliveMedium.withPackages (ps: [
            ps.biber
            ps.chktex
          ]))
          texlab
          zathura
        ];

        shellHook = ''
          echo "LaTeX devShell active (LuaTeX, TeX Live, Texlab, Zathura)"
        '';
      };
    });
  };
}
