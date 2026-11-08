# Feature modules in nixos/features/

Files under `nixos/features/` define reusable NixOS modules exposed under `flake.nixosModules.<name>`.

Each feature groups related packages, services, udev rules, environment variables, and user permissions for a specific capability.

## Directory organization

```text
nixos/features/
├── system/                    # OS plumbing, hardware, display, and session services
│   ├── base.nix               # User virgola, nix-ld, fonts, weekly GC, and deduplication
│   ├── mangowm.nix            # MangoWM session, SDDM login, autostart daemons, keybindings
│   ├── noctalia.nix           # Noctalia v5 shell
│   ├── niri.nix               # Niri scrollable tiling compositor fallback
│   ├── wireguard.nix          # WireGuard and Fortinet SSL VPN suite (openfortivpn)
│   ├── laptop.nix             # UPower, power-profiles-daemon, lid switch, Blueman
│   ├── nvidia.nix             # Nvidia drivers and PRIME offload
│   └── zsh.nix                # Zsh shell, Starship prompt, aliases, vault scripts
└── apps/                      # Application suites and developer stacks
    ├── dev.nix                # Python (uv, pip), PHP, JDK 21, VS Code, Docker, LaTeX/LuaTeX
    ├── security.nix           # Pwn, web, reversing, crypto, stego (Ghidra, Pwndbg, Sage, MTP)
    ├── desktop.nix            # Desktop tools (Firefox, Thunar, GIMP, VLC, Vesktop, Zathura)
    └── gaming.nix             # Steam, GameMode, Proton-GE optimizations
```

## Module structure

Features use this structure:

```nix
{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.featureName = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # System packages:
    environment.systemPackages = with pkgs; [
      myPackage
    ];

    # Services:
    services.myService.enable = true;

    # Firewall or user permissions:
    # networking.firewall.allowedTCPPorts = [ ... ];
    # users.users.virgola.extraGroups = [ "mygroup" ];
  };
}
```

## Guidelines for feature modules

1. Keep features hardware independent: a feature should work across virtual machines, workstations, and laptops without assumptions about the target machine.
2. Use `lib.mkDefault`: wrap defaults in `lib.mkDefault` so individual hosts can override settings without needing `lib.mkForce`.
3. Flake discovery: any `.nix` file placed in `nixos/features/` is registered under `self.nixosModules.<name>` by `flake.nix`.
