{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    configDir = pkgs.runCommand "noctalia-config-dir" {} ''
      mkdir -p $out/noctalia
      cp ${./noctalia.toml} $out/noctalia/config.toml
    '';

    wrappedNoctalia =
      (pkgs.symlinkJoin {
        name = "noctalia-${pkgs.noctalia.version}";
        paths = [pkgs.noctalia];
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        postBuild = ''
          wrapProgram $out/bin/noctalia \
            --set-default NOCTALIA_CONFIG_HOME "${configDir}"
        '';
      })
      .overrideAttrs (old: {
        meta =
          (old.meta or {})
          // {
            mainProgram = "noctalia";
          };
      });
  in {
    packages.myNoctalia = wrappedNoctalia;
  };
}
