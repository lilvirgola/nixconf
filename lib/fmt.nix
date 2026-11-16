{
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;

    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        statix
        deadnix
        nixd
      ];

      shellHook = ''
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git config core.hooksPath .githooks
        fi
      '';
    };

    checks = {
      nix-fmt =
        pkgs.runCommand "nix-fmt-check" {
          nativeBuildInputs = [pkgs.alejandra];
        } ''
          if ! alejandra --check ${../.} 2>&1; then
            echo
            echo "Nix files are not alejandra-clean. Fix with: nix fmt"
            exit 1
          fi
          touch $out
        '';

      nix-lint =
        pkgs.runCommand "nix-lint-check" {
          nativeBuildInputs = [pkgs.statix pkgs.deadnix];
        } ''
          statix check -c ${../statix.toml} ${../.}
          deadnix --fail ${../.}
          touch $out
        '';
    };
  };
}
