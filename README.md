# Virgola's NixOS Configuration

A modular, multi-host NixOS flake structured around the **Dendritic Pattern** (`flake-parts`), using **MangoWM** (`mangowc`) and **Noctalia Shell** packaged via `nix-wrapper-modules`.

---

## Architecture: The Dendritic Pattern

In this repository, **every `.nix` file is a `flake-parts` module** (except `flake.nix` itself, files prefixed with `_`, and standalone project templates under `templates/`).
`flake.nix` recursively discovers and imports every `.nix` file in the directory tree automatically—so you never need to maintain a central list of file path imports.

### Directory Map (What Goes Where)

```text
nixconf/
├── flake.nix                  # Flake entrypoint & recursive module auto-importer
├── lib/                       # Flake-wide settings: supported systems, formatter, checks, templates
├── wrappedPrograms/           # Standalone programs wrapped via nix-wrapper-modules (MangoWM, Noctalia, Niri)
├── packages/                  # Custom standalone derivations exposed under `perSystem.packages`
├── templates/                 # Project devShell templates (`python-uv`, `go`, `rust`) for `nix flake init -t`
├── nixos/
│   ├── features/              # Reusable NixOS modules (`flake.nixosModules.<name>`)
│   │   ├── system/            # Core OS, WireGuard, desktop/compositor, audio, laptop, Nvidia modules
│   │   └── apps/              # Desktop apps, Dev (`uv`/Go/Rust/Docker), Security/RE, Gaming modules
│   └── hosts/                 # Machine-specific configurations (`flake.nixosConfigurations.<host>`)
│       ├── vm/                # QEMU/KVM Virtual Machine host (`#vm`)
│       └── laptop/            # Physical Laptop host with UEFI, Nvidia, Gaming & power services (`#laptop`)
└── .github/
    ├── dependabot.yml         # Weekly updates for GitHub Actions
    └── workflows/             # CI (`nix flake check`) & automated weekly `flake.lock` PRs
```

Each folder contains its own `README.md` with copy-pasteable templates explaining what belongs in that directory.

---

## Starting a Python (`uv`), Go, or Rust Project

See [`templates/README.md`](./templates/README.md) for full details:

1. **Quick Global Workflow (Anywhere)**:
   - **Python (`uv`)**: `uv init my-app && cd my-app && uv run main.py` (`nix-ld` is preconfigured so prebuilt C/C++ Python wheels work out-of-the-box)
   - **Go**: `go mod init example.com/app && go run .`
   - **Rust**: `rustup default stable` (once), then `cargo new my-app && cargo run`
2. **Reproducible Flake + `direnv` Workflow**:
   ```bash
   mkdir my-project && cd my-project
   nix flake init -t /home/virgola/nixconf#python-uv   # or #go or #rust
   direnv allow
   ```

---

## Using WireGuard VPN

Both `wireguard-tools` and NetworkManager's WireGuard support are enabled on all hosts:
```bash
# Import a WireGuard .conf file into NetworkManager once:
nmcli connection import type wireguard file ~/my-vpn.conf

# Toggle the VPN tunnel on/off:
nmcli connection up my-vpn
nmcli connection down my-vpn
```
*(Or run `nm-connection-editor` for a GUI interface, or `sudo wg-quick up ~/my-vpn.conf`).*

---

## Common Commands

### Rebuild a Host
```bash
# On the VM:
sudo nixos-rebuild switch --flake /home/virgola/nixconf#vm

# On the Laptop:
sudo nixos-rebuild switch --flake /home/virgola/nixconf#laptop
```

### Format & Validate Flake
```bash
# Format all .nix files with Alejandra:
nix fmt .

# Run all flake checks (formatting, wrapped program validation, NixOS evaluations):
nix flake check .
```
