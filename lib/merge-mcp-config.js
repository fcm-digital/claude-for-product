#!/usr/bin/env node
// Safely merges a single MCP entry into a Claude config file.
// Usage: node merge-mcp-config.js <config-path> <mcp-name> <mcp-json-string>
//
// Behaviour:
//   - File doesn't exist  → creates it with just the new MCP entry.
//   - File exists, valid JSON  → merges only mcpServers[<mcp-name>], preserves all other keys.
//   - File exists, invalid JSON → prints an error and exits 1 (no data loss).
//   - Creates a .bak backup before every write.

const fs = require('fs');
const path = require('path');

const [,, configPath, mcpName, mcpJson] = process.argv;

if (!configPath || !mcpName || !mcpJson) {
  console.error('Usage: node merge-mcp-config.js <config-path> <mcp-name> <mcp-json-string>');
  process.exit(1);
}

let mcpEntry;
try {
  mcpEntry = JSON.parse(mcpJson);
} catch (e) {
  console.error(`  ERROR: Invalid MCP entry JSON: ${e.message}`);
  process.exit(1);
}

let config = {};
if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, 'utf-8');
  try {
    config = JSON.parse(raw);
  } catch {
    console.error(`  ERROR: Config file contains invalid JSON and cannot be safely updated:`);
    console.error(`  ${configPath}`);
    console.error(`  Fix the JSON manually, then re-run the installer.`);
    process.exit(1);
  }
  fs.copyFileSync(configPath, configPath + '.bak');
}

config.mcpServers = config.mcpServers || {};
config.mcpServers[mcpName] = mcpEntry;

fs.mkdirSync(path.dirname(configPath), { recursive: true });
fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
