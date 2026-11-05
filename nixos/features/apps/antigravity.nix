{
  self,
  lib,
  ...
}: let
  # Factory to build Antigravity packages against a given pkgs instance
  mkAntigravityPackages = pkgs: let
    baseIde = pkgs.antigravity-ide.override {
      buildVscode = args:
        pkgs.buildVscode (args
          // {
            version = "2.6.0";
            vscodeVersion = "1.107.0";
            src = pkgs.fetchurl (
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
                pkgs.stdenv.hostPlatform.system
              }
              or (throw "antigravity-ide: unsupported system ${pkgs.stdenv.hostPlatform.system}")
            );
          });
    };

    antigravityIde = baseIde.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        ln -sf antigravity-ide $out/bin/antigravity
      '';
    });

    antigravityCli = pkgs.antigravity-cli.overrideAttrs (old: let
      version = "1.5.0";
      buildId = "5265121291927552";
      wholeVersion = "${version}-${buildId}";
      sourceData = {
        x86_64-linux = pkgs.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-x64/cli_linux_x64.tar.gz";
          hash = "sha256-Vh4jZkyl13MPDxvj7Dvdnfhdbzg6Ty2laQUCVsWUhds=";
        };
        aarch64-linux = pkgs.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-arm/cli_linux_arm64.tar.gz";
          hash = "sha256-ZAuTHiV3U4FIa9dSmFATcrW1G2134MB985nC1Vkao7o=";
        };
        aarch64-darwin = pkgs.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/darwin-arm/cli_mac_arm64.tar.gz";
          hash = "sha256-VsF7DkBQwKBmR4hVCz+UShJRPxMO7bf3wVOY5susSEQ=";
        };
      };
    in {
      inherit version;
      src = sourceData.${pkgs.stdenvNoCC.hostPlatform.system};
      passthru = (old.passthru or {}) // {
        inherit wholeVersion;
      };
      postInstall = (old.postInstall or "") + ''
        ln -sf agy $out/bin/antigravity-cli
      '';
    });
  in {
    ide = antigravityIde;
    cli = antigravityCli;
  };
in {
  perSystem = {pkgs, ...}: let
    packages = mkAntigravityPackages pkgs;
  in {
    packages = {
      antigravity-ide = packages.ide;
      antigravity-cli = packages.cli;
      agy = packages.cli;
    };
  };

  flake.nixosModules.antigravity = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.programs.antigravity;

    chosenIdePkg =
      if cfg.useFHS
      then pkgs.antigravity-ide.fhs
      else pkgs.antigravity-ide;
  in {
    options.programs.antigravity = {
      enable = lib.mkEnableOption "Antigravity AI Development Platform (IDE and CLI)";

      useFHS = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to run Antigravity IDE inside a Bubblewrap FHS sandbox.
          Defaults to false: running natively on the host with nix-ld and envfs,
          which allows SUID binaries like `sudo` to work in the integrated terminal
          without being blocked by PR_SET_NO_NEW_PRIVS.
        '';
      };

      enableSudo = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Ensure the integrated terminal and environment allow sudo without sandbox privilege restrictions.
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = chosenIdePkg;
        description = "Antigravity IDE package to install.";
      };

      cliPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.antigravity-cli;
        description = "Antigravity CLI package to install.";
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.enableSudo -> !cfg.useFHS;
          message = "Antigravity: `enableSudo = true` requires `useFHS = false` because Bubblewrap FHS sandboxing sets PR_SET_NO_NEW_PRIVS, preventing `sudo` from acquiring root privileges in the terminal.";
        }
      ];

      nixpkgs.overlays = [
        (final: prev: let
          p = mkAntigravityPackages prev;
        in {
          antigravity-ide = p.ide;
          antigravity-ide-fhs = p.ide.fhs;
          antigravity-ide-fhsWithPackages = p.ide.fhsWithPackages;
          antigravity-cli = p.cli;
        })
      ];

      environment.systemPackages = [
        cfg.package
        cfg.cliPackage
      ];
    };
  };
}

