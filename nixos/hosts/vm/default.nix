{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vmConfiguration
    ];
  };

  perSystem = {system, ...}: {
    packages = lib.optionalAttrs (system == "x86_64-linux") {
      vm = self.nixosConfigurations.vm.config.system.build.vm;
    };
  };
}
