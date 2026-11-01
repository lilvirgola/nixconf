{
  flake.nixosModules.nvidia = {config, ...}: {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # If your laptop uses hybrid graphics (Nvidia Optimus), uncomment and set your PCI Bus IDs:
      # prime = {
      #   offload = {
      #     enable = true;
      #     enableOffloadCmd = true;
      #   };
      #   intelBusId = "PCI:0:2:0";
      #   nvidiaBusId = "PCI:1:0:0";
      # };
    };
  };
}
