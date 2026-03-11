#!/usr/bin/env bash
# Test: agent-x init command
set -euo pipefail

AGENT_X_HOME="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR=$(mktemp -d)
PASS=0
FAIL=0

assert() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "true" ]; then
    echo "  ✓ $desc"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "Testing agent-x init..."

# Run init in temp directory
cd "$TEST_DIR"
bash "$AGENT_X_HOME/agent-x" init > /dev/null 2>&1

# Test: Files created
assert ".agent-x/ directory created" "$([ -d "$TEST_DIR/.agent-x" ] && echo true || echo false)"
assert "project-state.json created" "$([ -f "$TEST_DIR/.agent-x/project-state.json" ] && echo true || echo false)"
assert "CLAUDE.md created" "$([ -f "$TEST_DIR/CLAUDE.md" ] && echo true || echo false)"
assert "AGENTS.md created" "$([ -f "$TEST_DIR/AGENTS.md" ] && echo true || echo false)"
assert ".claude/hooks/ created" "$([ -d "$TEST_DIR/.claude/hooks" ] && echo true || echo false)"
assert ".claude/settings.json created" "$([ -f "$TEST_DIR/.claude/settings.json" ] && echo true || echo false)"
assert ".gitignore created" "$([ -f "$TEST_DIR/.gitignore" ] && echo true || echo false)"
assert "git repo initialized" "$([ -d "$TEST_DIR/.git" ] && echo true || echo false)"

# Test: State file has correct values
assert "State has project name" "$(grep -q '"project_name"' "$TEST_DIR/.agent-x/project-state.json" && echo true || echo false)"
assert "State starts at INTAKE phase" "$(grep -q '"INTAKE"' "$TEST_DIR/.agent-x/project-state.json" && echo true || echo false)"

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
