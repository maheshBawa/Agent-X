#!/usr/bin/env bash
# Test: Agent-X setup script
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

echo "Testing Agent-X Setup..."

# Test: Core files exist
assert "CLAUDE.md exists" "$([ -f "$AGENT_X_HOME/CLAUDE.md" ] && echo true || echo false)"
assert "AGENTS.md exists" "$([ -f "$AGENT_X_HOME/AGENTS.md" ] && echo true || echo false)"
assert "setup.sh exists" "$([ -f "$AGENT_X_HOME/setup.sh" ] && echo true || echo false)"
assert "setup.ps1 exists" "$([ -f "$AGENT_X_HOME/setup.ps1" ] && echo true || echo false)"
assert "agent-x CLI exists" "$([ -f "$AGENT_X_HOME/agent-x" ] && echo true || echo false)"

# Test: Settings exist
assert ".claude/settings.json exists" "$([ -f "$AGENT_X_HOME/.claude/settings.json" ] && echo true || echo false)"

# Test: Hook scripts exist
assert "pre-write.sh exists" "$([ -f "$AGENT_X_HOME/.claude/hooks/pre-write.sh" ] && echo true || echo false)"
assert "post-write.sh exists" "$([ -f "$AGENT_X_HOME/.claude/hooks/post-write.sh" ] && echo true || echo false)"
assert "pre-commit.sh exists" "$([ -f "$AGENT_X_HOME/.claude/hooks/pre-commit.sh" ] && echo true || echo false)"
assert "pre-deploy.sh exists" "$([ -f "$AGENT_X_HOME/.claude/hooks/pre-deploy.sh" ] && echo true || echo false)"

# Test: Core directories exist
assert "core/intake/ exists" "$([ -d "$AGENT_X_HOME/core/intake" ] && echo true || echo false)"
assert "core/planner/ exists" "$([ -d "$AGENT_X_HOME/core/planner" ] && echo true || echo false)"
assert "core/quality/ exists" "$([ -d "$AGENT_X_HOME/core/quality" ] && echo true || echo false)"
assert "core/deployer/ exists" "$([ -d "$AGENT_X_HOME/core/deployer" ] && echo true || echo false)"
assert "core/memory/ exists" "$([ -d "$AGENT_X_HOME/core/memory" ] && echo true || echo false)"
assert "core/evolution/ exists" "$([ -d "$AGENT_X_HOME/core/evolution" ] && echo true || echo false)"

# Test: Stacks exist
assert "stacks/registry.json exists" "$([ -f "$AGENT_X_HOME/stacks/registry.json" ] && echo true || echo false)"
assert "stacks/registry.json is valid JSON" "$(python3 -m json.tool "$AGENT_X_HOME/stacks/registry.json" > /dev/null 2>&1 && echo true || echo false)"

# Test: Profile exists
assert "profiles/default.json exists" "$([ -f "$AGENT_X_HOME/profiles/default.json" ] && echo true || echo false)"

# Test: Templates exist
assert "templates/project-claude.md exists" "$([ -f "$AGENT_X_HOME/templates/project-claude.md" ] && echo true || echo false)"
assert "templates/project-state.json exists" "$([ -f "$AGENT_X_HOME/templates/project-state.json" ] && echo true || echo false)"
assert "templates/project-agents.md exists" "$([ -f "$AGENT_X_HOME/templates/project-agents.md" ] && echo true || echo false)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
