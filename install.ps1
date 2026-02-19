# Claude for Product — Windows Installer
# Usage:
#   Interactive:  .\install.ps1
#   Specific:     .\install.ps1 -Mcp fcm-rag -Skill my-skill
#   All:          .\install.ps1 -All
#   List:         .\install.ps1 -List

param(
    [string[]]$Mcp,
    [string[]]$Skill,
    [switch]$All,
    [switch]$List
)

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/fcm-digital/claude-for-product"
$LOCAL_REPO = "$env:USERPROFILE\.claude-for-product"

# ── Resolve repo dir ──────────────────────────────────────────────────────────
$SCRIPT_PATH = $PSScriptRoot
if ($SCRIPT_PATH -and (Test-Path "$SCRIPT_PATH\mcp")) {
    $REPO_DIR = $SCRIPT_PATH
} else {
    # Running standalone — clone or update
    if (Test-Path "$LOCAL_REPO\.git") {
        Write-Host "Updating repository..."
        git -C $LOCAL_REPO pull --quiet
    } else {
        Write-Host "Downloading repository..."
        git clone --quiet $REPO_URL $LOCAL_REPO
    }
    $REPO_DIR = $LOCAL_REPO
}

# ── Discover items ────────────────────────────────────────────────────────────
function Discover-Items {
    param([string]$Kind)
    
    $base = Join-Path $REPO_DIR $Kind
    if (-not (Test-Path $base)) { return @() }
    
    $items = @()
    Get-ChildItem -Path $base -Directory | ForEach-Object {
        $runScript = Join-Path $_.FullName "run.ps1"
        if (-not (Test-Path $runScript)) { return }
        
        $name = $_.Name
        $purpose = ""
        $readme = Join-Path $_.FullName "README.md"
        if (Test-Path $readme) {
            $content = Get-Content $readme -Raw
            if ($content -match '## Purpose\s*\n+([^\n#]+)') {
                $purpose = $Matches[1].Trim()
            }
        }
        $items += [PSCustomObject]@{
            Kind = $Kind
            Name = $name
            Purpose = $purpose
            Path = $runScript
        }
    }
    return $items
}

$ALL_ITEMS = @()
$ALL_ITEMS += Discover-Items "mcp"
$ALL_ITEMS += Discover-Items "skills"

# ── Helpers ───────────────────────────────────────────────────────────────────
function Print-Header {
    Write-Host ""
    Write-Host "  Claude for Product — Installer" -ForegroundColor White
    Write-Host "  ---------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Print-Items {
    $i = 1
    $currentKind = ""
    foreach ($item in $ALL_ITEMS) {
        if ($item.Kind -ne $currentKind) {
            Write-Host "  $($item.Kind.ToUpper())" -ForegroundColor Cyan
            $currentKind = $item.Kind
        }
        $nameFormatted = $item.Name.PadRight(20)
        Write-Host "  [$i] " -NoNewline -ForegroundColor White
        Write-Host "$nameFormatted " -NoNewline
        Write-Host $item.Purpose -ForegroundColor DarkGray
        $i++
    }
}

function Run-Item {
    param(
        [string]$Kind,
        [string]$Name
    )
    
    $runScript = Join-Path $REPO_DIR "$Kind\$Name\run.ps1"
    if (-not (Test-Path $runScript)) {
        Write-Host "  Warning: $Kind/$Name/run.ps1 not found - skipping." -ForegroundColor Yellow
        return
    }
    Write-Host ""
    Write-Host "  > Installing $Kind/$Name" -ForegroundColor White
    & $runScript
}

# ── Modes ─────────────────────────────────────────────────────────────────────

# -List
if ($List) {
    Print-Header
    Print-Items
    Write-Host ""
    exit 0
}

# -All
if ($All) {
    Print-Header
    Write-Host "  Installing all items..."
    foreach ($item in $ALL_ITEMS) {
        Run-Item -Kind $item.Kind -Name $item.Name
    }
    Write-Host ""
    Write-Host "  All done. Restart Claude Desktop / Windsurf to activate." -ForegroundColor Green
    Write-Host ""
    exit 0
}

# -Mcp / -Skill (flags mode)
if ($Mcp -or $Skill) {
    Print-Header
    foreach ($name in $Mcp) {
        Run-Item -Kind "mcp" -Name $name
    }
    foreach ($name in $Skill) {
        Run-Item -Kind "skills" -Name $name
    }
    Write-Host ""
    Write-Host "  Done. Restart Claude Desktop / Windsurf to activate." -ForegroundColor Green
    Write-Host ""
    exit 0
}

# ── Interactive menu (default) ────────────────────────────────────────────────
Print-Header

if ($ALL_ITEMS.Count -eq 0) {
    Write-Host "  No items found in mcp/ or skills/."
    Write-Host ""
    exit 0
}

Print-Items

Write-Host ""
Write-Host "  Enter numbers to install " -NoNewline
Write-Host "(e.g. 1 3)" -NoNewline -ForegroundColor DarkGray
Write-Host ", " -NoNewline
Write-Host "all" -NoNewline -ForegroundColor White
Write-Host ", or " -NoNewline
Write-Host "q" -NoNewline -ForegroundColor White
Write-Host " to quit:"
$selection = Read-Host "  >"

if ($selection -eq "q" -or $selection -eq "quit") {
    Write-Host ""
    exit 0
}

$SELECTED = @()
if ($selection -eq "all") {
    $SELECTED = 0..($ALL_ITEMS.Count - 1)
} else {
    $numbers = $selection -split '\s+'
    foreach ($n in $numbers) {
        if ($n -match '^\d+$') {
            $idx = [int]$n
            if ($idx -ge 1 -and $idx -le $ALL_ITEMS.Count) {
                $SELECTED += ($idx - 1)
            } else {
                Write-Host "  Skipping invalid option: $n" -ForegroundColor Yellow
            }
        } elseif ($n -ne "") {
            Write-Host "  Skipping invalid option: $n" -ForegroundColor Yellow
        }
    }
}

if ($SELECTED.Count -eq 0) {
    Write-Host "  Nothing selected."
    Write-Host ""
    exit 0
}

foreach ($idx in $SELECTED) {
    $item = $ALL_ITEMS[$idx]
    Run-Item -Kind $item.Kind -Name $item.Name
}

Write-Host ""
Write-Host "  Done. Restart Claude Desktop / Windsurf to activate." -ForegroundColor Green
Write-Host ""
