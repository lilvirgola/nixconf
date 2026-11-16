{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.raspberrypi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.raspberrypiConfiguration
    ];
  };

  perSystem = {system, ...}: {
    packages = lib.optionalAttrs (system == "aarch64-linux") {
      raspberrypi-sd = self.nixosConfigurations.raspberrypi.config.system.build.sdImage;
    };
  };
}
