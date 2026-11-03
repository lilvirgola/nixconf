{
  flake.nixosModules.services = {
    pkgs,
    lib,
    ...
  }: {
    # 1. Mesh & Privacy VPNs
    services.tailscale.enable = true;
    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    # 2. Local AI / Ollama with CUDA acceleration
    # Down on boot by default (0 VRAM idle) — start on-demand with `ollama-up`
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      host = "127.0.0.1";
      port = 11434;
    };
    systemd.services.ollama.wantedBy = lib.mkForce [];

    # Allow virgola to start/stop ollama without password prompt
    security.sudo.extraRules = [
      {
        users = ["virgola"];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl start ollama";
            options = ["NOPASSWD"];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl stop ollama";
            options = ["NOPASSWD"];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl restart ollama";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # 3. Virtualization (QEMU/KVM & Virt-Manager)
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };
      };
    };
    programs.virt-manager.enable = true;

    # 4. Printing (Brother HL-1210W via brlaser driver & CUPS)
    services.printing = {
      enable = true;
      drivers = [pkgs.brlaser];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # 5. Game Controllers & Gamepads (DualSense / Switch / Xbox)
    hardware.steam-hardware.enable = true;
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
      dualsensectl
    ];
  };
}

