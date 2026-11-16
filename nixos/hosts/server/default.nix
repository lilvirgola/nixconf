{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.serverConfiguration
    ];
  };
}
