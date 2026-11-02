#!/usr/bin/env bash
# ==============================================================================
# Virgola's NixOS Bootstrap & Hardware Provisioning Script
# Repository: https://github.com/lilvirgola/nixconf
# ==============================================================================
set -euo pipefail

# Colors & Formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}${BOLD}[*]${NC} $*"; }
success() { echo -e "${GREEN}${BOLD}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[!]${NC} $*"; }
error()   { echo -e "${RED}${BOLD}[✗]${NC} $*"; }
ask()     { echo -en "${CYAN}${BOLD}[?]${NC} $*"; }

banner() {
  cat << "EOF"
  ██████╗  ██████╗  ██████╗ ████████╗███████╗████████╗██████╗  █████╗ ██████╗ 
  ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗
  ██████╔╝██║   ██║██║   ██║   ██║   ███████╗   ██║   ██████╔╝███████║██████╔╝
  ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝ 
  ██████╔╝╚██████╔╝╚██████╔╝   ██║   ███████║   ██║   ██║  ██║██║  ██║██║     
  ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     
               Virgola's Modular NixOS Desktop & Security Suite
EOF
}

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --host HOSTNAME   Target host configuration (default: laptop, options: laptop, vm)"
  echo "  -d, --dir PATH        Path to nixconf repository (default: current directory or ~/nixconf)"
  echo "  --no-hardware         Skip generating hardware.nix"
  echo "  --no-password         Skip password setup prompt"
  echo "  --dry-run             Evaluate configuration without rebuilding system"
  echo "  --help                Display this help message"
  echo ""
}

# Defaults
TARGET_HOST="laptop"
REPO_DIR=""
GEN_HARDWARE=true
SET_PASSWORD=true
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--host)
      TARGET_HOST="$2"
      shift 2
      ;;
    -d|--dir)
      REPO_DIR="$2"
      shift 2
      ;;
    --no-hardware)
      GEN_HARDWARE=false
      shift
      ;;
    --no-password)
      SET_PASSWORD=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      banner
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

banner

# 1. Locate repository directory
if [ -z "$REPO_DIR" ]; then
  if [ -f "./flake.nix" ] && [ -d "./nixos" ]; then
    REPO_DIR="$(pwd)"
  elif [ -d "$HOME/nixconf" ] && [ -f "$HOME/nixconf/flake.nix" ]; then
    REPO_DIR="$HOME/nixconf"
  elif [ -d "/etc/nixos" ] && [ -f "/etc/nixos/flake.nix" ]; then
    REPO_DIR="/etc/nixos"
  else
    REPO_DIR="$HOME/nixconf"
    info "Repository not found locally. Cloning to $REPO_DIR..."
    git clone https://github.com/lilvirgola/nixconf.git "$REPO_DIR"
  fi
fi

cd "$REPO_DIR"
info "Working inside repository: ${BOLD}$REPO_DIR${NC}"

# Verify flake.nix exists
if [ ! -f "flake.nix" ]; then
  error "flake.nix not found in $REPO_DIR!"
  exit 1
fi

# 2. Select host interactively if not explicitly passed
if [ "$TARGET_HOST" = "laptop" ] && [ -t 0 ]; then
  echo ""
  info "Available host configurations:"
  echo "  1) laptop  - Physical Laptop (UEFI, Nvidia hybrid, Power/Bluetooth, SSH disabled)"
  echo "  2) vm      - Virtual Machine (GRUB, QEMU/SPICE, SSH enabled)"
  ask "Select target host [1 for laptop / 2 for vm] (default: 1): "
  read -r host_choice
  case "$host_choice" in
    2|vm)
      TARGET_HOST="vm"
      ;;
    *)
      TARGET_HOST="laptop"
      ;;
  esac
fi
success "Selected target host: ${BOLD}$TARGET_HOST${NC}"

# Check that host directory exists
HOST_DIR="$REPO_DIR/nixos/hosts/$TARGET_HOST"
if [ ! -d "$HOST_DIR" ]; then
  error "Host directory $HOST_DIR does not exist!"
  exit 1
fi

# 3. Generate hardware configuration
if [ "$GEN_HARDWARE" = true ]; then
  echo ""
  ask "Generate fresh hardware-configuration.nix for this machine? (Y/n): "
  read -r gen_choice
  if [[ ! "$gen_choice" =~ ^[Nn]$ ]]; then
    if command -v nixos-generate-config >/dev/null 2>&1; then
      info "Running 'nixos-generate-config --show-hardware-config'..."
      TMP_HW=$(mktemp)
      sudo nixos-generate-config --show-hardware-config > "$TMP_HW"

      if [ -s "$TMP_HW" ]; then
        if [ -f "$HOST_DIR/hardware.nix" ]; then
          BACKUP_FILE="$HOST_DIR/hardware.nix.bak.$(date +%s)"
          info "Backing up existing hardware.nix to $(basename "$BACKUP_FILE")..."
          cp "$HOST_DIR/hardware.nix" "$BACKUP_FILE"
        fi
        
        info "Writing new hardware configuration to $HOST_DIR/hardware.nix..."
        mv "$TMP_HW" "$HOST_DIR/hardware.nix"
        
        # Ensure proper permissions
        sudo chown -R "$(id -u):$(id -g)" "$HOST_DIR/hardware.nix" 2>/dev/null || true
        chmod 644 "$HOST_DIR/hardware.nix"
        success "Hardware configuration updated successfully!"
      else
        warn "nixos-generate-config produced empty output. Keeping existing hardware.nix."
        rm -f "$TMP_HW"
      fi
    else
      warn "nixos-generate-config command not found. Skipping hardware generation."
    fi
  else
    info "Skipping hardware generation on user request."
  fi
