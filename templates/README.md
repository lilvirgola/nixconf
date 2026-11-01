# `templates/` — Project DevShell Templates (`uv`, `Go`, `Rust`)

## How to Start a New Project on NixOS

Your system is configured with **two ways** to work on Python (`uv`), Go, and Rust projects:

---

### Method 1: Instant Global Toolchains (Zero Nix Files Needed)

Because `uv`, `python3`, `go`, `rustup`, `gcc`, `pkg-config`, and `nix-ld` dynamic libraries are installed globally via [`nixos/features/apps/dev.nix`](../nixos/features/apps/dev.nix) and [`nixos/features/system/base.nix`](../nixos/features/system/base.nix), you can start projects anywhere just like on a traditional Linux distribution:

#### Python (`uv`)
```bash
mkdir my-py && cd my-py
uv init
uv add requests numpy
uv run main.py
```

#### Go
```bash
mkdir my-go && cd my-go
go mod init example.com/my-go
go run .
```

#### Rust
```bash
# First time only after installing NixOS:
rustup default stable

# For any new project:
cargo new my-rust && cd my-rust
cargo run
```

---

### Method 2: Reproducible Per-Project Flake + `direnv`

When a project needs project-specific system C libraries, pinned compiler versions, or a team-reproducible `flake.nix`, initialize one of the templates in this folder:

```bash
mkdir my-project && cd my-project

# Pick your language template:
nix flake init -t /home/virgola/nixconf#python-uv
# OR
nix flake init -t /home/virgola/nixconf#go
# OR
nix flake init -t /home/virgola/nixconf#rust

# Activate automatic environment loading via direnv:
direnv allow
```

Because `programs.direnv` and `nix-direnv` are enabled in `base.nix`, your shell (and VS Code with the `mkhl.direnv` extension) will automatically enter the project's `devShell` whenever you `cd` into the directory!
