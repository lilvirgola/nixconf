# Custom packages (`packages/`)

Files in `packages/` are auto-discovered by `flake.nix` and exposed under `perSystem.packages.<name>`.

Build or run any package directly:

```bash
nix run .#ninit
nix build .#keyhints
```

## Available packages

- `ninit` ([ninit.nix](./ninit.nix)): Interactive Python CLI (`rich` + `questionary`) that scaffolds projects from `templates/`, initializes Git, stages files, and runs `direnv allow`.
- `keyhints` ([keyhints.nix](./keyhints.nix)): Searchable `rofi` keybinding cheatsheet (`SUPER + H`) with a `yad` table mode (`keyhints --table`).
- `kssh` ([kssh.nix](./kssh.nix)): Interactive `kitten ssh` profile manager (`s <host>`) that stores per-host templates in `~/.config/kitty/ssh_hosts.conf`.
- `ssh-vault` ([ssh-vault.nix](./ssh-vault.nix)): Provides `ssh-vault-load`, `ssh-vault-add`, and `ssh-vault-list` to store and load SSH keys from Bitwarden/Vaultwarden (`rbw` or `bw`) into `ssh-agent`.
- `mtp` ([mtp.nix](./mtp.nix)): Interactive Many-Time Pad XOR cryptanalysis tool (`mtp ciphertexts.txt -o decrypted.json`).
- `tunnelmole` ([tunnelmole.nix](./tunnelmole.nix)): Reverse tunnel client (`tmole 8080`).
- `deploy` ([deploy.nix](./deploy.nix)): Remote NixOS deployment wrapper around `nixos-rebuild --target-host` (`deploy server`, `deploy raspberrypi`).