fi

# 4. User Password Configuration
if [ "$SET_PASSWORD" = true ]; then
  echo ""
  ask "Would you like to set/update the password for user 'virgola'? (y/N): "
  read -r pwd_choice
  if [[ "$pwd_choice" =~ ^[Yy]$ ]]; then
    if id "virgola" &>/dev/null; then
      info "Updating password for existing user 'virgola'..."
      sudo passwd virgola
      success "Password updated for 'virgola'!"
    else
      info "User 'virgola' will be created during the system rebuild."
      info "You can set your password immediately after the first boot/switch with: ${BOLD}sudo passwd virgola${NC}"
    fi
  fi
fi

# 5. Git Status & Staging Check
info "Checking Git tracking..."
if [ -d ".git" ]; then
  git add -A
  success "All configuration files staged in Git."
fi

# 6. Flake Validation
echo ""
info "Validating flake configuration for host ${BOLD}$TARGET_HOST${NC}..."
if command -v nix >/dev/null 2>&1; then
  # Alejandra format check if available
  if nix fmt --help >/dev/null 2>&1; then
    info "Formatting Nix code with Alejandra..."
    nix fmt . >/dev/null 2>&1 || true
  fi

  info "Evaluating system toplevel derivation..."
  if nix eval ".#nixosConfigurations.$TARGET_HOST.config.system.build.toplevel.drvPath" --extra-experimental-features "nix-command flakes" >/dev/null; then
    success "Flake evaluation succeeded with 0 errors!"
  else
    error "Flake evaluation failed! Please inspect the errors above."
    exit 1
  fi
else
  warn "Nix binary not found in PATH. Skipping pre-build validation."
fi

# 7. Rebuild / Install Execution
if [ "$DRY_RUN" = true ]; then
  echo ""
  success "Dry-run complete! System configuration evaluated cleanly."
  info "To switch to this configuration manually, run:"
  echo -e "  ${BOLD}sudo nixos-rebuild switch --flake $REPO_DIR#$TARGET_HOST${NC}"
  exit 0
fi

echo ""
IS_LIVE_INSTALLER=false
if [ ! -d "/run/current-system" ] && [ -d "/mnt" ]; then
  IS_LIVE_INSTALLER=true
fi

if [ "$IS_LIVE_INSTALLER" = true ]; then
  ask "Live installer environment detected. Run 'nixos-install --flake .#$TARGET_HOST'? (Y/n): "
  read -r install_choice
  if [[ ! "$install_choice" =~ ^[Nn]$ ]]; then
    info "Starting NixOS installation to /mnt..."
    sudo nixos-install --flake ".#$TARGET_HOST"
    success "Installation complete! You may now reboot into your new system."
  fi
else
  ask "Apply configuration now with 'sudo nixos-rebuild switch --flake .#$TARGET_HOST'? (Y/n): "
  read -r switch_choice
  if [[ ! "$switch_choice" =~ ^[Nn]$ ]]; then
    info "Rebuilding and switching NixOS system..."
    sudo nixos-rebuild switch --flake ".#$TARGET_HOST"
    success "System successfully switched to #$TARGET_HOST!"
  else
    info "Skipped switch. You can manually apply anytime with:"
    echo -e "  ${BOLD}sudo nixos-rebuild switch --flake $REPO_DIR#$TARGET_HOST${NC}"
  fi
fi

# 8. Completion Summary
echo ""
echo "=============================================================================="
success "Bootstrap completed for ${BOLD}$TARGET_HOST${NC}!"
echo "=============================================================================="
echo ""
echo -e "  ${BOLD}Desktop Environment:${NC}  MangoWM + Noctalia Shell (Catppuccin Mocha)"
echo -e "  ${BOLD}Keybindings Cheatsheet:${NC} SUPER + H (Live interactive modal & cheatsheet)"
echo -e "  ${BOLD}Project Templates:${NC}      ninit (Python uv, Go, Rust, LaTeX/LuaTeX)"
echo -e "  ${BOLD}Security Suite:${NC}         Ghidra, Pwndbg, SageMath, Wireshark, Burp Suite"
echo -e "  ${BOLD}Vaultwarden SSH:${NC}        ssh-vault-add, ssh-vault-load"
echo ""
success "Enjoy your clean, declarative NixOS setup!"
