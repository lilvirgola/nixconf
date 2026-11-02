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

### Method 2: Automated Initializer (`ninit` / `nix-template`)

The fastest way to scaffold a new project with Git, Flake, and automatic `direnv` activation:

```bash
# Interactive selection with fzf:
ninit

# Or direct initialization:
ninit rust my-cli
ninit py my-data-app
ninit go my-service
ninit latex my-paper
```

`ninit` automatically:
1. Creates the target directory and copies the template
2. Runs `git init` (if not already inside a git repo)
3. Runs `direnv allow` for immediate environment activation

---

### Method 3: Manual `nix flake init -t`

When you want to manually initialize a template:

```bash
mkdir my-project && cd my-project

# Pick your language template:
nix flake init -t /home/virgola/nixconf#python-uv
# OR
nix flake init -t /home/virgola/nixconf#go
# OR
nix flake init -t /home/virgola/nixconf#rust
# OR
nix flake init -t /home/virgola/nixconf#latex

# Activate automatic environment loading via direnv:
direnv allow
```

Because `programs.direnv` and `nix-direnv` are enabled in `base.nix`, your shell (and VS Code with the `mkhl.direnv` extension) will automatically enter the project's `devShell` whenever you `cd` into the directory!

