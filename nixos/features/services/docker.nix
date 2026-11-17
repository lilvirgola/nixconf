{
  flake.nixosModules.docker = {config, ...}: {
    virtualisation.docker.enable = true;
    users.users.${config.custom.username}.extraGroups = ["docker"];
  };
}
