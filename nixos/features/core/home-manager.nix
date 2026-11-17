{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.homeManagerCore = {config, ...}: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";

      users.${config.custom.username} = {
        imports = [
          ../../../home/core.nix
        ];
      };
    };
  };

  flake.nixosModules.homeManagerDesktop = {config, ...}: {
    imports = [
      self.nixosModules.homeManagerCore
    ];

    home-manager.users.${config.custom.username}.imports = [
      ../../../home/desktop.nix
    ];
  };
}
