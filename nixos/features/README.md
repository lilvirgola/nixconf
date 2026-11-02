# `nixos/features/` — Composable NixOS Feature Modules

Every file under `nixos/features/` defines one or more reusable NixOS modules exposed under `flake.nixosModules.<name>`.

Features are the modular building blocks of your operating system. Rather than creating a single monolithic configuration, each feature encapsulates a discrete capability: its packages, services, daemon configurations, udev rules, environment variables, and PAM hooks.

---

## Directory Organization

```text
nixos/features/
├── system/                    # Core OS plumbing, hardware, display, and session services
│   ├── base.nix               # User virgola, nix-ld, fonts, weekly GC & deduplication
│   ├── mangowm.nix            # MangoWM session, SDDM login, autostart daemons, keybindings
│   ├── noctalia.nix           # Noctalia v5 shell & floating bar integration
│   ├── niri.nix               # Niri scrollable tiling compositor fallback
│   ├── wireguard.nix          # WireGuard & Fortinet SSL VPN suite (openfortivpn)
│   ├── laptop.nix             # UPower, power-profiles-daemon, lid switch, Blueman
│   ├── nvidia.nix             # Proprietary Nvidia drivers & PRIME offload
│   └── zsh.nix                # Zsh shell, Starship, power aliases & vault scripts
└── apps/                      # User-facing application suites & developer toolchains
    ├── dev.nix                # Python (uv, pip), PHP, JDK 21, VS Code, Docker, LaTeX/LuaTeX
    ├── security.nix           # Pwn, Web, Reversing, Crypto, Stego (Ghidra, Pwndbg, Sage, MTP)
    ├── desktop.nix            # Daily desktop tools (Firefox, Thunar, GIMP, VLC, Vesktop, Zathura)
    └── gaming.nix             # Steam, GameMode, Proton-GE optimizations
```

---

## Anatomy of a Feature Module

Every feature follows this standard template:

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
    # 1. System packages needed for this feature:
    environment.systemPackages = with pkgs; [
      myPackage
    ];

    # 2. System services:
    services.myService.enable = true;

    # 3. Security, firewall, or user permissions:
    # networking.firewall.allowedTCPPorts = [ ... ];
    # users.users.virgola.extraGroups = [ "mygroup" ];
  };
}
```

---

## Best Practices for Authoring Features

1. **Keep Features Decoupled**: Never assume a feature will only run on a specific host. A feature should function identically whether imported by a VM, a desktop workstation, or a laptop.
2. **Use `lib.mkDefault`**: When defining default settings that a specific machine might want to override (e.g. `services.openssh.enable`), wrap the value in `lib.mkDefault` so hosts can override it cleanly without `mkForce`.
3. **Automatic Discovery**: Because of the Dendritic auto-import pattern in `flake.nix`, simply creating a `.nix` file in `nixos/features/` registers its module globally in `self.nixosModules.<name>`.
