#!/usr/bin/env bash
# Test: Deep quality gate testing — negative paths, edge cases, Gate 4
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

echo "Testing deep quality gates..."

# Setup: init a test project
cd "$TEST_DIR"
bash "$AGENT_X_HOME/agent-x" init > /dev/null 2>&1

# =============================================
# Gate 1: Pre-Write Tests
# =============================================
echo ""
echo "--- Gate 1: Pre-Write ---"

# Test: Gate 1 blocks when no architecture doc exists
rm -f .agent-x/architecture.md
RESULT=$(echo '{"file_path": "src/app.js"}' | bash .claude/hooks/pre-write.sh 2>&1 || true)
assert "Gate 1 blocks without architecture doc" "$(echo "$RESULT" | grep -q 'GATE 1 BLOCKED' && echo true || echo false)"

# Test: Gate 1 passes when architecture doc exists
echo "# Architecture" > .agent-x/architecture.md
RESULT=$(echo '{"file_path": "src/app.js"}' | bash .claude/hooks/pre-write.sh 2>&1 || true)
assert "Gate 1 passes with architecture doc" "$(echo "$RESULT" | grep -q 'BLOCKED' && echo false || echo true)"

# Test: Gate 1 skips .agent-x files
RESULT=$(echo '{"file_path": ".agent-x/state.json"}' | bash .claude/hooks/pre-write.sh 2>&1); EC=$?
assert "Gate 1 skips .agent-x files" "$([ $EC -eq 0 ] && echo true || echo false)"

# Test: Gate 1 skips markdown files
RESULT=$(echo '{"file_path": "README.md"}' | bash .claude/hooks/pre-write.sh 2>&1); EC=$?
assert "Gate 1 skips markdown files" "$([ $EC -eq 0 ] && echo true || echo false)"

# Test: Gate 1 warns about missing test file
RESULT=$(echo '{"file_path": "src/utils.js"}' | bash .claude/hooks/pre-write.sh 2>&1 || true)
assert "Gate 1 warns about missing test" "$(echo "$RESULT" | grep -q 'WARNING.*test' && echo true || echo false)"

# Test: Gate 1 does NOT warn for test files themselves
RESULT=$(echo '{"file_path": "tests/test_utils.js"}' | bash .claude/hooks/pre-write.sh 2>&1 || true)
assert "Gate 1 skips warning for test files" "$(echo "$RESULT" | grep -q 'WARNING' && echo false || echo true)"

# =============================================
# Gate 2: Post-Write Tests
# =============================================
echo ""
echo "--- Gate 2: Post-Write ---"

# Test: Gate 2 detects JSON-style secrets
echo '{"database": {"password": "supersecret123"}}' > test-json-secret.js
RESULT=$(echo '{"file_path": "test-json-secret.js"}' | bash .claude/hooks/post-write.sh 2>&1 || true)
assert "Gate 2 detects JSON-style secrets" "$(echo "$RESULT" | grep -q 'GATE 2 BLOCKED' && echo true || echo false)"

# Test: Gate 2 detects connection strings
echo 'const db = "postgresql://admin:password123@localhost/mydb"' > test-connstr.js
RESULT=$(echo '{"file_path": "test-connstr.js"}' | bash .claude/hooks/post-write.sh 2>&1 || true)
assert "Gate 2 detects connection strings" "$(echo "$RESULT" | grep -q 'GATE 2 BLOCKED' && echo true || echo false)"

# Test: Gate 2 warns about console.log
echo 'console.log("debug info")' > test-debug.js
RESULT=$(echo '{"file_path": "test-debug.js"}' | bash .claude/hooks/post-write.sh 2>&1 || true)
assert "Gate 2 warns about console.log" "$(echo "$RESULT" | grep -q 'WARNING.*Debug' && echo true || echo false)"

# Test: Gate 2 passes clean code with env vars
echo 'const dbUrl = process.env.DATABASE_URL' > test-env.js
RESULT=$(echo '{"file_path": "test-env.js"}' | bash .claude/hooks/post-write.sh 2>&1 || true)
assert "Gate 2 passes code using env vars" "$(echo "$RESULT" | grep -q 'BLOCKED' && echo false || echo true)"

# Test: Gate 2 skips JSON files
echo '{"password": "shouldnotblock"}' > config.json
RESULT=$(echo '{"file_path": "config.json"}' | bash .claude/hooks/post-write.sh 2>&1); EC=$?
assert "Gate 2 skips .json files" "$([ $EC -eq 0 ] && echo true || echo false)"

