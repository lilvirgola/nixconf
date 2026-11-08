# Custom derivations and standalone packages in packages/

This directory contains packages, scripts, and derivations exposed under `perSystem.packages.<name>` and loaded by `flake.nix`.

Each package defined here can be run or built directly:
- `nix run .#<packageName>` or `nix build .#<packageName>`
- Referenced in system configurations through `self.packages.${pkgs.stdenv.hostPlatform.system}.<packageName>`

## Available packages

### 1. ninit ([packages/ninit.nix](./ninit.nix))
Project scaffolding CLI with an interactive terminal interface:
- Discovers templates dynamically from `templates/` and reads metadata (`template.json` or `flake.nix`).
- Interactive menu built with Python, Rich, and Questionary.
- Scaffolds projects for 26 environments across systems programming, web runtimes, document typesetting, enterprise languages, and security/CTF categories.
- Initializes Git repositories, configures `.gitignore`, stages files, and runs `direnv allow`.
- Usage:
  ```bash
  ninit                  # Interactive selection
  ninit --list           # View all discovered templates, aliases, and commands
  ninit rust my-crate    # Initialize Rust template in ./my-crate
  ninit py my-app        # Initialize Python uv template in ./my-app
  ninit ctf-pwn pwn01    # Initialize CTF binary exploitation workspace
  ```

### 2. keyhints ([packages/keyhints.nix](./keyhints.nix))
Keybindings cheatsheet and launcher:
- Fuzzy search modal with `rofi`, bound to `SUPER + H` in MangoWM and `Mod + H` in Niri.
- Categorized into Apps, Windows, Navigation, Resize and Move, Workspaces, Screenshots, and Audio and Media.
- Pressing `Enter` on an application row launches it directly.
- Floating GTK table with `yad`: run `keyhints --table` to keep a 3-column reference visible while working.

### 3. mtp ([packages/mtp.nix](./mtp.nix))
Many-Time Pad interactive cryptanalysis tool:
- Solves stream cipher key-reuse vulnerabilities by analyzing XOR ciphertexts with statistical frequency analysis and an interactive terminal interface.
- Built with Python and `urwid`.
- Usage:
  ```bash
  mtp ciphertexts.txt -o decrypted.json
  ```

### 4. tunnelmole ([packages/tunnelmole.nix](./tunnelmole.nix))
Tunneling client for exposing local services:
- Generates public HTTP and HTTPS URLs for local web servers without manual port forwarding.
- Provides `tmole` and `tunnelmole` binaries configured with `nix-ld` compatibility.
- Usage:
  ```bash
  tmole 8080                                  # Expose port 8080 with a random public URL
  tmole 8080 as myapp.tunnelmole.net          # Expose with custom subdomain
  ```

### 5. kssh ([packages/kssh.nix](./kssh.nix))
Kitty SSH Kitten connection and profile manager:
- Built with Python, Rich, and Questionary.
- Detects first-time connections and prompts for a host profile template.
- Saves host configurations using `include templates/<name>.conf` in `~/.config/kitty/ssh_hosts.conf`.
- Directly executes `kitten ssh` for configured hosts without runtime overhead.
- Usage:
  ```bash
  s cluster                   # Connect to host (prompts on first connection)
  s --list                    # Table of saved SSH hosts
  s --templates               # Table of available connection templates
  s --edit                    # Edit ssh_hosts.conf in $EDITOR
  s --edit-template server    # Edit specific template in $EDITOR
  s --remove cluster          # Remove saved profile to re-trigger prompt
  ```

## Adding a custom package

Any `.nix` file placed in `packages/` is automatically registered under `packages.<name>`.

### Example: shell script package
Create `packages/my-tool.nix`:
```nix
{...}: {
  perSystem = {pkgs, ...}: {
    packages.myTool = pkgs.writeShellApplication {
      name = "my-tool";
      runtimeInputs = with pkgs; [curl jq];
      text = ''
        echo "Executing custom tool..."
        curl -s "https://api.github.com/repos/lilvirgola/nixconf" | jq .stargazers_count
      '';
    };
  };
}
```

### Example: standard derivation
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

Run the package:
```bash
nix run .#myTool
```
