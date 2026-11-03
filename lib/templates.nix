{
  flake.templates = {
    python-uv = {
      path = ../templates/python-uv;
      description = "Python project with uv, ruff, pyright, and nix-ld dynamic library support";
    };
    go = {
      path = ../templates/go;
      description = "Go project with go, gopls, golangci-lint, and delve";
    };
    rust = {
      path = ../templates/rust;
      description = "Rust project with cargo, rustc, rust-analyzer, clippy, and rustfmt";
    };
    latex = {
      path = ../templates/latex;
      description = "LaTeX and LuaTeX project with TeX Live Full, tectonic, texlab, and zathura";
    };
    typescript = {
      path = ../templates/typescript;
      description = "TypeScript and Node.js 22 project with pnpm, tsc, and Biome";
    };
    c-cpp = {
      path = ../templates/c-cpp;
      description = "Modern C / C++ project with Clang, CMake, Ninja, GDB, and clang-tools";
    };
    embedded = {
      path = ../templates/embedded;
      description = "Embedded microcontroller project with PlatformIO, ARM GCC, and TinyGo";
    };
    php = {
      path = ../templates/php;
      description = "PHP project with modern PHP CLI and Composer";
    };
    pwn = {
      path = ../templates/pwn;
      description = "CTF and binary exploitation workspace with Pwntools, Ropper, Pycryptodome, and GDB";
    };
  };
}
