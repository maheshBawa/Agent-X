#!/usr/bin/env bash
# Gate 3: PRE-COMMIT — Validates before any git commit
# Runs as PreToolUse hook on Bash tool when command contains "git commit"
# Receives tool input via stdin as JSON
set -euo pipefail

TOOL_INPUT=$(cat)
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.agent-x/project-state.json"

# Skip if not an Agent-X project
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  exit 0
fi

# Only trigger on git commit commands (check the "command" field in JSON)
if ! echo "$TOOL_INPUT" | grep -q "git commit"; then
  exit 0
fi

ERRORS=""

# Check 1: Scan staged files for secrets
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
for file in $STAGED_FILES; do
  if [ -f "$file" ]; then
    SECRETS=$(grep -nEi '(password|secret|api_key|apikey|api.key|token|private_key|aws_access|aws_secret)[[:space:]]*=[[:space:]]*["\x27][^"\x27]{8,}' "$file" 2>/dev/null || true)
    if [ -n "$SECRETS" ]; then
      ERRORS="$ERRORS\nSECRETS in $file:\n$SECRETS"
    fi
  fi
done

# Check 2: Scan for .env files being committed
for file in $STAGED_FILES; do
  case "$file" in
    .env|.env.*|*.env)
      if ! echo "$file" | grep -qE '\.env\.example|\.env\.template'; then
        ERRORS="$ERRORS\nENV FILE: $file should not be committed. Add to .gitignore."
      fi
      ;;
  esac
done

# Check 3: Check for hardcoded IPs, URLs with credentials
for file in $STAGED_FILES; do
  if [ -f "$file" ]; then
    HARDCODED=$(grep -nE '(https?://[^@]*:[^@]*@|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]+)' "$file" 2>/dev/null || true)
    if [ -n "$HARDCODED" ]; then
      ERRORS="$ERRORS\nHARDCODED VALUES in $file:\n$HARDCODED"
    fi
  fi
done

# Check 4: TODO/FIXME check (only in VERIFY/DEPLOY phases)
if [ -f "$STATE_FILE" ]; then
  CURRENT_PHASE=$(sed -n 's/.*"current_phase"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -1)
  if [ "$CURRENT_PHASE" = "VERIFY" ] || [ "$CURRENT_PHASE" = "DEPLOY" ]; then
    for file in $STAGED_FILES; do
      if [ -f "$file" ]; then
        TODOS=$(grep -nEi '(TODO|FIXME|HACK|XXX)\b' "$file" 2>/dev/null || true)
        if [ -n "$TODOS" ]; then
          ERRORS="$ERRORS\nTODO/FIXME in $file (not allowed in $CURRENT_PHASE phase):\n$TODOS"
        fi
      fi
    done
  fi
fi

# Check 5: Run tests if test runner is available
if [ -f "$PROJECT_ROOT/package.json" ]; then
  if grep -q '"test"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    echo "GATE 3: Running tests..."
    if ! npm test --silent 2>/dev/null; then
      ERRORS="$ERRORS\nTESTS FAILED: Fix failing tests before committing."
    fi
  fi
elif [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
  if command -v pytest &>/dev/null; then
    echo "GATE 3: Running tests..."
    if ! pytest --quiet 2>/dev/null; then
      ERRORS="$ERRORS\nTESTS FAILED: Fix failing tests before committing."
    fi
  fi
fi

# Report results
if [ -n "$ERRORS" ]; then
  echo "GATE 3 BLOCKED — Pre-commit checks failed:"
  echo -e "$ERRORS"
  exit 1
fi

echo "GATE 3 PASSED: All pre-commit checks passed."
exit 0
