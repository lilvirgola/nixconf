{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.vm-minimal = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vmMinimalConfiguration
    ];
  };

  perSystem = {system, ...}: {
    packages = lib.optionalAttrs (system == "x86_64-linux") {
      vm-minimal = self.nixosConfigurations.vm-minimal.config.system.build.vm;
    };
  };
}
