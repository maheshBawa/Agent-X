#!/usr/bin/env bash
# Test: Quality gate hook scripts
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

echo "Testing quality gate hooks..."

# Setup: init a test project
cd "$TEST_DIR"
bash "$AGENT_X_HOME/agent-x" init > /dev/null 2>&1

# Create a fake architecture file so Gate 1 doesn't block
mkdir -p .agent-x
echo "# Test Architecture" > .agent-x/architecture.md

# Test Gate 2: Should detect hardcoded secrets
echo 'const password = "supersecretpassword123"' > test-secret.js
RESULT=$(echo '{"file_path": "test-secret.js"}' | bash .claude/hooks/post-write.sh 2>&1 || true)
assert "Gate 2 detects hardcoded secrets" "$(echo "$RESULT" | grep -q 'GATE 2 BLOCKED' && echo true || echo false)"

# Test Gate 2: Should pass clean code
echo 'const greeting = "hello world"' > test-clean.js
RESULT=$(echo '{"file_path": "test-clean.js"}' | bash .claude/hooks/post-write.sh 2>&1 || true)
assert "Gate 2 passes clean code" "$(echo "$RESULT" | grep -q 'BLOCKED' && echo false || echo true)"

# Test Gate 3: Should skip non-commit commands
echo '{"command": "ls -la"}' | bash .claude/hooks/pre-commit.sh 2>&1; EC=$?
assert "Gate 3 skips non-commit commands" "$([ $EC -eq 0 ] && echo true || echo false)"

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
