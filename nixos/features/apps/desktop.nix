{
  flake.nixosModules.desktopApps = {
    config,
    pkgs,
    lib,
    ...
  }: let
    blenderWithCuda = let
      cudaToolkit = pkgs.symlinkJoin {
        name = "blender-cuda-env";
        paths = [
          pkgs.cudaPackages.cuda_nvcc
          pkgs.cudaPackages.cuda_cudart
          pkgs.cudaPackages.cuda_crt
          pkgs.cudaPackages.cccl
        ];
      };
    in
      pkgs.symlinkJoin {
        name = "blender";
        paths = [pkgs.blender];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          rm $out/bin/blender
          makeWrapper ${pkgs.blender}/bin/blender $out/bin/blender \
            --prefix PATH : "${lib.makeBinPath [cudaToolkit]}" \
            --prefix CPATH : "${cudaToolkit}/include" \
            --set CUDA_PATH "${cudaToolkit}" \
            --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
            --set-default __NV_PRIME_RENDER_OFFLOAD 1 \
            --set-default __GLX_VENDOR_LIBRARY_NAME nvidia \
            --set-default __VK_LAYER_NV_optimus NVIDIA_only
        '';
      };
    blenderPkg =
      if config.custom.enableCuda
      then blenderWithCuda
      else pkgs.blender;
  in {
    programs.firefox.enable = true;

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.tumbler.enable = true;
    services.gvfs.enable = true;

    # GNOME Calendar backend storage & sync daemon
    services.gnome.evolution-data-server.enable = true;

    environment.systemPackages = with pkgs; [
      # GTK Themes & Icons
      adw-gtk3
      papirus-icon-theme
      bibata-cursors
      # Web Browsers
      librewolf

      # Music & Media
      spotify
      mpv
      vlc
      pavucontrol
      picard
      obs-studio
      yt-dlp

      # Communication & Notes
      vesktop
      telegram-desktop
      obsidian

      # Productivity & Office
      gnome-calendar
      libreoffice
      qalculate-gtk
      qbittorrent

      # Files, PDFs, Graphics & Screenshots
      gimp
      inkscape
      blenderPkg
      yazi
      zathura
      poppler-utils
      ffmpegthumbnailer
      grim
      slurp
      swappy
    ];
  };
}
