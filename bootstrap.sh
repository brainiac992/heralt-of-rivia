#!/usr/bin/env bash
# HERALD bootstrap — adds /install-herald to Claude Code globally
# Run once. After this, /install-herald is available in any Claude Code session.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/brainiac992/herald-of-rivia/main/bootstrap.sh | bash

set -e

COMMANDS_DIR="$HOME/.claude/commands"
INSTALL_FILE="$COMMANDS_DIR/install-herald.md"
RAW_URL="https://raw.githubusercontent.com/brainiac992/herald-of-rivia/main/.claude/commands/install-herald.md"

mkdir -p "$COMMANDS_DIR"

if [ -f "$INSTALL_FILE" ]; then
  echo "HERALD bootstrap: /install-herald already exists at $INSTALL_FILE"
  echo "Run \`/install-herald\` in any Claude Code session to install HERALD into a project."
  exit 0
fi

if command -v curl &>/dev/null; then
  curl -fsSL "$RAW_URL" -o "$INSTALL_FILE"
elif command -v wget &>/dev/null; then
  wget -qO "$INSTALL_FILE" "$RAW_URL"
else
  echo "Error: curl or wget is required." >&2
  exit 1
fi

echo ""
echo "HERALD bootstrap complete."
echo ""
echo "  /install-herald is now available globally in Claude Code."
echo ""
echo "To install HERALD into any project:"
echo "  1. Open the project in Claude Code"
echo "  2. Run: /install-herald"
echo ""
