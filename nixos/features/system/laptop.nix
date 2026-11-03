{
  flake.nixosModules.laptopFeatures = {pkgs, ...}: {
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;

    # MediaTek MT7921 Bluetooth firmware reset after suspend/resume
    systemd.services.mt7921-bt-resume = {
      description = "Fix MT7921 Bluetooth after resume";
      after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
      wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.kmod}/bin/modprobe -r btusb";
        ExecStart = "${pkgs.kmod}/bin/modprobe btusb";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl restart bluetooth";
      };
    };

    # Bluetooth & Blueman manager
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    # ELAN Fingerprint reader (04f3:0c4f)
    services.fprintd.enable = true;

    # Logitech Bolt / Unifying wireless receiver daemon & GUI (Solaar)
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    # Filesystem drivers: Btrfs and NTFS (for external drives)
    boot.supportedFilesystems = ["btrfs" "ntfs"];

    # Power management & Lid switch
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
    };
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
      acpi
      solaar
    ];
  };
}
