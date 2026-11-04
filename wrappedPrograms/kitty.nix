{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.myKitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;
      settings = {
        confirm_os_window_close = 0;
      };
    };
  };
}
