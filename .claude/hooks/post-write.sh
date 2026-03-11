#!/usr/bin/env bash
# Gate 2: POST-WRITE — Runs quality checks after code is written
# Batched: only runs full analysis at milestones, light checks per file
# Receives tool input via stdin as JSON
set -euo pipefail

TOOL_INPUT=$(cat)
# Resolve project root from the hook's own location (hooks live at <project>/.claude/hooks/)
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

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
  # Check for hardcoded secrets patterns (multiple detection strategies)
  SQ="'"
  SECRETS_FOUND=""

  # Pattern 1: Assignment with = (password = "value", api_key = 'value')
  S1=$(grep -nEi "(password|secret|api_key|apikey|api.key|token|private_key|db_pass|auth_token|STRIPE|OPENAI|GITHUB_TOKEN|AWS_ACCESS|AWS_SECRET)[[:space:]]*=[[:space:]]*[\"${SQ}][^\"${SQ}]{4,}" "$FILE_PATH" 2>/dev/null || true)

  # Pattern 2: JSON/dict notation ("password": "value")
  S2=$(grep -nEi "(\"password\"|\"secret\"|\"api_key\"|\"apikey\"|\"token\"|\"private_key\"|\"db_pass\"|\"auth_token\")[[:space:]]*:[[:space:]]*\"[^\"]{4,}\"" "$FILE_PATH" 2>/dev/null || true)

  # Pattern 3: Connection strings (postgresql://user:pass@host, mongodb://user:pass@host)
  S3=$(grep -nEi "(postgresql|mongodb|mysql|redis|amqp)://[^:]+:[^@]+@" "$FILE_PATH" 2>/dev/null || true)

  SECRETS_FOUND="${S1}${S2}${S3}"
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
