# dovetail-mcp

## Purpose
Connect Claude to Dovetail to query research, insights, and customer feedback.

## Requirements
- Node.js v22 or later
- A Dovetail API token — get yours at https://developers.dovetail.com/docs/introduction

## Inputs
- `DOVETAIL_API_TOKEN`: your Dovetail API token (prompted at install time, never stored in the repo)

## Outputs
- Configures `dovetail-mcp` under `mcpServers` in Claude Desktop and Claude Code
- Installs the pre-built binary at `~/.mcp/dovetail-mcp/index.js`

## Usage

Run the installer and enter your token when prompted:

```bash
bash install.sh --mcp dovetail-mcp
```

To update your token, re-run the installer at any time.

## Examples

Once installed, you can ask Claude things like:
- "Summarise the latest research notes in Dovetail"
- "What are the top pain points from user interviews this quarter?"
- "Find all insights tagged with 'onboarding'"

## Owner
@jeiker26

## Status
Ready
