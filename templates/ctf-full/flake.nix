{
  description = "Complete CTF All-in-One workspace (Pwn, Rev, Crypto, Web, OSINT, Network)";

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
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # Base Tools & Utilities
          git
          curl
          wget
          jq
          tmux
          p7zip
          unzip
          unrar
          upx
          file
          hexyl
          nasm
          patchelf
          binwalk
          socat
          netcat-gnu

          # Binary Exploitation (pwn)
          gdb
          gef
          checksec
          elfutils
          strace
          ltrace
          ropgadget
          one_gadget
          pwninit
          qemu-user

          # Reverse Engineering (rev)
          ghidra-bin
          rizin
          radare2
          jadx
          apktool

          # Cryptography (crypto)
          hashcat
          john
          z3
          openssl

          # Web Exploitation (web)
          ffuf
          gobuster
          sqlmap
          nikto
          mitmproxy
          nmap

          # Network Analysis (network)
          wireshark-cli # tshark
          termshark
          tcpdump

          # OSINT & Forensics (osint)
          exiftool
          volatility3
          sherlock
          theharvester
          holehe
          socialscan
          maigret

          # Unified Python Security Stack
          (python3.withPackages (ps: [
            # Pwn & Binary
            ps.pwntools
            ps.angr
            ps.ropper
            ps.keystone-engine

            # Reversing
            ps.capstone
            ps.unicorn
            ps.pefile
            ps.pyelftools
            ps.lief
            ps.r2pipe

            # Crypto & Math
            ps.pycryptodome
            ps.cryptography
            ps.gmpy2
            ps.sympy
            ps.z3-solver
            ps.numpy

            # Network
            ps.scapy
            ps.pyshark
            ps.dpkt

            # Web & Scraping
            ps.requests
            ps.httpx
            ps.beautifulsoup4
            ps.websockets

            # Utilities
            ps.ipython
            ps.tqdm
          ]))
        ];

        shellHook = ''
          echo "=================================================================="
          echo "   CTF All-in-One Full Box (ctf-full) devShell active"
          echo "   Pwn | Rev | Crypto | Web | Network | OSINT"
          echo "=================================================================="
        '';
      };
    });
  };
}
