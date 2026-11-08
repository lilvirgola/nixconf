{
  description = "CTF Base environment with essential CLI, forensics, and analysis tooling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pythonEnv = pkgs.python3.withPackages (p:
        with p; [
          pwntools
          pyelftools
          requests
          httpx
          beautifulsoup4
          tqdm
          ipython
        ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pythonEnv
          file
          binwalk
          exiftool
          foremost
          testdisk
          gdb
          strace
          ltrace
          patchelf
          nasm
          xxd
          hexedit
          p7zip
          unrar
          unzip
          socat
          netcat-gnu
          curl
          wget
        ];

        shellHook = ''
          echo "CTF Base devShell active (pwntools, binwalk, gdb, forensics)"
        '';
      };
    });
  };
}
