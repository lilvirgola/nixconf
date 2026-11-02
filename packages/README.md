# `packages/` — Custom Derivations & Standalone Flake Packages

This directory contains **custom packages, scripts, and derivations** exposed under `perSystem.packages.<name>` and automatically discovered by `flake.nix`.

Any package defined here is:
1. Available on the command line: `nix run .#<packageName>` or `nix build .#<packageName>`.
2. Available for installation across your NixOS systems: `self.packages.${pkgs.stdenv.hostPlatform.system}.<packageName>`.

---

## Current Custom Packages

### 1. `ninit` ([`packages/ninit.nix`](./ninit.nix))
An interactive, automated project scaffolding CLI tool:
- Scans `templates/` and prompts with an interactive `fzf` picker.
- Scaffolds complete projects for:
  - `python-uv`: Modern Python 3 with `uv`, `pyproject.toml`, and `.envrc`.
  - `go`: Go module with `gopls`, `golangci-lint`, and `.envrc`.
  - `rust`: Rust crate with `Cargo.toml`, `rust-toolchain.toml`, and `.envrc`.
  - `latex`: Complete LaTeX / LuaTeX document setup with Tectonic, Texlab, Zathura SyncTeX, and `.envrc`.
- Automatically initializes git repositories and runs `direnv allow`.
- **Usage**:
  ```bash
  ninit                  # Interactive selection with fzf
  ninit rust my-crate    # Direct initialization
  ```

---

### 2. `keyhints` ([`packages/keyhints.nix`](./keyhints.nix))
Interactive keybindings cheatsheet and action launcher:
- **Interactive Fuzzy Search Modal (`rofi`)**:
  - Bound to `SUPER + H` in MangoWM and `Mod + H` in Niri.
  - Toggles on/off cleanly if already open.
  - Features a custom Catppuccin Mocha theme with categorized rows (**Apps**, **Windows**, **Navigation**, **Resize & Move**, **Workspaces**, **Screenshots**, **Audio & Media**).
  - **Live Action Execution**: Pressing `Enter` on any application row immediately executes the command.
- **Persistent Graphical Cheatsheet (`yad`)**:
  - Run `keyhints --table` or select `📋 View Full Table Cheatsheet (YAD)` to open a floating 3-column GTK reference table that stays visible while you work.

---

### 3. `mtp` ([`packages/mtp.nix`](./mtp.nix))
Many-Time Pad Interactive cryptanalysis tool:
- Solves One-Time Pad / stream cipher key-reuse vulnerabilities by analyzing XOR-ed ciphertexts with statistical frequency and interactive TUI feedback.
- Packaged using `pkgs.python3Packages.buildPythonApplication` with `urwid` terminal interface.
- **Usage**:
  ```bash
  mtp ciphertexts.txt -o decrypted.json
  ```

---

### 4. `tunnelmole` ([`packages/tunnelmole.nix`](./tunnelmole.nix))
Open-source `ngrok` alternative:
- Generates instant, public HTTP and HTTPS URLs for local web servers through firewalls without port forwarding.
- Provides `tmole` and `tunnelmole` executables configured with `nix-ld` compatibility.
- **Usage**:
  ```bash
  tmole 8080                                  # Expose port 8080 with a random public URL
  tmole 8080 as myapp.tunnelmole.net          # Expose with custom reserved subdomain
  ```

---

## How to Add a Custom Package

Due to the Dendritic Flake-Parts architecture, simply creating a `.nix` file in `packages/` automatically registers it under `packages.<name>`.

### Example: Writing a Shell Script Application
Create `packages/my-tool.nix`:
```nix
{...}: {
  perSystem = {pkgs, ...}: {
    packages.myTool = pkgs.writeShellApplication {
      name = "my-tool";
      runtimeInputs = with pkgs; [curl jq];
      text = ''
        echo "Executing my custom tool..."
        curl -s "https://api.github.com/repos/lilvirgola/nixconf" | jq .stargazers_count
      '';
    };
  };
}
```

### Example: Packaging a Standard Derivation
Create `packages/my-binary.nix`:
```nix
{...}: {
  perSystem = {pkgs, ...}: {
    packages.myBinary = pkgs.stdenv.mkDerivation {
      pname = "my-binary";
      version = "1.0.0";
      src = pkgs.fetchurl {
        url = "https://example.com/download.tar.gz";
        hash = "...";
      };
      installPhase = ''
        mkdir -p $out/bin
        cp my-binary $out/bin/
      '';
    };
  };
}
```
Validate and run your new package immediately:
```bash
nix run .#myTool
```
