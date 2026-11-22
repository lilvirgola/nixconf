{
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

    # OpenVR-to-OpenXR compatibility layer and ADB tooling for wired USB Quest debugging/tethering
    environment.systemPackages = with pkgs; [
      xrizer
      android-tools
    ];
  };
}
