#!/usr/bin/env bash
# Agent-X Setup Script
# One-command installer for macOS and Linux
set -euo pipefail

AGENT_X_HOME="$(cd "$(dirname "$0")" && pwd)"
PROFILE_FILE="$AGENT_X_HOME/profiles/default.json"

echo "============================================"
echo "  AGENT-X SETUP"
echo "  Autonomous AI Development Environment"
echo "============================================"
echo ""

# Step 1: Check prerequisites
echo "[1/5] Checking prerequisites..."

if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code is not installed."
  echo "Install it from: https://claude.ai/code"
  exit 1
fi
echo "  ✓ Claude Code found"

if ! command -v git &>/dev/null; then
  echo "ERROR: git is not installed."
  exit 1
fi
echo "  ✓ git found"

if command -v node &>/dev/null; then
  echo "  ✓ Node.js found ($(node --version))"
else
  echo "  ⚠ Node.js not found (needed for JavaScript/TypeScript stacks)"
fi

if command -v python3 &>/dev/null; then
  echo "  ✓ Python found ($(python3 --version))"
else
  echo "  ⚠ Python not found (needed for Python stacks)"
fi

if command -v gh &>/dev/null; then
  echo "  ✓ GitHub CLI found"
else
  echo "  ⚠ GitHub CLI (gh) not found (needed for evolution engine)"
  echo "    Install from: https://cli.github.com/"
fi

echo ""

# Step 2: Initialize git if needed
echo "[2/5] Setting up repository..."
if [ ! -d "$AGENT_X_HOME/.git" ]; then
  cd "$AGENT_X_HOME" && git init
  echo "  ✓ Git repository initialized"
else
  echo "  ✓ Git repository exists"
fi

# Step 3: Make hook scripts executable
echo "[3/5] Configuring quality gates..."
if [ -d "$AGENT_X_HOME/.claude/hooks" ]; then
  chmod +x "$AGENT_X_HOME/.claude/hooks/"*.sh 2>/dev/null || true
  echo "  ✓ Quality gate hooks configured"
else
  echo "  ⚠ Hooks directory not found"
fi

# Step 4: Create user profile if first time
echo "[4/5] Setting up profile..."
if [ -f "$PROFILE_FILE" ]; then
  NAME=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PROFILE_FILE" | head -1)
  if [ -z "$NAME" ]; then
    echo "  First-time setup detected. Let's configure your profile."
    echo ""
    read -p "  Your name: " USER_NAME
    read -p "  Preferred languages (comma-separated, e.g., TypeScript,Python): " USER_LANGS
    read -p "  Design taste (e.g., minimal, modern, corporate): " USER_TASTE

    LANGS_JSON=$(echo "$USER_LANGS" | sed 's/,/","/g' | sed 's/^/["/;s/$/"]/')
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat > "$PROFILE_FILE" << PROFILE
{
  "version": "1.0.0",
  "name": "$USER_NAME",
  "preferred_languages": $LANGS_JSON,
  "design_taste": "$USER_TASTE",
  "communication_style": "concise, technical",
  "risk_tolerance": "low",
  "default_cloud": null,
  "auto_deploy": false,
  "custom_rules": [],
  "created_at": "$TIMESTAMP",
  "updated_at": "$TIMESTAMP"
}
PROFILE
    echo "  ✓ Profile created"
  else
    echo "  ✓ Profile exists (welcome back, $NAME)"
  fi
fi

# Step 5: CLI setup
echo "[5/5] Setting up CLI..."
chmod +x "$AGENT_X_HOME/agent-x" 2>/dev/null || true
echo "  ✓ CLI ready"
echo "  To use globally, add to PATH:"
echo "    export PATH=\"$AGENT_X_HOME:\$PATH\""

echo ""
echo "============================================"
echo "  Agent-X online. Ready to build."
echo "============================================"
echo ""
echo "Usage:"
echo "  cd your-project-dir"
echo "  $AGENT_X_HOME/agent-x init"
echo "  claude"
echo ""
