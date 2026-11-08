# Flake infrastructure in lib/

This directory contains flake-wide modules, formatters, automated checks, and template exports for the repository.

## Modules

### parts.nix ([lib/parts.nix](./parts.nix))
Declares the target platforms evaluated by `perSystem`:
```nix
systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
```

### fmt.nix ([lib/fmt.nix](./fmt.nix))
Configures `pkgs.alejandra` as the formatter for `nix fmt .`, and adds `checks.nix-fmt` so running `nix flake check .` verifies formatting in CI.

### templates.nix ([lib/templates.nix](./templates.nix))
Exports `flake.templates` pointing to the directories in `templates/`, providing 26 environments across systems development, web runtimes, document typesetting, enterprise languages, and security/CTF categories.

## Validation commands

```bash
# Format all Nix files with Alejandra:
nix fmt .

# Run flake checks (formatting, derivations, evaluation):
nix flake check .

# Test against a specific Nixpkgs revision:
nix flake check --override-input nixpkgs github:nixos/nixpkgs/nixos-unstable
```

## The underscore prefix convention

`flake.nix` discovers and imports every `.nix` file in the tree. Any file in this directory must be a valid module returning an attribute set.

To define helper functions or raw expressions meant for manual import, prefix the filename with an underscore (such as `_helpers.nix`). The discovery logic skips files starting with `_`.
