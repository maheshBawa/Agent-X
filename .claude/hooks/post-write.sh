#!/usr/bin/env bash
# Gate 2: POST-WRITE — Runs quality checks after code is written
# Batched: only runs full analysis at milestones, light checks per file
# Receives tool input via stdin as JSON
set -euo pipefail

TOOL_INPUT=$(cat)
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Skip if not an Agent-X project
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  exit 0
fi

# Extract file_path from JSON (portable)
FILE_PATH=$(echo "$TOOL_INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip .agent-x directory files
case "$FILE_PATH" in
  .agent-x/*|*/.agent-x/*) exit 0 ;;
esac

# Skip non-code files
case "$FILE_PATH" in
  *.md|*.json|*.yaml|*.yml|*.toml|*.txt|*.env*|*.gitignore|*.lock)
    exit 0
    ;;
esac

# Light check: scan for common security issues in the written file
if [ -f "$FILE_PATH" ]; then
  # Check for hardcoded secrets patterns
  SECRETS_FOUND=$(grep -nEi '(password|secret|api_key|apikey|token|private_key)[[:space:]]*=[[:space:]]*["\x27][^"\x27]{8,}' "$FILE_PATH" 2>/dev/null || true)
  if [ -n "$SECRETS_FOUND" ]; then
    echo "GATE 2 BLOCKED: Potential hardcoded secrets detected in $FILE_PATH:"
    echo "$SECRETS_FOUND"
    echo "Use environment variables instead."
    exit 1
  fi

  # Check for console.log / print statements (common debug leftovers)
  # Only warn, don't block
  DEBUG_FOUND=$(grep -nE 'console\.log|print\(' "$FILE_PATH" 2>/dev/null | head -5 || true)
  if [ -n "$DEBUG_FOUND" ]; then
    echo "GATE 2 WARNING: Debug statements found in $FILE_PATH (remove before commit):"
    echo "$DEBUG_FOUND"
  fi
fi

exit 0
