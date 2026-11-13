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
      description = "LaTeX and LuaTeX project with TeX Live, texlab, and zathura";
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
    ctf-base = {
      path = ../templates/ctf-base;
      description = "CTF base environment with CLI analysis, forensics, and Python tooling";
    };
    ctf-pwn = {
      path = ../templates/ctf-pwn;
      description = "CTF binary exploitation workspace with Pwntools, Ropper, ROPgadget, one_gadget, GDB/GEF, and angr";
    };
    ctf-rev = {
      path = ../templates/ctf-rev;
      description = "CTF reverse engineering workspace with Ghidra, Rizin, Radare2, Jadx, Apktool, and Capstone";
    };
    ctf-crypto = {
      path = ../templates/ctf-crypto;
      description = "CTF cryptography workspace with gmpy2, sympy, z3-solver, pycryptodome, hashcat, and john";
    };
    ctf-web = {
      path = ../templates/ctf-web;
      description = "CTF web exploitation workspace with ffuf, sqlmap, nikto, gobuster, mitmproxy, and httpx";
    };
    ctf-osint = {
      path = ../templates/ctf-osint;
      description = "CTF OSINT & reconnaissance workspace with sherlock, theHarvester, holehe, socialscan, and volatility3";
    };
    ctf-network = {
      path = ../templates/ctf-network;
      description = "CTF network & PCAP analysis workspace with tshark, termshark, tcpdump, scapy, and pyshark";
    };
    ctf-full = {
      path = ../templates/ctf-full;
      description = "Complete all-in-one CTF workspace with pwn, rev, crypto, web, osint, and network tooling";
    };
    # Backward compatibility aliases
    pwn = {
      path = ../templates/ctf-pwn;
      description = "Alias for ctf-pwn";
    };
    reversing = {
      path = ../templates/ctf-rev;
      description = "Alias for ctf-rev";
    };
  };
}
