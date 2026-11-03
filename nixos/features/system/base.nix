{self, ...}: {
  flake.nixosModules.base = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.settings
      self.nixosModules.zsh
    ];

    # Automated Nix store garbage collection, deduplication, and low-disk guards
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024; # 5 GiB
      max-free = 10 * 1024 * 1024 * 1024; # 10 GiB
    };

    # Polkit authorization framework
    security.polkit.enable = true;

    # GNOME Keyring & Secret Service for storing credentials in VS Code, Git, and browsers
    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
    programs.seahorse.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;

    # System-wide fonts: Noto Color Emoji, CJK ideographs, and fontconfig fallbacks
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
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

    # ZRAM compressed in-memory swap to prevent OOM during builds
    zramSwap.enable = true;

    # Enable networking
    networking.networkmanager.enable = true;

    # Set system time zone from centralized settings
    time.timeZone = config.custom.timezone;

    # Select internationalisation properties
    i18n.defaultLocale = config.custom.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = config.custom.extraLocale;
      LC_IDENTIFICATION = config.custom.extraLocale;
      LC_MEASUREMENT = config.custom.extraLocale;
      LC_MONETARY = config.custom.extraLocale;
      LC_NAME = config.custom.extraLocale;
      LC_NUMERIC = config.custom.extraLocale;
      LC_PAPER = config.custom.extraLocale;
      LC_TELEPHONE = config.custom.extraLocale;
      LC_TIME = config.custom.extraLocale;
    };

    # Configure keymap in X11 / Wayland
    services.xserver.xkb = {
      layout = config.custom.keyboardLayout;
      variant = "";
    };

    # Configure console keymap
    console.keyMap = config.custom.consoleKeyMap;

    # Audio with PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Define primary user account from centralized settings
    users.users.${config.custom.username} = {
      isNormalUser = true;
      initialPassword = lib.mkDefault config.custom.initialPassword;
      description = config.custom.userDescription;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "audio"
        "docker"
        "wireshark"
        "libvirtd"
        "kvm"
        "input"
        "dialout"
        "uucp"
      ];
      packages = with pkgs; [];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Base packages and CLI power tools installed across all hosts
    environment.systemPackages = with pkgs; [
      vim
      neovim
      wget
      curl
      git
      gh
      kitty
      alacritty
      btop
      fastfetch
      ripgrep
      fd
      fzf
      unzip
      p7zip
      rbw
      bitwarden-cli
      libsecret
      jq
      playerctl
      brightnessctl
      gparted
      scrcpy
      self.packages.${pkgs.stdenv.hostPlatform.system}.ninit
      self.packages.${pkgs.stdenv.hostPlatform.system}.keyhints
    ];

    # Start SSH Agent as a systemd user service with $SSH_AUTH_SOCK
    programs.ssh.startAgent = true;

    # Enable direnv + nix-direnv for automatic per-project devShell loading
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Enable the OpenSSH daemon and nix-ld with dynamic libraries for uv/Python wheels & foreign binaries
    services.openssh.enable = lib.mkDefault true;
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      zstd
      xz
      bzip2
      openssl
      curl
      glib
      libsecret
      libGL
      libxkbcommon
      libxml2
      sqlite
      ncurses
      expat
      util-linux
    ];

    system.stateVersion = "26.05";
  };
}
