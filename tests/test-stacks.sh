#!/usr/bin/env bash
# Test: Stack registry and configs
set -euo pipefail

AGENT_X_HOME="$(cd "$(dirname "$0")/.." && pwd)"
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

echo "Testing stack registry..."

# Test: Registry is valid JSON
assert "registry.json is valid JSON" "$(python3 -m json.tool "$AGENT_X_HOME/stacks/registry.json" > /dev/null 2>&1 && echo true || echo false)"

# Test: All stacks in registry have directories
for stack in nextjs-postgres react-native-expo python-fastapi node-express-mongo static-site; do
  assert "Stack dir exists: $stack" "$([ -d "$AGENT_X_HOME/stacks/$stack" ] && echo true || echo false)"
  assert "stack.json exists: $stack" "$([ -f "$AGENT_X_HOME/stacks/$stack/stack.json" ] && echo true || echo false)"
  assert "template.md exists: $stack" "$([ -f "$AGENT_X_HOME/stacks/$stack/template.md" ] && echo true || echo false)"
  assert "stack.json valid JSON: $stack" "$(python3 -m json.tool "$AGENT_X_HOME/stacks/$stack/stack.json" > /dev/null 2>&1 && echo true || echo false)"
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
