{self, ...}: {
  flake.nixosModules.base = {pkgs, ...}: {
    imports = [
      self.nixosModules.zsh
    ];

    nix.settings.experimental-features = ["nix-command" "flakes"];

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

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."virgola" = {
      isNormalUser = true;
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
    ];

    # Start SSH Agent as a systemd user service with $SSH_AUTH_SOCK
    programs.ssh.startAgent = true;

    # Enable direnv + nix-direnv for automatic per-project devShell loading
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Enable the OpenSSH daemon and nix-ld with dynamic libraries for uv/Python wheels & foreign binaries
    services.openssh.enable = true;
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
