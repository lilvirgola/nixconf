# `templates/` — Project DevShell Templates (`Python uv`, `Go`, `Rust`, `LaTeX`)

This directory houses reproducible, zero-friction project templates exposed via `flake.templates.<name>` and consumable with the automated `ninit` CLI tool or `nix flake init -t`.

---

## Three Ways to Start a Project on NixOS

### Method 1: Automated Scaffold (`ninit`) — Recommended!

The fastest, recommended method to bootstrap a new repository:

```bash
# 1. Interactive picker with fzf:
ninit

# 2. Or specify template and project name directly:
ninit rust my-crate          # Scaffolds Rust template in ./my-crate
ninit py my-fastapi          # Scaffolds Python uv template in ./my-fastapi
ninit go my-microservice     # Scaffolds Go template in ./my-microservice
ninit latex my-thesis        # Scaffolds LaTeX/LuaTeX template in ./my-thesis
```

`ninit` handles all boilerplate automatically:
1. Creates the target directory.
2. Copies all template files (`flake.nix`, `.envrc`, `.gitignore`, boilerplate code).
3. Initializes a Git repository with `git init`.
4. Runs `direnv allow` so the isolated `devShell` activates instantly.

---

### Method 2: Instant Global Toolchains (Zero Nix Files Needed)

Because `uv`, `python3`, `go`, `rustup`, `gcc`, `tectonic`, and `nix-ld` are installed globally in `dev.nix`, you can also create projects anywhere just like on traditional Linux:

#### Python (`uv`)
```bash
mkdir my-py && cd my-py
uv init
uv add requests fastapi
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
# First time setup (once):
rustup default stable

cargo new my-rust && cd my-rust
cargo run
```

#### LaTeX / Academic
```bash
mkdir my-doc && cd my-doc
cat << 'EOF' > main.tex
\documentclass{article}
\begin{document}
Hello from Tectonic on NixOS!
\end{document}
EOF
tectonic -X compile main.tex
```

---

### Method 3: Standard Flake Initialization (`nix flake init -t`)

For manual flake initialization:

```bash
mkdir my-project && cd my-project

# Initialize from the local flake:
nix flake init -t /home/virgola/nixconf#python-uv
# OR
nix flake init -t /home/virgola/nixconf#go
# OR
nix flake init -t /home/virgola/nixconf#rust
# OR
nix flake init -t /home/virgola/nixconf#latex

# Activate devShell:
direnv allow
```

---

## Template Details

### 1. `python-uv` ([`templates/python-uv/`](./python-uv/))
- **Tools**: Python 3.14, `uv`, `ruff`, `pyright`.
- **Preconfigured**: `UV_PYTHON_DOWNLOADS=automatic` and `nix-ld` dynamic library bindings so binary wheels (NumPy, PyTorch, Pandas, Scipy) install and link without C-compiler compilation errors.

### 2. `go` ([`templates/go/`](./go/))
- **Tools**: Go 1.24+, `gopls` language server, `golangci-lint`, and `delve` debugger.
- **Includes**: Clean `main.go`, `go.mod`, and `Makefile`.

### 3. `rust` ([`templates/rust/`](./rust/))
- **Tools**: `cargo`, `rustc`, `rust-analyzer`, `clippy`, and `rustfmt` managed with `rustup` or native toolchain.
- **Includes**: Cargo configuration, boilerplate `src/main.rs`, and `.gitignore`.

### 4. `latex` ([`templates/latex/`](./latex/))
- **Tools**: `tectonic`, `texliveMedium` (with `biber` & `chktex`), `texlab` language server, `ltex-ls-plus`, and `zathura`.
- **Live SyncTeX Bidirectional Sync**:
  - Live compilation and continuous watching:
    ```bash
    tectonic -X watch --keep-intermediates --synctex
    ```
  - Open PDF with Zathura:
    ```bash
    zathura build/main.pdf &
    ```
  - Hold `Ctrl` and click any text inside Zathura to jump directly to the exact source file and line in your editor!
