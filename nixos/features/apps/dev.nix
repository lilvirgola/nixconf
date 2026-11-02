{
  flake.nixosModules.dev = {pkgs, ...}: {
    virtualisation.docker.enable = true;

    environment.sessionVariables = {
      UV_PYTHON_DOWNLOADS = "automatic";
    };

    environment.systemPackages = with pkgs; [
      # Python & uv
      uv
      python3
      ruff
      pyright

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

      # LaTeX & LuaTeX toolchain
      (texliveMedium.withPackages (ps: [
        ps.biber
        ps.chktex
      ]))
      tectonic
      texlab
      ltex-ls-plus

      # Containers & Linux lab environments
      distrobox

      # Antigravity AI Development Platform & CLI
      antigravity-ide-fhs
      antigravity-cli
    ];
  };
}
