#!/usr/bin/env bash
# Stack-specific quality runner — invokes linter, formatter, type checker from stack.json
# Called at milestone boundaries during BUILD phase
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

STATE_FILE="$PROJECT_ROOT/.agent-x/project-state.json"
STACK_DECISION="$PROJECT_ROOT/.agent-x/stack-decision.md"

# Skip if not an Agent-X project
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  echo "Not an Agent-X project. Skipping."
  exit 0
fi

# Determine the stack ID from stack-decision.md
STACK_ID=""
if [ -f "$STACK_DECISION" ]; then
  # Look for stack ID in the decision file (e.g., "Stack: nextjs-postgres" or "nextjs-postgres")
  STACK_ID=$(grep -oE '(nextjs-postgres|react-native-expo|python-fastapi|node-express-mongo|static-site)' "$STACK_DECISION" 2>/dev/null | head -1)
fi

if [ -z "$STACK_ID" ]; then
  echo "QUALITY RUNNER: No stack decision found. Skipping stack-specific checks."
  exit 0
fi

# Find Agent-X home from project state
AGENT_X_HOME=""
if [ -f "$STATE_FILE" ]; then
  AGENT_X_HOME=$(sed -n 's/.*"agent_x_home"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_FILE" | head -1)
fi

STACK_CONFIG="$AGENT_X_HOME/stacks/$STACK_ID/stack.json"
if [ ! -f "$STACK_CONFIG" ]; then
  echo "QUALITY RUNNER: Stack config not found at $STACK_CONFIG"
  exit 1
fi

echo "============================================"
echo "  STACK QUALITY CHECK: $STACK_ID"
echo "============================================"

ERRORS=""
WARNINGS=""

# Extract tool commands from stack.json (portable sed)
get_config() {
  sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$STACK_CONFIG" | head -1
}

LINTER=$(get_config "linter")
FORMATTER=$(get_config "formatter")
TYPE_CHECKER=$(get_config "type_checker")
TEST_RUNNER=$(get_config "test_runner")

# Run linter
if [ -n "$LINTER" ] && [ "$LINTER" != "none" ]; then
  echo "[1/4] Running linter: $LINTER..."
  LINT_CMD=""
  case "$LINTER" in
    eslint) LINT_CMD="npx eslint . --max-warnings 0" ;;
    ruff)   LINT_CMD="ruff check ." ;;
    *)      LINT_CMD="$LINTER" ;;
  esac
  if ! eval "$LINT_CMD" 2>/dev/null; then
    ERRORS="$ERRORS\nLinter ($LINTER) found issues."
  fi
else
  echo "[1/4] Linter: skipped (none configured)"
fi

# Run formatter check
if [ -n "$FORMATTER" ] && [ "$FORMATTER" != "none" ]; then
  echo "[2/4] Checking formatting: $FORMATTER..."
  FMT_CMD=""
  case "$FORMATTER" in
    prettier)  FMT_CMD="npx prettier --check ." ;;
    black)     FMT_CMD="black --check ." ;;
    *)         FMT_CMD="$FORMATTER --check" ;;
  esac
  if ! eval "$FMT_CMD" 2>/dev/null; then
    WARNINGS="$WARNINGS\nFormatter ($FORMATTER) found unformatted files."
  fi
else
  echo "[2/4] Formatter: skipped (none configured)"
fi

# Run type checker
if [ -n "$TYPE_CHECKER" ] && [ "$TYPE_CHECKER" != "none" ]; then
  echo "[3/4] Running type checker: $TYPE_CHECKER..."
  TC_CMD=""
  case "$TYPE_CHECKER" in
    typescript) TC_CMD="npx tsc --noEmit" ;;
    mypy)       TC_CMD="mypy ." ;;
    *)          TC_CMD="$TYPE_CHECKER" ;;
  esac
  if ! eval "$TC_CMD" 2>/dev/null; then
    ERRORS="$ERRORS\nType checker ($TYPE_CHECKER) found errors."
  fi
else
  echo "[3/4] Type checker: skipped (none configured)"
fi

# Run tests
if [ -n "$TEST_RUNNER" ] && [ "$TEST_RUNNER" != "none" ]; then
  echo "[4/4] Running tests: $TEST_RUNNER..."
  TEST_CMD=""
  case "$TEST_RUNNER" in
    jest)   TEST_CMD="npx jest" ;;
    pytest) TEST_CMD="pytest" ;;
    vitest) TEST_CMD="npx vitest run" ;;
    *)      TEST_CMD="$TEST_RUNNER" ;;
  esac
  if ! eval "$TEST_CMD" 2>/dev/null; then
    ERRORS="$ERRORS\nTests ($TEST_RUNNER) failed."
  fi
else
  echo "[4/4] Test runner: skipped (none configured)"
fi

# Report
echo ""
echo "============================================"
if [ -n "$ERRORS" ]; then
  echo "  STACK QUALITY: FAILED"
  echo "============================================"
  printf '%b\n' "$ERRORS"
  if [ -n "$WARNINGS" ]; then
    echo ""
    echo "Warnings:"
    printf '%b\n' "$WARNINGS"
  fi
  exit 1
else
  if [ -n "$WARNINGS" ]; then
    echo "  STACK QUALITY: PASSED WITH WARNINGS"
    echo "============================================"
    printf '%b\n' "$WARNINGS"
  else
    echo "  STACK QUALITY: PASSED"
    echo "============================================"
  fi
  exit 0
fi
