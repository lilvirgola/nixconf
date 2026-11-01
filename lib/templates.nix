{
  flake.templates = {
    python-uv = {
      path = ../templates/python-uv;
      description = "Python project with uv and nix-ld dynamic library support";
    };
    go = {
      path = ../templates/go;
      description = "Go project with go, gopls, golangci-lint, and delve";
    };
    rust = {
      path = ../templates/rust;
      description = "Rust project with cargo, rustc, rust-analyzer, clippy, and rustfmt";
    };
  };
}
