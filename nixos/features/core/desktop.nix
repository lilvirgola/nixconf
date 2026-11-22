{self, ...}: {
  flake.nixosModules.desktop = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.homeManagerDesktop
    ];

    security.polkit.enable = true;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
    programs.seahorse.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;

    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = ["JetBrains Mono Nerd Font" "Noto Color Emoji"];
          sansSerif = ["Noto Sans" "Noto Color Emoji"];
          serif = ["Noto Serif" "Noto Color Emoji"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };

    networking.networkmanager.enable = true;

    services.xserver.xkb = {
      layout = config.custom.keyboardLayout;
      variant = "";
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    users.users.${config.custom.username}.extraGroups = [
      "networkmanager"
      "video"
      "audio"
      "input"
    ];

    environment.sessionVariables = {
      XCURSOR_THEME = config.custom.theme.cursorTheme;
      XCURSOR_SIZE = toString config.custom.theme.cursorSize;
      GTK_THEME = config.custom.theme.gtkTheme;
    };

    environment.systemPackages = with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myKitty
      self.packages.${pkgs.stdenv.hostPlatform.system}.keyhints
      alacritty
      libsecret
      playerctl
      brightnessctl
      gparted
    ];
  };
}
