{
  description = "C# / .NET 9 development environment";

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
          dotnetCorePackages.sdk_9_0
          omnisharp-roslyn
        ];

        env = {
          DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_9_0}";
        };

        shellHook = ''
          echo "C# / .NET devShell active (dotnet $(dotnet --version))"
        '';
      };
    });
  };
}

