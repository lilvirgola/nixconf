{
  flake.nixosModules.security = {pkgs, ...}: {
    # Enables Wireshark with dumpcap permissions for users in the "wireshark" group
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    environment.systemPackages = with pkgs; [
      # Decompilers, Disassemblers & Hex Editors
      ghidra
      cutter
      rizin
      radare2
      imhex

      # Debuggers & Binary Exploitation (Pwn)
      gdb
      pwndbg
      checksec
      patchelf
      binwalk
      ltrace
      strace
      file
      unixtools.xxd
      ropgadget
      one_gadget

      # Network & Web Security
      nmap
      netcat-gnu
      gobuster
      burpsuite
    ];
  };
}
