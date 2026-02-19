# Contributing

Thanks for sharing your MCPs and skills. Keep everything simple and readable so non-technical teammates can install it with one command.

---

## How the installer works

The root `install.sh` auto-discovers items by scanning `mcp/` and `skills/` for subdirectories that contain a `run.sh`. It reads the `## Purpose` section of each `README.md` to show a description in the menu.

This means: **if your item has a `run.sh` and a `## Purpose` in its README, it will appear automatically in the installer.**

---

## Adding a new item

1. Create a folder under `mcp/` or `skills/` using `kebab-case`:

```
mcp/my-tool/
  README.md
  run.sh
  ...any supporting files
```

2. Write the `README.md` using the standard sections (see below).
3. Write the `run.sh` following the conventions below.
4. Test it locally: `bash install.sh --mcp my-tool`

---

## README sections

Every item README must include these sections in this order:

```markdown
## Purpose
## Requirements
## Inputs
## Outputs
## Usage
## Examples
## Owner
## Status   ← Draft | Ready
```

The text under `## Purpose` is shown directly in the installer menu — keep it to one line.

---

## run.sh conventions

The `run.sh` is the installer for your item. It runs on the user's machine when they select it from the menu.

**Structure:**

```bash
#!/bin/bash
set -e

ITEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.mcp/my-tool"
LIB_DIR="$ITEM_DIR/../../lib"

# Always source the shared OS library — it handles macOS, Windows (Git Bash), and WSL.
source "$LIB_DIR/os.sh"
set_config_paths   # sets $CLAUDE_DESKTOP_CONFIG and $CLAUDE_CODE_CONFIG

echo "  Installing my-tool..."

# 1. Check dependencies
# 2. Prompt for tokens (see below)
# 3. Copy and build
# 4. Write to Claude config using the shared merge helper (see below)
```

**Writing to Claude config:**

Always use `lib/merge-mcp-config.js` — never write to the config files directly. The helper preserves all existing configuration, backs up before writing, and aborts with a clear error if the existing file has invalid JSON.

```bash
MCP_ENTRY=$(node -e "
console.log(JSON.stringify({
  command: 'node',
  args: ['\$INSTALL_DIR/build/index.js'],
  env: { MY_TOKEN: '\$MY_TOKEN' }
}));
")

# Claude Desktop
if [ -n "$CLAUDE_DESKTOP_CONFIG" ]; then
  node "$LIB_DIR/merge-mcp-config.js" "$CLAUDE_DESKTOP_CONFIG" "my-tool" "$MCP_ENTRY"
  echo "  Claude Desktop configured."
else
  echo "  Claude Desktop: skipped (unsupported OS)."
fi

# Claude Code
if [ -f "$CLAUDE_CODE_CONFIG" ]; then
  node "$LIB_DIR/merge-mcp-config.js" "$CLAUDE_CODE_CONFIG" "my-tool" "$MCP_ENTRY"
  echo "  Claude Code configured."
else
  echo "  Claude Code: skipped (not installed)."
fi
```

**Rules:**
- Always start with `set -e` so errors stop the script.
- Always `source lib/os.sh` and call `set_config_paths` — never hard-code config paths.
- Always use `lib/merge-mcp-config.js` to write to Claude configs — never write directly.
- Use `read_input` / `read_secret` from `lib/os.sh` instead of raw `read` — they handle `curl | bash` and Windows correctly.
- Print short, friendly messages prefixed with two spaces (`  `).
- Configure both Claude Desktop and Claude Code when possible (see the fcm-rag example).
- Never hard-code secrets. Use the token prompt pattern below.

---

## Handling tokens and secrets

**Tokens must never be committed to the repo.** The `run.sh` prompts the user for any required credentials at install time and injects them into the local Claude config as environment variables.

### Pattern

```bash
# 1. Allow passing via env var (useful for automation)
MY_TOKEN="${MY_TOKEN:-}"

# 2. If not set, prompt the user
if [ -z "$MY_TOKEN" ]; then
  echo ""
  echo "  This MCP requires a token."
  echo "  You can find it at: https://example.com/settings/tokens"
  echo ""
  echo -n "  Enter your token: "
  read -rs MY_TOKEN </dev/tty
  echo ""
fi

# 3. Validate
if [ -z "$MY_TOKEN" ]; then
  echo "  ERROR: Token is required. Aborting."
  exit 1
fi

# 4. Inject into Claude config via the env block
MCP_ENTRY=$(node -e "
console.log(JSON.stringify({
  command: 'node',
  args: ['$INSTALL_DIR/build/index.js'],
  env: { MY_TOKEN: '$MY_TOKEN' }
}));
")
```

The token is stored only in `~/Library/Application Support/Claude/claude_desktop_config.json` (Claude Desktop) and `~/.claude.json` (Claude Code) — local files on the user's machine, never in the repo.

### Updating a token

The user can re-run the installer at any time to update their token:

```bash
curl -fsSL https://raw.githubusercontent.com/fcm-digital/claude-for-product/main/install.sh | bash
```

---

## Checklist before merging

- [ ] Folder uses `kebab-case`
- [ ] `README.md` has all standard sections; `## Purpose` is one line
- [ ] `run.sh` is executable (`chmod +x run.sh`) and starts with `#!/bin/bash`
- [ ] No tokens or secrets anywhere in the files
- [ ] Tested locally with `bash install.sh --mcp <name>` or `bash install.sh --skill <name>`
- [ ] Status in README set to `Ready`
