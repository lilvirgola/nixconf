{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.security = {pkgs, ...}: let
    ghidraAuto =
      pkgs.writers.writePython3Bin "ghidra-auto" {
        libraries = with pkgs.python3Packages; [click];
      } (builtins.replaceStrings
        [''"/opt/ghidra/"'']
        [''"${pkgs.ghidra}/lib/ghidra/"'']
        (builtins.readFile ../../../assets/pwn/ghidra.py));

    pwninitGhidra = pkgs.writeShellScriptBin "pwninit-ghidra" (
      builtins.replaceStrings ["@templatePath@"] ["${../../../assets/pwn/pwninit-template.py}"] (builtins.readFile ../../../assets/pwn/pwninit-ghidra.sh)
    );
  in {
    # Enables Wireshark with dumpcap permissions for users in the "wireshark" group
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    environment.systemPackages = with pkgs; [
      # Decompilers, Disassemblers & Hex Editors
      ghidra
      ghidraAuto
      jadx
      rizin
      radare2
      imhex

      # Debuggers, Binary Exploitation (Pwn) & Reverse Engineering
      gdb
      inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default
      pwninit
      pwninitGhidra
      python3Packages.pwntools
      python3Packages.ropper
      ropgadget
      one_gadget
      ruby
      rubyPackages.seccomp-tools
      checksec
      patchelf
      elfutils
      bpftrace
      ht
      ltrace
      strace
      file
      unixtools.xxd

      # Steganography, File Analysis & Password Cracking
      binwalk
      stegsolve
      zsteg
      john

      # Network, Packet & Traffic Analysis
      tshark
      termshark
      python3Packages.pyshark
      nmap
      netcat-gnu

      # Web Security, API Testing & Tunneling
      burpsuite
      postman
      gobuster
      ngrok
      self.packages.${pkgs.stdenv.hostPlatform.system}.tunnelmole

      # Cryptography & Mathematical Analysis
      sage
      python3Packages.pycryptodome
      self.packages.${pkgs.stdenv.hostPlatform.system}.mtp
    ];
  };
}
