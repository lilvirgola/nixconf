{
  flake.nixosModules.nvidia = {
    config,
    pkgs,
    ...
  }: {
    # Accelerated Graphics Driver & 32-bit libraries for Steam/Wine
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-utils
      ];
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Hybrid Graphics PRIME Offload (AMD Lucienne/Cezanne + NVIDIA RTX 3050 Ti Mobile)
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:5:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
