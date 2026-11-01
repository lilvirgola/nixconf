# `packages/` — Custom Derivations & Scripts

## What Goes Here?

This directory is for **custom packages, scripts, or derivations** that you want to expose in your flake outputs (`perSystem.packages.<name>`) and optionally install on your NixOS hosts.

---

## How to Add a Custom Package

### Option 1: Inline `perSystem` module (Recommended for small scripts/packages)
Create `packages/my-script.nix`:
```nix
{
  perSystem = {pkgs, ...}: {
    packages.myScript = pkgs.writeShellApplication {
      name = "my-script";
      runtimeInputs = [pkgs.curl pkgs.jq];
      text = ''
        echo "Hello from custom package!"
      '';
    };
  };
}
```

### Option 2: `callPackage` with a `_`-prefixed derivation file
Because `flake.nix` auto-imports all `.nix` files *except* those starting with `_`, put the `callPackage` derivation in `_derivation.nix` and expose it in a module file:
1. `packages/_my-tool.nix`: standard `{ lib, stdenv, ... }: stdenv.mkDerivation { ... }`
2. `packages/my-tool.nix`:
```nix
{
  perSystem = {pkgs, ...}: {
    packages.myTool = pkgs.callPackage ./_my-tool.nix {};
  };
}
```

