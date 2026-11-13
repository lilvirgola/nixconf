{self, ...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    imports = [
      self.nixosModules.antigravity
    ];

    # Modern Antigravity AI platform with native host execution (sudo enabled)
    programs.antigravity.enable = true;

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
      (python3.withPackages (ps:
        with ps; [
          pip
          dbus-python
          pygobject3
          cryptography
          pyopenssl
        ]))
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

      # API, gRPC, Protobuf & Automation
      protobuf
      buf
      grpcurl
      websocat
      act

      # Game Development
      godot_4

      # LaTeX & LuaTeX toolchain
      (texliveMedium.withPackages (ps: [
        ps.biber
        ps.chktex
      ]))
      texlab
      ltex-ls-plus

      # Containers & Linux lab environments
      docker-compose
      distrobox
    ];
  };
}
