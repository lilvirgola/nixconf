{self, ...}: {
  flake.nixosModules.core = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.settings
    ];

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
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 10 * 1024 * 1024 * 1024;
    };

    zramSwap.enable = true;

    time.timeZone = config.custom.timezone;
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
    console.keyMap = config.custom.consoleKeyMap;

    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    users.users.${config.custom.username} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      initialPassword = lib.mkDefault config.custom.initialPassword;
      description = config.custom.userDescription;
      openssh.authorizedKeys.keys = config.custom.sshAuthorizedKeys;
      extraGroups = ["wheel"];
    };

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      vim
      neovim
      wget
      curl
      git
      gh
      btop
      fastfetch
      ripgrep
      fd
      fzf
      unzip
      p7zip
      jq
      lsd
      lolcat
      gnupg
      pinentry-curses
      rbw
      bitwarden-cli
      self.packages.${pkgs.stdenv.hostPlatform.system}.ninit
      self.packages.${pkgs.stdenv.hostPlatform.system}.kssh
      self.packages.${pkgs.stdenv.hostPlatform.system}.ssh-vault
      self.packages.${pkgs.stdenv.hostPlatform.system}.deploy
    ];

    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        Host *
          ForwardAgent yes
          AddKeysToAgent yes
      '';
    };
    systemd.user.settings.Manager.DefaultEnvironment = "SSH_AUTH_SOCK=%t/ssh-agent";
    systemd.user.services.ssh-agent.postStart = "${pkgs.systemd}/bin/systemctl --user set-environment SSH_AUTH_SOCK=%t/ssh-agent";

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    services.openssh = {
      enable = lib.mkDefault true;
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        KbdInteractiveAuthentication = lib.mkDefault false;
      };
    };

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        zstd
        xz
        bzip2
        openssl
        curl
        glib
        libxml2
        sqlite
        ncurses
        expat
        util-linux
      ];
    };

    services.envfs.enable = true;

    system.stateVersion = "26.05";
  };
}
