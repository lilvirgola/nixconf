{
  description = "OpenXR and VR development workspace (Godot 4, OpenXR SDK, Vulkan, C/C++, Rust)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      runtimeLibs = with pkgs; [
        openxr-loader
        vulkan-loader
        wayland
        libxkbcommon
        libGL
      ];
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          godot_4
          openxr-loader
          vulkan-headers
          vulkan-loader
          vulkan-tools
          wayland
          wayland-protocols
          libxkbcommon
          libGL
          pkg-config
          cmake
          ninja
          gcc
          clang-tools
          cargo
          rustc
          rust-analyzer
          clippy
          rustfmt
        ];

        env = {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };

        shellHook = ''
          echo "OpenXR devShell active ($(godot4 --version 2>/dev/null || echo 'godot4'), openxr-loader ready). Use 'nvidia-offload godot4' on PRIME laptops."
        '';
      };
    });
  };
}
