{self, ...}: {
  flake.nixosModules.base = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
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

    # Set your time zone.
    time.timeZone = "Europe/Rome";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "it_IT.UTF-8";
      LC_IDENTIFICATION = "it_IT.UTF-8";
      LC_MEASUREMENT = "it_IT.UTF-8";
      LC_MONETARY = "it_IT.UTF-8";
      LC_NAME = "it_IT.UTF-8";
      LC_NUMERIC = "it_IT.UTF-8";
      LC_PAPER = "it_IT.UTF-8";
      LC_TELEPHONE = "it_IT.UTF-8";
      LC_TIME = "it_IT.UTF-8";
    };

    # Configure keymap in X11 / Wayland
    services.xserver.xkb = {
      layout = "it";
      variant = "";
    };

    # Configure console keymap
    console.keyMap = "it2";

    # Audio with PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Define a user account with an initial default password ("nixos")
    users.users."virgola" = {
      isNormalUser = true;
      initialPassword = "nixos";
      description = "Alessandro";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "audio"
        "docker"
        "wireshark"
      ];
      packages = with pkgs; [];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Base packages and CLI power tools installed across all hosts
    environment.systemPackages = with pkgs; [
      vim
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
      jq
      playerctl
      brightnessctl
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
