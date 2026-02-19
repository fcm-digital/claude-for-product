# Installs the fcm-rag MCP into Claude Desktop and Windsurf on Windows
$ErrorActionPreference = "Stop"

$ITEM_DIR = $PSScriptRoot
$INSTALL_DIR = "$env:USERPROFILE\.mcp\fcm-rag"
$CLAUDE_DESKTOP_CONFIG = "$env:APPDATA\Claude\claude_desktop_config.json"
$WINDSURF_CONFIG = "$env:APPDATA\Windsurf\mcp_config.json"

Write-Host "  Installing fcm-rag MCP..."

# --- Node.js check ---
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  ERROR: Node.js is required."
    Write-Host "  Install it from https://nodejs.org (LTS version) and run again."
    Write-Host ""
    exit 1
}

# --- Prompt for RAG URL ---
$RAG_URL = $env:FCM_RAG_URL

if ([string]::IsNullOrEmpty($RAG_URL)) {
    Write-Host ""
    Write-Host "  This MCP requires the RAG API URL."
    Write-Host "  Ask the maintainer (@jeiker26) if you don't have it."
    Write-Host ""
    $RAG_URL = Read-Host "  Enter the RAG API URL"
    Write-Host ""
}

if ([string]::IsNullOrEmpty($RAG_URL)) {
    Write-Host "  ERROR: RAG API URL is required. Aborting."
    exit 1
}

# Append /query if not already present
if (-not $RAG_URL.EndsWith("/query")) {
    $RAG_URL = $RAG_URL.TrimEnd("/") + "/query"
}

# --- Copy files ---
$parentDir = Split-Path $INSTALL_DIR -Parent
if (-not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}
if (Test-Path $INSTALL_DIR) {
    Remove-Item -Recurse -Force $INSTALL_DIR
}
Copy-Item -Recurse $ITEM_DIR $INSTALL_DIR

# --- Install dependencies & build ---
Push-Location $INSTALL_DIR
npm install --silent 2>$null
npm run build --silent 2>$null
Pop-Location

# --- Build MCP entry with WINDOWS-NATIVE path (forward slashes work in JSON) ---
$indexPath = "$INSTALL_DIR\build\index.js" -replace '\\', '/'
$mcpEntry = @{
    command = "node"
    args = @($indexPath)
    env = @{
        FCM_RAG_URL = $RAG_URL
    }
}

# --- Claude Desktop ---
$claudeDir = Split-Path $CLAUDE_DESKTOP_CONFIG -Parent
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

if (Test-Path $CLAUDE_DESKTOP_CONFIG) {
    try {
        $config = Get-Content $CLAUDE_DESKTOP_CONFIG -Raw | ConvertFrom-Json
    } catch {
        $config = @{}
    }
} else {
    $config = @{}
}

if (-not $config.mcpServers) {
    $config | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{} -Force
}
$config.mcpServers | Add-Member -NotePropertyName "fcm-rag" -NotePropertyValue $mcpEntry -Force

$config | ConvertTo-Json -Depth 10 | Set-Content $CLAUDE_DESKTOP_CONFIG -Encoding UTF8
Write-Host "  Claude Desktop configured."

# --- Windsurf ---
$windsurfDir = Split-Path $WINDSURF_CONFIG -Parent
if (Test-Path $windsurfDir) {
    if (Test-Path $WINDSURF_CONFIG) {
        try {
            $wsConfig = Get-Content $WINDSURF_CONFIG -Raw | ConvertFrom-Json
        } catch {
            $wsConfig = @{}
        }
    } else {
        $wsConfig = @{}
    }

    if (-not $wsConfig.mcpServers) {
        $wsConfig | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{} -Force
    }
    $wsConfig.mcpServers | Add-Member -NotePropertyName "fcm-rag" -NotePropertyValue $mcpEntry -Force

    $wsConfig | ConvertTo-Json -Depth 10 | Set-Content $WINDSURF_CONFIG -Encoding UTF8
    Write-Host "  Windsurf configured."
} else {
    Write-Host "  Windsurf: skipped (not installed)."
}

Write-Host ""
Write-Host "  Done! Restart Claude Desktop / Windsurf to use fcm-rag."
Write-Host ""
