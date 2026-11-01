# Virgola's NixOS Configuration

A modular, multi-host NixOS flake structured around the **Dendritic Pattern** (`flake-parts`), using **MangoWM** (`mangowc`) and **Noctalia Shell** packaged via `nix-wrapper-modules`.

---

## Architecture: The Dendritic Pattern

In this repository, **every `.nix` file is a `flake-parts` module** (except `flake.nix` itself and any file prefixed with `_`).
`flake.nix` recursively discovers and imports every `.nix` file in the directory tree automatically—so you never need to maintain a central list of file path imports.

### Directory Map (What Goes Where)

```text
nixconf/
├── flake.nix                  # Flake entrypoint & recursive module auto-importer
├── lib/                       # Flake-wide settings: supported systems, formatter, checks
├── wrappedPrograms/           # Standalone programs wrapped via nix-wrapper-modules (MangoWM, Noctalia, Niri)
├── packages/                  # Custom standalone derivations exposed under `perSystem.packages`
├── nixos/
│   ├── features/              # Reusable NixOS modules (`flake.nixosModules.<name>`)
│   │   ├── system/            # Core OS, hardware, desktop/compositor, audio, GPU modules
│   │   └── apps/              # User-facing application bundles (gaming, dev tools, etc.)
│   └── hosts/                 # Machine-specific configurations (`flake.nixosConfigurations.<host>`)
│       ├── vm/                # QEMU/KVM Virtual Machine host (`#vm`)
│       └── laptop/            # Physical Laptop host with UEFI, Nvidia & power services (`#laptop`)
└── .github/
    ├── dependabot.yml         # Weekly updates for GitHub Actions
    └── workflows/             # CI (`nix flake check`) & automated weekly `flake.lock` PRs
```

Each folder contains its own `README.md` with copy-pasteable templates explaining what belongs in that directory.

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
nix fmt

# Run all flake checks (formatting, wrapped program validation, NixOS evaluations):
nix flake check
```

### Test Wrapped Programs Directly
Because `MangoWM` and `Noctalia` are wrapped as standalone packages in `wrappedPrograms/`, you can build or run them directly:
```bash
nix build .#myMango
nix build .#myNoctalia
```

---

## Setting Up the Laptop Host

1. On your physical laptop, generate or inspect `/etc/nixos/hardware-configuration.nix`.
2. Copy the hardware-specific options (`boot.*`, `fileSystems.*`, `swapDevices`, etc.) into [`nixos/hosts/laptop/hardware.nix`](./nixos/hosts/laptop/hardware.nix) inside `flake.nixosModules.laptopHardware`.
3. If your laptop uses hybrid graphics (Intel/AMD iGPU + Nvidia dGPU), uncomment the `hardware.nvidia.prime` block in [`nixos/features/system/nvidia.nix`](./nixos/features/system/nvidia.nix) and set your PCI Bus IDs.
4. Run `sudo nixos-rebuild switch --flake .#laptop`.

---

## GitHub & Dependabot Setup

This repository includes:
- [`.github/dependabot.yml`](./.github/dependabot.yml): Keeps GitHub Actions versions updated weekly.
- [`.github/workflows/update-flake-lock.yml`](./.github/workflows/update-flake-lock.yml): Automatically runs `nix flake update` every Monday (or manually via the Actions tab) and opens a Pull Request.
- [`.github/workflows/check.yml`](./.github/workflows/check.yml): Runs `nix flake check` on every push to `main` and every Pull Request.

> **Important GitHub Repo Setting**: After pushing to GitHub, go to **Settings → Actions → General → Workflow permissions**, select **Read and write permissions**, and check **Allow GitHub Actions to create and approve pull requests** so the `Update flake.lock` workflow can open PRs.
