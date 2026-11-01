# `nixos/features/apps/` — Application Feature Modules

## What Goes Here?

Reusable NixOS modules (`flake.nixosModules.<name>`) for user-facing applications, gaming setups, or development toolchains that you can toggle on any host by adding `self.nixosModules.<name>` to that host's `imports`.

---

## Example: Adding a Gaming Module

Create `nixos/features/apps/gaming.nix`:

```nix
{inputs, ...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    imports = [
      inputs.nix-gaming.nixosModules.platformOptimizations
    ];

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };
}
```

Then include `self.nixosModules.gaming` in `nixos/hosts/laptop/configuration.nix` (or `vm/configuration.nix`).

