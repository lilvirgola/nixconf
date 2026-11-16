{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.isoConfiguration
    ];
  };

  perSystem = {system, ...}: {
    packages = lib.optionalAttrs (system == "x86_64-linux") {
      iso = self.nixosConfigurations.iso.config.system.build.isoImage;
    };
  };
}
