# `lib/` — Flake Infrastructure, Formatting & Checks

This directory contains **flake-wide infrastructure, `flake-parts` modules, formatters, automated checks, and template registrations** that apply across the entire repository.

---

## Current Modules

### 1. `parts.nix` ([`lib/parts.nix`](./parts.nix))
- Declares the target platform architectures evaluated by `perSystem`:
  ```nix
  systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  ```
- Ensures multi-architecture support across all defined packages, devShells, and checks.

### 2. `fmt.nix` ([`lib/fmt.nix`](./fmt.nix))
- **Formatter**: Configures `pkgs.alejandra` as the flake-wide formatter executed by `nix fmt .`.
- **Automated Check**: Registers `checks.nix-fmt` so running `nix flake check .` or CI automatically enforces Alejandra formatting rules across all `.nix` files.

### 3. `templates.nix` ([`lib/templates.nix`](./templates.nix))
- Exposes `flake.templates` pointing to the definitions in `templates/`:
  - `python-uv`: Modern Python 3 with `uv`, `ruff`, and `.envrc`.
  - `go`: Go module with language server, linter, and debugger.
  - `rust`: Rust crate with Cargo toolchain and rust-analyzer.
  - `latex`: Complete academic publishing setup with Tectonic, SyncTeX, and Texlab.

---

## Flake Validation Commands

```bash
# 1. Format all Nix files according to Alejandra standard:
nix fmt .

# 2. Run all flake checks (formatting, derivations, evaluation):
nix flake check .

# 3. Test compatibility with specific Nixpkgs revisions:
nix flake check --override-input nixpkgs github:nixos/nixpkgs/nixos-unstable
```

---

## The `_` Prefix Convention

Because `flake.nix` automatically discovers and imports every `.nix` file in the repository tree, any file you add here is expected to be a valid `flake-parts` module (a function accepting `{ inputs, self, ... }` and returning an attribute set).

If you want to write a raw Nix expression or helper function to import manually (rather than a module), simply prefix the file name with `_` (e.g. `_helpers.nix`). The importer in `flake.nix` will ignore it.
