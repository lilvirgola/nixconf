{
  description = "Java (OpenJDK 21, Gradle, Maven) development environment";

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
          jdk
          gradle
          maven
        ];

        env = {
          JAVA_HOME = "${pkgs.jdk}";
        };

        shellHook = ''
          echo "Java devShell active ($(java -version 2>&1 | head -n1), Gradle $(gradle --version | grep Gradle | awk '{print $2}'))"
        '';
      };
    });
  };
}
