{
  flake.nixosModules.dev = {pkgs, ...}: {
    virtualisation.docker.enable = true;

    # PlatformIO microcontroller udev rules (ESP32, STM32, Arduino)
    services.udev.packages = with pkgs; [
      platformio-core.udev
    ];

    environment.sessionVariables = {
      UV_PYTHON_DOWNLOADS = "automatic";
    };

    environment.systemPackages = with pkgs; [
      # Python & uv
      uv
      python3
      python3Packages.pip
      ruff
      pyright

      # Node.js, Web & TypeScript
      nodejs_22
      pnpm
      typescript
      php

      # Java JDK (LTS 21)
      jdk21

      # Code Editors & IDEs
      vscode

      # Go
      go
      gopls
      golangci-lint
      delve

      # Rust (rustup manages cargo, rustc, rust-analyzer, clippy, rustfmt)
      rustup

      # C/C++ & Build toolchains
      gcc
      clang
      gnumake
      cmake
      pkg-config
      ninja

      # Embedded Hardware & Microcontrollers
      gcc-arm-embedded
      platformio
      tinygo

      # Software Defined Radio (SDR) & Signal Analysis
      gnuradio
      inspectrum
      sigdigger

      # Game Development & Automation
      godot_4
      act
      grpcurl
      websocat
      protobuf

      # LaTeX & LuaTeX toolchain
      (texliveMedium.withPackages (ps: [
        ps.biber
        ps.chktex
      ]))
      tectonic
      texlab
      ltex-ls-plus

      # Containers & Linux lab environments
      docker-compose
      distrobox

      # Antigravity AI Development Platform & CLI
      antigravity-ide-fhs
      antigravity-cli
    ];
  };
}
