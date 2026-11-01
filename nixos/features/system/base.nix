{
  flake.nixosModules.base = {pkgs, ...}: {
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
      extraGroups = ["networkmanager" "wheel" "video" "audio"];
      packages = with pkgs; [];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Base packages installed across all hosts
    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      kitty
      alacritty
    ];

    # Enable the OpenSSH daemon and nix-ld
    services.openssh.enable = true;
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # dynamic libs go here
    ];

    system.stateVersion = "26.05";
  };
}
