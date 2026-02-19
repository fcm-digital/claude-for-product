#!/bin/bash
# Installs the fcm-rag MCP into Claude Desktop and Claude Code
set -e

ITEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.mcp/fcm-rag"

source "$ITEM_DIR/../../lib/os.sh"
set_config_paths

echo "  Installing fcm-rag MCP..."

# --- Node.js check ---
if ! command -v node &>/dev/null; then
  echo ""
  echo "  ERROR: Node.js is required."
  echo "  Install it from https://nodejs.org (LTS version) and run again."
  echo ""
  exit 1
fi

# --- Prompt for RAG URL ---
RAG_URL="${FCM_RAG_URL:-}"

if [ -z "$RAG_URL" ]; then
  echo ""
  echo "  This MCP requires the RAG API URL."
  echo "  Ask the maintainer (@jeiker26) if you don't have it."
  echo ""
  read_input RAG_URL "  Enter the RAG API URL: "
  echo ""
fi

if [ -z "$RAG_URL" ]; then
  echo "  ERROR: RAG API URL is required. Aborting."
  exit 1
fi

# Append /query if not already present
[[ "$RAG_URL" != */query ]] && RAG_URL="${RAG_URL%/}/query"

# --- Copy files ---
mkdir -p "$(dirname "$INSTALL_DIR")"
rm -rf "$INSTALL_DIR"
cp -r "$ITEM_DIR" "$INSTALL_DIR"

# --- Install dependencies & build ---
npm install --prefix "$INSTALL_DIR" --silent 2>/dev/null
npm run build --prefix "$INSTALL_DIR" --silent 2>/dev/null

MCP_ENTRY=$(node -e "
console.log(JSON.stringify({
  command: 'node',
  args: ['$INSTALL_DIR/build/index.js'],
  env: { FCM_RAG_URL: '$RAG_URL' }
}));
")

# --- Claude Desktop ---
if [ -n "$CLAUDE_DESKTOP_CONFIG" ]; then
  mkdir -p "$(dirname "$CLAUDE_DESKTOP_CONFIG")"
  node -e "
const fs = require('fs');
const p = '$CLAUDE_DESKTOP_CONFIG';
let c = {};
if (fs.existsSync(p)) { try { c = JSON.parse(fs.readFileSync(p, 'utf-8')); } catch {} }
c.mcpServers = c.mcpServers || {};
c.mcpServers['fcm-rag'] = $MCP_ENTRY;
fs.writeFileSync(p, JSON.stringify(c, null, 2));
" 2>/dev/null && echo "  Claude Desktop configured." || echo "  Claude Desktop: skipped (not installed)."
else
  echo "  Claude Desktop: skipped (unsupported OS)."
fi

# --- Claude Code ---
node -e "
const fs = require('fs');
const p = '$CLAUDE_CODE_CONFIG';
if (!fs.existsSync(p)) { process.exit(0); }
let c = {};
try { c = JSON.parse(fs.readFileSync(p, 'utf-8')); } catch { process.exit(0); }
c.mcpServers = c.mcpServers || {};
c.mcpServers['fcm-rag'] = $MCP_ENTRY;
fs.writeFileSync(p, JSON.stringify(c, null, 2));
" 2>/dev/null && echo "  Claude Code configured." || echo "  Claude Code: skipped (not installed)."

echo "  Done. Restart Claude Desktop to activate."