# =============================================
# Gate 3: Pre-Commit Tests
# =============================================
echo ""
echo "--- Gate 3: Pre-Commit ---"

# Test: Gate 3 fast-path exits for non-commit commands
RESULT=$(echo '{"command": "npm install express"}' | bash .claude/hooks/pre-commit.sh 2>&1); EC=$?
assert "Gate 3 fast-path: npm install" "$([ $EC -eq 0 ] && echo true || echo false)"

RESULT=$(echo '{"command": "ls -la"}' | bash .claude/hooks/pre-commit.sh 2>&1); EC=$?
assert "Gate 3 fast-path: ls -la" "$([ $EC -eq 0 ] && echo true || echo false)"

RESULT=$(echo '{"command": "mkdir src"}' | bash .claude/hooks/pre-commit.sh 2>&1); EC=$?
assert "Gate 3 fast-path: mkdir" "$([ $EC -eq 0 ] && echo true || echo false)"

# Test: Gate 3 detects .env files in staged changes
git add .agent-x/ .claude/ CLAUDE.md AGENTS.md .gitignore > /dev/null 2>&1
git commit -m "init" > /dev/null 2>&1 || true
echo "SECRET=abc" > .env
git add -f .env 2>/dev/null
RESULT=$(echo '{"command": "git commit -m test"}' | bash .claude/hooks/pre-commit.sh 2>&1 || true)
assert "Gate 3 detects .env in staged files" "$(echo "$RESULT" | grep -q 'ENV FILE' && echo true || echo false)"
git rm --cached .env > /dev/null 2>&1 || true
rm -f .env

# =============================================
# Gate 4: Pre-Deploy Tests
# =============================================
echo ""
echo "--- Gate 4: Pre-Deploy ---"

# Test: Gate 4 script exists and is executable
assert "pre-deploy.sh exists" "$([ -f .claude/hooks/pre-deploy.sh ] && echo true || echo false)"

# Test: Gate 4 runs without crashing on empty project
RESULT=$(bash .claude/hooks/pre-deploy.sh 2>&1 || true)
assert "Gate 4 runs without crash" "$(echo "$RESULT" | grep -q 'GATE 4' && echo true || echo false)"

# Test: Gate 4 detects TODO in files
echo '// TODO: fix this later' > todo-file.js
git add todo-file.js > /dev/null 2>&1
RESULT=$(bash .claude/hooks/pre-deploy.sh 2>&1 || true)
assert "Gate 4 detects TODO" "$(echo "$RESULT" | grep -q 'TODO' && echo true || echo false)"
rm -f todo-file.js

# =============================================
# CLI Tests
# =============================================
echo ""
echo "--- CLI Tests ---"

# Test: agent-x reset command
bash "$AGENT_X_HOME/agent-x" reset BUILD > /dev/null 2>&1
RESULT=$(cat .agent-x/project-state.json)
assert "Reset sets phase to BUILD" "$(echo "$RESULT" | grep -q '"BUILD"' && echo true || echo false)"

# Test: agent-x reset with invalid phase
RESULT=$(bash "$AGENT_X_HOME/agent-x" reset INVALID 2>&1 || true)
assert "Reset rejects invalid phase" "$(echo "$RESULT" | grep -q 'Invalid phase' && echo true || echo false)"

# Test: agent-x init is idempotent (second run doesn't crash)
RESULT=$(bash "$AGENT_X_HOME/agent-x" init 2>&1 || true)
assert "Init is idempotent (second run)" "$(echo "$RESULT" | grep -q 'initialized\|backup' && echo true || echo false)"

# Test: agent-x version reads from VERSION file
RESULT=$(bash "$AGENT_X_HOME/agent-x" version 2>&1)
assert "Version command works" "$(echo "$RESULT" | grep -q 'Agent-X v' && echo true || echo false)"

# =============================================
# Stack Quality Runner Tests
# =============================================
echo ""
echo "--- Stack Quality Runner ---"

# Test: run-quality.sh handles missing stack decision
RESULT=$(bash .claude/hooks/run-quality.sh 2>&1 || true)
assert "Quality runner handles missing stack decision" "$(echo "$RESULT" | grep -q 'No stack decision\|skipped' && echo true || echo false)"

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
