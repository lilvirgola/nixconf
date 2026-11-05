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
    rust-gui = {
      path = ../templates/rust-gui;
      description = "Rust GUI & game dev project (GPUI, Bevy, Egui, Winit) with Wayland, Vulkan, and fontconfig";
    };
    zig = {
      path = ../templates/zig;
      description = "Zig project with zig compiler, zls language server, and GDB";
    };
    typst = {
      path = ../templates/typst;
      description = "Typst document project with typst compiler, typstyle formatter, and tinymist LSP";
    };
    latex = {
      path = ../templates/latex;
      description = "LaTeX and LuaTeX project with TeX Live Full, tectonic, texlab, and zathura";
    };
    typescript = {
      path = ../templates/typescript;
      description = "TypeScript and Node.js 22 project with pnpm, tsc, and Biome";
    };
    bun = {
      path = ../templates/bun;
      description = "Bun high-performance JavaScript & TypeScript project";
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
    shell = {
      path = ../templates/shell;
      description = "Bash / POSIX shell scripting project with shellcheck and shfmt";
    };
    java = {
      path = ../templates/java;
      description = "Java project with OpenJDK 21, Gradle, and Maven";
    };
    csharp = {
      path = ../templates/csharp;
      description = "C# / .NET 9 project with dotnet SDK and omnisharp";
    };
    elixir = {
      path = ../templates/elixir;
      description = "Elixir project with Erlang/OTP, Elixir, and Rebar3";
    };
    haskell = {
      path = ../templates/haskell;
      description = "Haskell project with GHC, Cabal, and Haskell Language Server (HLS)";
    };
    nix = {
      path = ../templates/nix;
      description = "Nix flake and packaging workspace with nixd LSP, statix linter, and alejandra formatter";
    };
    pwn = {
      path = ../templates/pwn;
      description = "CTF & binary exploitation workspace with Pwntools, Ropper, ROPgadget, one_gadget, GDB, and socat";
    };
    reversing = {
      path = ../templates/reversing;
      description = "Reverse engineering workspace with Radare2, Rizin, Ghidra, Hexyl, Capstone, and Unicorn";
    };
    ctf-web = {
      path = ../templates/ctf-web;
      description = "CTF web exploitation workspace with ffuf, sqlmap, mitmproxy, socat, requests, and httpx";
    };
    ctf-crypto = {
      path = ../templates/ctf-crypto;
      description = "CTF cryptography workspace with gmpy2, sympy, z3-solver, pycryptodome, and hashcat";
    };
    ctf-network = {
      path = ../templates/ctf-network;
      description = "CTF network & PCAP analysis workspace with tshark, termshark, tcpdump, scapy, and pyshark";
    };
  };
}
