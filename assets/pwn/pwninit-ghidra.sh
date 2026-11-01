set -u  # no -e on purpose

PWNINIT_BIN="$(command -v pwninit)"
GHIDRA_SCRIPT="$(command -v ghidra-auto)"

if [[ -z "$PWNINIT_BIN" ]]; then
    echo "[!] pwninit not found"
    exit 1
fi

TEMPLATE_PATH="$HOME/.config/pwninit/pwninit-template.py"
if [[ ! -f "$TEMPLATE_PATH" ]]; then
    TEMPLATE_PATH="@templatePath@"
fi

# --- ALWAYS run pwninit ---
"$PWNINIT_BIN" \
    --template-path "$TEMPLATE_PATH" \
    --template-bin-name e \
    "$@"

# --- Ghidra: best effort only ---
BIN=""

if ls *_patched &>/dev/null; then
    BIN=$(ls *_patched | head -n1)
else
    BIN=$(file * 2>/dev/null | grep ELF | cut -d: -f1 | head -n1 || true)
fi

if [[ -n "$BIN" && -n "$GHIDRA_SCRIPT" ]]; then
    echo "[*] launching ghidra analysis for $BIN"
    "$GHIDRA_SCRIPT" "$(pwd)" >/dev/null 2>&1 &
    disown
else
    echo "[*] ghidra skipped (no binary or script missing)"
fi

# --- ALWAYS return success ---
true

