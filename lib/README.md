# Flake infrastructure (`lib/`)

Shared `flake-parts` configuration for the repository.

## Modules

- `parts.nix`: Sets `systems` to `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, and `aarch64-darwin`, and enables `allowUnfree = true` for `perSystem` packages.
- `fmt.nix`: Configures `alejandra` (`nix fmt .`), `checks.nix-fmt`, `checks.nix-lint` (`statix` + `deadnix`), and `devShells.default` (which sets `git config core.hooksPath .githooks`).
- `templates.nix`: Exports `flake.templates` from `templates/`.

## Validation

```bash
nix fmt .
nix flake check
```

Files prefixed with `_` are ignored by the recursive module loader in `flake.nix` and can be imported manually.
