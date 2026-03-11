#!/usr/bin/env bash
# Gate 1: PRE-WRITE — Validates code before it is written
# Runs as PreToolUse hook on Write/Edit tools
# Receives tool input via stdin as JSON
set -euo pipefail

TOOL_INPUT=$(cat)
# Resolve project root from the hook's own location (hooks live at <project>/.claude/hooks/)
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"
# Fallback to git if hook is piped (no $0 path)
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
ARCH_FILE="$PROJECT_ROOT/.agent-x/architecture.md"

# Skip if no .agent-x directory (not an Agent-X project)
if [ ! -d "$PROJECT_ROOT/.agent-x" ]; then
  exit 0
fi

# Extract file_path from JSON input (portable — no grep -P)
FILE_PATH=$(echo "$TOOL_INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

# Skip if we can't determine the file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip .agent-x directory files
case "$FILE_PATH" in
  .agent-x/*|*/.agent-x/*) exit 0 ;;
esac

# Skip non-code files (docs, configs, etc.)
case "$FILE_PATH" in
  *.md|*.json|*.yaml|*.yml|*.toml|*.txt|*.env*|*.gitignore|*.lock)
    exit 0
    ;;
esac

# Check 1: Architecture file must exist before writing code
if [ ! -f "$ARCH_FILE" ]; then
  echo "GATE 1 BLOCKED: No architecture document found at .agent-x/architecture.md"
  echo "You must complete Phase 3 (Architecture) before writing code."
  exit 1
fi

# Check 2: Verify test file exists or is being created
BASENAME=$(basename "$FILE_PATH")

# Skip if this IS a test file
case "$BASENAME" in
  test_*|*_test.*|*.test.*|*.spec.*)
    exit 0
    ;;
esac

# Look for corresponding test file
FOUND_TEST=false
for pattern in "test_${BASENAME}" "${BASENAME%.*}.test.${BASENAME##*.}" "${BASENAME%.*}.spec.${BASENAME##*.}"; do
  if find "$PROJECT_ROOT" -name "$pattern" -type f 2>/dev/null | head -1 | grep -q .; then
    FOUND_TEST=true
    break
  fi
done

# Check in tests/ directory too
if [ "$FOUND_TEST" = false ]; then
  TESTS_DIR="$PROJECT_ROOT/tests"
  if [ -d "$TESTS_DIR" ]; then
    if find "$TESTS_DIR" -name "*$(basename "${BASENAME%.*}")*" -type f 2>/dev/null | head -1 | grep -q .; then
      FOUND_TEST=true
    fi
  fi
fi

# Warn but don't block if no test found (test might be created next)
if [ "$FOUND_TEST" = false ]; then
  echo "GATE 1 WARNING: No test file found for $BASENAME. Ensure tests are created."
fi

exit 0
