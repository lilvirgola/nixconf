{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    configDir = pkgs.runCommand "noctalia-config-dir" {} ''
      mkdir -p $out/noctalia
      substitute ${./noctalia.toml} $out/noctalia/config.toml \
        --replace-fail "@ASTRONAUT_WALLPAPER@" "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme/Backgrounds/astronaut.png"
    '';

    wrappedNoctalia =
      (pkgs.symlinkJoin {
        name = "noctalia-${pkgs.noctalia.version}";
        paths = [pkgs.noctalia];
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        postBuild = ''
          wrapProgram $out/bin/noctalia \
            --set-default NOCTALIA_CONFIG_HOME "${configDir}" \
            --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [zenity networkmanager networkmanagerapplet])}
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
