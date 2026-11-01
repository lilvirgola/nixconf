# `wrappedPrograms/` — Portable Wrapped Applications

## What Goes Here?

This directory contains standalone program configurations built with [`BirdeeHub/nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules).

Instead of tying application configs to Home Manager, each file here wraps a package (bundling its flags, config files, and runtime environment directly into a derivation) and exposes it under `perSystem.packages.<name>`.

### Current Files
- [`noctalia.nix`](./noctalia.nix) & [`noctalia.json`](./noctalia.json): Produces `packages.myNoctalia` (`noctalia-shell` bundled with declarative settings).
- [`mangowm.nix`](./mangowm.nix): Produces `packages.myMango` (`mangowc` compositor configured to spawn `myNoctalia`, use the `it` keyboard layout, and validate its config at build time).
- [`niri.nix`](./niri.nix): Produces `packages.myNiri` (optional Niri compositor wrapper).

---

## How to Add a New Wrapped Program

Create a new `<program>.nix` file in this directory:

```nix
{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.myKitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;
      settings = {
        font_size = 12;
      };
    };
  };
}
```

You can then reference it inside any NixOS module as:
```nix
self.packages.${pkgs.stdenv.hostPlatform.system}.myKitty
```
or test it directly from the terminal with `nix run .#myKitty`.

