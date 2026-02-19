#!/bin/bash
# Claude for Product — Installer
# Usage:
#   Interactive:  bash install.sh
#   Specific:     bash install.sh --mcp fcm-rag --skill my-skill
#   All:          bash install.sh --all
#   List:         bash install.sh --list
#   Remote:       curl -fsSL <raw-url>/install.sh | bash

set -e

REPO_URL="https://github.com/fcm-digital/claude-for-product"
LOCAL_REPO="$HOME/.claude-for-product"


# ── Colors ────────────────────────────────────────────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ── Resolve repo dir ──────────────────────────────────────────────────────────
# If running from inside the repo use it directly; otherwise clone/update.
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
if [ -n "$SCRIPT_SOURCE" ] && [ -f "$SCRIPT_SOURCE" ]; then
  REPO_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
  source "$REPO_DIR/lib/os.sh"
else
  # Running via pipe (curl | bash) — clone or update
  if [ -d "$LOCAL_REPO/.git" ]; then
    echo "Updating repository..."
    git -C "$LOCAL_REPO" pull --quiet
  else
    echo "Downloading repository..."
    git clone --quiet "$REPO_URL" "$LOCAL_REPO"
  fi
  REPO_DIR="$LOCAL_REPO"
  # Re-exec from the cloned copy so relative paths work
  exec bash "$REPO_DIR/install.sh" "$@"
fi

# ── Discover items ────────────────────────────────────────────────────────────
discover() {
  local kind="$1"          # mcp | skills
  local base="$REPO_DIR/$kind"
  [ -d "$base" ] || return
  for dir in "$base"/*/; do
    [ -f "$dir/run.sh" ] || continue
    local name
    name="$(basename "$dir")"
    local purpose=""
    if [ -f "$dir/README.md" ]; then
      purpose="$(awk '/^## Purpose/{found=1; next} found && /^[^#[:space:]]/{print; exit} found && /^## /{exit}' "$dir/README.md" 2>/dev/null | head -1)"
    fi
    echo "$kind|$name|$purpose"
  done
}

ALL_ITEMS=()
while IFS= read -r line; do
  ALL_ITEMS+=("$line")
done < <({ discover mcp; discover skills; })

# ── Helpers ───────────────────────────────────────────────────────────────────
print_header() {
  echo ""
  echo -e "${BOLD}  Claude for Product — Installer${RESET}"
  echo -e "${DIM}  ─────────────────────────────────${RESET}"
  echo ""
}

print_items() {
  local i=1
  local current_kind=""
  for item in "${ALL_ITEMS[@]}"; do
    IFS='|' read -r kind name purpose <<< "$item"
    if [ "$kind" != "$current_kind" ]; then
      echo -e "  ${CYAN}$(echo "$kind" | tr '[:lower:]' '[:upper:]')${RESET}"
      current_kind="$kind"
    fi
    printf "  ${BOLD}[%d]${RESET} %-20s ${DIM}%s${RESET}\n" "$i" "$name" "$purpose"
    ((i++))
  done
}

run_item() {
  local kind="$1"
  local name="$2"
  local run_script="$REPO_DIR/$kind/$name/run.sh"
  if [ ! -f "$run_script" ]; then
    echo -e "  ${YELLOW}Warning: $kind/$name/run.sh not found — skipping.${RESET}"
    return
  fi
  echo ""
  echo -e "${BOLD}  ▶ Installing $kind/$name${RESET}"
  bash "$run_script"
}

# ── Modes ─────────────────────────────────────────────────────────────────────

# --list
if [[ "$1" == "--list" ]]; then
  print_header
  print_items
  echo ""
  exit 0
fi

# --all
if [[ "$1" == "--all" ]]; then
  print_header
  echo "  Installing all items..."
  for item in "${ALL_ITEMS[@]}"; do
    IFS='|' read -r kind name _ <<< "$item"
    run_item "$kind" "$name"
  done
  echo ""
  echo -e "${GREEN}  All done. Restart Claude Desktop to activate.${RESET}"
  echo ""
  exit 0
fi

# --mcp <name> --skill <name> (flags mode)
if [[ "$1" == "--mcp" || "$1" == "--skill" ]]; then
  print_header
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mcp)   run_item "mcp"    "$2"; shift 2 ;;
      --skill) run_item "skills" "$2"; shift 2 ;;
      *)       shift ;;
    esac
  done
  echo ""
  echo -e "${GREEN}  Done. Restart Claude Desktop to activate.${RESET}"
  echo ""
  exit 0
fi

# ── Interactive menu (default) ────────────────────────────────────────────────
print_header

if [ ${#ALL_ITEMS[@]} -eq 0 ]; then
  echo "  No items found in mcp/ or skills/."
  echo ""
  exit 0
fi

print_items

echo ""
echo -e "  Enter numbers to install ${DIM}(e.g. 1 3)${RESET}, ${BOLD}all${RESET}, or ${BOLD}q${RESET} to quit:"
read_input selection "  > "

if [[ "$selection" == "q" || "$selection" == "quit" ]]; then
  echo ""
  exit 0
fi

SELECTED=()
if [[ "$selection" == "all" ]]; then
  SELECTED=("${!ALL_ITEMS[@]}")
else
  for n in $selection; do
    if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#ALL_ITEMS[@]}" ]; then
      SELECTED+=($((n - 1)))
    else
      echo -e "  ${YELLOW}Skipping invalid option: $n${RESET}"
    fi
  done
fi

if [ ${#SELECTED[@]} -eq 0 ]; then
  echo "  Nothing selected."
  echo ""
  exit 0
fi

for idx in "${SELECTED[@]}"; do
  IFS='|' read -r kind name _ <<< "${ALL_ITEMS[$idx]}"
  run_item "$kind" "$name"
done

echo ""
echo -e "${GREEN}  Done. Restart Claude Desktop to activate.${RESET}"
echo ""
