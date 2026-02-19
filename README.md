# Claude for Product

Shared catalog of MCPs and skills for FCM product teams.

---

## Requirements


### macOS
- **Claude Desktop** or **Claude Code** installed
- **Node.js** LTS — [nodejs.org](https://nodejs.org)
- **Git** — pre-installed on most Macs; if missing: `xcode-select --install`

### Windows
- **Claude Desktop** or **Windsurf** installed
- **Node.js** LTS — [nodejs.org](https://nodejs.org)
- **Git** — [git-scm.com](https://git-scm.com/download/win)
- **PowerShell** 5.1+ (pre-installed on Windows 10/11)

---

## Install on MacOS (one command)

Open **Terminal** (Mac) and run:

```bash
curl -fsSL https://raw.githubusercontent.com/fcm-digital/claude-for-product/refs/heads/master/install.sh | bash
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

## Install on Windows

Open **PowerShell** and run:

```powershell
git clone https://github.com/fcm-digital/claude-for-product.git
cd claude-for-product
.\install.ps1
```

You'll see the same interactive menu. Type the numbers you want, press Enter, and restart Claude Desktop / Windsurf when done.

**Alternative commands:**

```powershell
# List available items
.\install.ps1 -List

# Install a specific MCP
.\install.ps1 -Mcp fcm-rag

# Install a specific skill
.\install.ps1 -Skill my-skill

# Install everything
.\install.ps1 -All
```

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
