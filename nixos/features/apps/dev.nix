{
  flake.nixosModules.dev = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: {
        antigravity-ide = prev.antigravity-ide.override {
          buildVscode = args:
            prev.buildVscode (args
              // {
                version = "2.6.0";
                vscodeVersion = "1.107.0";
                src = prev.fetchurl (
                  {
                    x86_64-linux = {
                      url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.6.0-5526304964083712/linux-x64/Antigravity%20IDE.tar.gz";
                      sha256 = "b060a7c7679103b2b619752f8ee7a3088dd241a7d207d4311974b56ea6f94356";
                    };
                    aarch64-linux = {
                      url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.6.0-5526304964083712/linux-arm/Antigravity%20IDE.tar.gz";
                      sha256 = "4953ccb52bf909582a1711a3dd26d640efb45fe555a17ebeff8bc7e2eaa052de";
                    };
                    aarch64-darwin = {
                      url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.6.0-5526304964083712/darwin-arm/Antigravity%20IDE.zip";
                      sha256 = "56fe0853adb76cb6f0e77df5e6bcc739216eb0bfc290b605b5576a1b335d4a47";
                    };
                  }.${
                    prev.stdenv.hostPlatform.system
                  }
                  or (throw "antigravity-ide: unsupported system ${prev.stdenv.hostPlatform.system}")
                );
              });
        };
        antigravity-ide-fhs = final.antigravity-ide.fhs;
        antigravity-ide-fhsWithPackages = final.antigravity-ide.fhsWithPackages;

        antigravity-cli = prev.antigravity-cli.overrideAttrs (_: let
          version = "1.5.0";
          buildId = "5265121291927552";
          wholeVersion = "${version}-${buildId}";
          sourceData = {
            x86_64-linux = prev.fetchurl {
              url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-x64/cli_linux_x64.tar.gz";
              hash = "sha256-Vh4jZkyl13MPDxvj7Dvdnfhdbzg6Ty2laQUCVsWUhds=";
            };
            aarch64-linux = prev.fetchurl {
              url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-arm/cli_linux_arm64.tar.gz";
              hash = "sha256-ZAuTHiV3U4FIa9dSmFATcrW1G2134MB985nC1Vkao7o=";
            };
            aarch64-darwin = prev.fetchurl {
              url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/darwin-arm/cli_mac_arm64.tar.gz";
              hash = "sha256-VsF7DkBQwKBmR4hVCz+UShJRPxMO7bf3wVOY5susSEQ=";
            };
          };
        in {
          inherit version;
          src = sourceData.${prev.stdenvNoCC.hostPlatform.system};
          passthru = {
            inherit wholeVersion;
          };
        });
      })
    ];

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
