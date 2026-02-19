#!/bin/bash
# Shared OS detection and path helpers.
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

detect_os() {
  case "$(uname -s)" in
    Darwin)           echo "macos" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows-bash" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

# Sets CLAUDE_DESKTOP_CONFIG and CLAUDE_CODE_CONFIG for the current OS.
set_config_paths() {
  local os
  os=$(detect_os)

  case "$os" in
    macos)
      CLAUDE_DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
      CLAUDE_CODE_CONFIG="$HOME/.claude.json"
      ;;
    windows-bash)
      CLAUDE_DESKTOP_CONFIG="$APPDATA/Claude/claude_desktop_config.json"
      CLAUDE_CODE_CONFIG="$HOME/.claude.json"
      ;;
    wsl)
      local win_user
      win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
      CLAUDE_DESKTOP_CONFIG="/mnt/c/Users/$win_user/AppData/Roaming/Claude/claude_desktop_config.json"
      CLAUDE_CODE_CONFIG="$HOME/.claude.json"
      ;;
    *)
      echo "  WARNING: OS not supported. Claude Desktop config will not be configured."
      CLAUDE_DESKTOP_CONFIG=""
      CLAUDE_CODE_CONFIG="$HOME/.claude.json"
      ;;
  esac
}

# read_input <varname> <prompt>
# Reads from /dev/tty when available (works with curl | bash and Git Bash).
read_input() {
  local varname="$1"
  local prompt="$2"
  echo -n "$prompt"
  if [ -e /dev/tty ]; then
    read -r "$varname" </dev/tty
  else
    read -r "$varname"
  fi
}

# read_secret <varname> <prompt>
# Same as read_input but hides characters (for tokens/passwords).
read_secret() {
  local varname="$1"
  local prompt="$2"
  echo -n "$prompt"
  if [ -e /dev/tty ]; then
    read -rs "$varname" </dev/tty
  else
    read -rs "$varname"
  fi
  echo ""
}
