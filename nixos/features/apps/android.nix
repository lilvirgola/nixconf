{
  flake.nixosModules.android = {pkgs, ...}: {
    # Android & Quest 3 device tooling (USB permissions handled by built-in systemd uaccess)
    environment.systemPackages = with pkgs; [
      # ADB, Fastboot, screen mirroring & MTP file transfer
      android-tools
      scrcpy
      android-file-transfer

      # USB reverse tethering
      gnirehtet

      # APK inspection, patching & dynamic instrumentation
      apktool
      apksigner
      frida-tools

      # Phone debloating & firmware extraction/flashing
      universal-android-debloater
      payload-dumper-go
      heimdall
    ];
  };
}
