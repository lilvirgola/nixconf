{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  xdg.configFile = {
    # Point Steam OpenVR runtime to xrizer so OpenVR games run through WiVRn/OpenXR
    "openvr/openvrpaths.vrpath".text = builtins.toJSON {
      config = ["/home/${osConfig.custom.username}/.local/share/Steam/config"];
      external_drivers = null;
      jsonid = "vrpathreg";
      log = ["/home/${osConfig.custom.username}/.local/share/Steam/logs"];
      runtime = ["${pkgs.xrizer}/lib/xrizer"];
      version = 1;
    };

    # Baseline WayVR defaults (loaded alphabetically before zz-saved-config.json5)
    "wayvr/conf.d/10-nixos.json5".text = builtins.toJSON ({
        default_curvature = 0.07;
        default_overlay_scale = 0.8;
      }
      // lib.optionalAttrs osConfig.custom.enableCuda {
        capture_method = "ScreenCopyCpu";
      });
  };
}
