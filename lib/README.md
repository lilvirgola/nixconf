# `lib/` — Flake Infrastructure & Helpers

## What Goes Here?

This directory holds **flake-wide configuration, `flake-parts` setup, formatters, checks, and shared helper functions** that apply to the entire flake rather than a single NixOS host or desktop app.

### Current Files
- [`parts.nix`](./parts.nix): Declares the target architectures (`systems = [ "x86_64-linux" ... ];`) evaluated by `perSystem`.
- [`fmt.nix`](./fmt.nix): Configures `pkgs.alejandra` as the flake formatter (`nix fmt`) and registers `checks.nix-fmt` so `nix flake check` verifies all `.nix` files are formatted.

### Rule of Thumb
- Any `.nix` file placed here is automatically imported as a `flake-parts` module.
- If you write a raw helper library file that is **not** a `flake-parts` module (for example, a set of pure functions to import manually), prefix its filename with `_` (e.g., `_helpers.nix`) so `flake.nix` skips auto-importing it as a module.
