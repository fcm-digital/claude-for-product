#!/bin/bash
# Installs the dovetail-mcp MCP into Claude Desktop and Claude Code
set -e

ITEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.mcp/dovetail-mcp"
LIB_DIR="$ITEM_DIR/../../lib"

source "$LIB_DIR/os.sh"
set_config_paths

echo "  Installing dovetail-mcp..."

# --- Node.js check (requires v22+) ---
if ! command -v node &>/dev/null; then
  echo ""
  echo "  ERROR: Node.js v22 or later is required."
  echo "  Install it from https://nodejs.org (LTS version) and run again."
  echo ""
  exit 1
fi

NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo ""
  echo "  ERROR: Node.js v22 or later is required (you have $(node -v))."
  echo "  Update it from https://nodejs.org and run again."
  echo ""
  exit 1
fi

# --- Prompt for API token ---
DOVETAIL_API_TOKEN="${DOVETAIL_API_TOKEN:-}"

if [ -z "$DOVETAIL_API_TOKEN" ]; then
  echo ""
  echo "  This MCP requires a Dovetail API token."
  echo "  Get yours at: https://developers.dovetail.com/docs/introduction"
  echo ""
  read_secret DOVETAIL_API_TOKEN "  Enter your Dovetail API token: "
fi

if [ -z "$DOVETAIL_API_TOKEN" ]; then
  echo "  ERROR: Dovetail API token is required. Aborting."
  exit 1
fi

# --- Download pre-built binary ---
mkdir -p "$INSTALL_DIR"
echo "  Downloading latest dovetail-mcp release..."
curl -fsSL "https://github.com/dovetail/dovetail-mcp/releases/latest/download/index.js" \
  -o "$INSTALL_DIR/index.js"

MCP_ENTRY=$(node -e "
console.log(JSON.stringify({
  command: 'node',
  args: ['$INSTALL_DIR/index.js'],
  env: { DOVETAIL_API_TOKEN: '$DOVETAIL_API_TOKEN' }
}));
")

# --- Claude Desktop ---
if [ -n "$CLAUDE_DESKTOP_CONFIG" ]; then
  node "$LIB_DIR/merge-mcp-config.js" "$CLAUDE_DESKTOP_CONFIG" "dovetail-mcp" "$MCP_ENTRY"
  echo "  Claude Desktop configured."
else
  echo "  Claude Desktop: skipped (unsupported OS)."
fi

# --- Claude Code ---
if [ -f "$CLAUDE_CODE_CONFIG" ]; then
  node "$LIB_DIR/merge-mcp-config.js" "$CLAUDE_CODE_CONFIG" "dovetail-mcp" "$MCP_ENTRY"
  echo "  Claude Code configured."
else
  echo "  Claude Code: skipped (not installed)."
fi

echo "  Done. Restart Claude Desktop to activate."
