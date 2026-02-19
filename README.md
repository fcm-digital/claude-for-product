# Claude for Product

Shared catalog of MCPs and skills for FCM product teams.

---

## Install (one command)

Open **Terminal** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/fcm-digital/claude-for-product/main/install.sh | bash
```

You'll see a menu like this:

```
  Claude for Product — Installer
  ─────────────────────────────────

  MCP
  [1] fcm-rag              Connects Claude to the FCM knowledge base

  Enter numbers to install (e.g. 1 3), all, or q to quit:
  >
```

Type the numbers you want, press Enter, and restart Claude Desktop when done.

If an item requires a token or URL, the installer will ask for it — nothing is stored in the repo.

---

## Requirements

- Mac with **Claude Desktop** or **Claude Code** installed
- **Node.js** LTS — [nodejs.org](https://nodejs.org)
- **Git** — pre-installed on most Macs; if missing: `xcode-select --install`

---

## For contributors

Clone the repo and run the installer locally:

```bash
git clone https://github.com/fcm-digital/claude-for-product.git
cd claude-for-product

# List available items
bash install.sh --list

# Install a specific MCP
bash install.sh --mcp fcm-rag

# Install a specific skill
bash install.sh --skill my-skill

# Install everything
bash install.sh --all
```

See `CONTRIBUTING.md` to learn how to add new MCPs and skills.
