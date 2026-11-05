{
  description = "Rust GUI & Game Development environment (GPUI, Bevy, Egui, Winit)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      linuxLibs = with pkgs; [
        wayland
        wayland-protocols
        libxkbcommon
        libGL
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        fontconfig
        freetype
      ];
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          cargo
          rustc
          rust-analyzer
          clippy
          rustfmt
          pkg-config
          openssl
        ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux linuxLibs;

        env = {
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux linuxLibs);
        };

        shellHook = ''
          echo "Rust GUI devShell active ($(rustc --version), Wayland + Vulkan + Fontconfig configured)"
        '';
      };
    });
  };
}

