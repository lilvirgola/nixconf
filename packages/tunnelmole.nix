{...}: {
  perSystem = {pkgs, ...}: {
    packages.tunnelmole = pkgs.stdenv.mkDerivation {
      pname = "tunnelmole";
      version = "2.4.0";
      src = pkgs.fetchurl {
        url = "https://tunnelmole.com/downloads/tmole-linux.gz";
        sha256 = "d8d2a6f25ecee80b785d56e326d8ffb3a419fa0cdcdaff6a67c879f49595f83d";
      };
      nativeBuildInputs = [pkgs.gzip];
      dontUnpack = true;
      dontPatchELF = true;
      dontStrip = true;
      installPhase = ''
        mkdir -p $out/bin
        gzip -dc $src > $out/bin/tmole
        chmod +x $out/bin/tmole
        ln -s $out/bin/tmole $out/bin/tunnelmole
      '';
    };
  };
}
