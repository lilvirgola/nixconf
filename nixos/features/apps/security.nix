{inputs, ...}: {
  flake.nixosModules.security = {pkgs, ...}: let
    ghidraAuto =
      pkgs.writers.writePython3Bin "ghidra-auto" {
        libraries = with pkgs.python3Packages; [click];
      } (builtins.replaceStrings
        ["os.environ.get('GHIDRA_PATH', '/opt/ghidra/')"]
        ["os.environ.get('GHIDRA_PATH', '${pkgs.ghidra}/lib/ghidra/')"]
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
      cutter
      rizin
      radare2
      imhex

      # Debuggers & Binary Exploitation (Pwn)
      gdb
      inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default
      pwninit
      pwninitGhidra
      python3Packages.pwntools
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
