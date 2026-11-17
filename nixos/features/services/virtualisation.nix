{
  flake.nixosModules.virtualisation = {
    config,
    pkgs,
    ...
  }: {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;

    users.users.${config.custom.username}.extraGroups = [
      "libvirtd"
      "kvm"
    ];
  };
}
