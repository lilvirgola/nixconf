{self, ...}: {
  flake.nixosModules.vr = {
    config,
    pkgs,
    lib,
    ...
  }: let
    wivrnPkg =
      if config.custom.enableCuda
      then pkgs.wivrn.override {cudaSupport = true;}
      else pkgs.wivrn;
  in {
    imports = [
      self.nixosModules.android
    ];

    # Wireless PCVR streaming for Meta Quest 3 (start on-demand via `wivrn-dashboard`)
    services.wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = false;
      highPriority = true;
      steam.importOXRRuntimes = true;
      package = wivrnPkg;
      monadoEnvironment = lib.optionalAttrs config.custom.enableCuda {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };

    # Ensure mDNS discovery port is open even on hosts without printing enabled
    services.avahi.openFirewall = lib.mkDefault true;

    # Virtual desktop overlay and OpenVR-to-OpenXR compatibility
    environment.systemPackages = with pkgs; [
      wayvr
      xrizer
    ];

    # Point Steam OpenVR runtime to xrizer so OpenVR games run through WiVRn/OpenXR
    home-manager.users.${config.custom.username}.xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
      config = ["/home/${config.custom.username}/.local/share/Steam/config"];
      external_drivers = null;
      jsonid = "vrpathreg";
      log = ["/home/${config.custom.username}/.local/share/Steam/logs"];
      runtime = ["${pkgs.xrizer}/lib/xrizer"];
      version = 1;
    };
  };
}
