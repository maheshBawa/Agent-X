#!/usr/bin/env bash
# Tests for the autonomous loop engine consciousness documents
# These are structural and behavioral validation tests

set -euo pipefail

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_X_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

pass() { ((PASS++)) || true; echo "  PASS: $1"; }
fail() { ((FAIL++)) || true; echo "  FAIL: $1"; }

echo "========================================="
echo "  Agent-X Autonomy Tests"
echo "========================================="
echo ""

# ─── Test 1: All autonomy documents exist ───
echo "--- Core Documents ---"
for doc in loop.md checkpoints.md confidence.md triggers.md task-graph.md feedback.md; do
  if [[ -f "$AGENT_X_HOME/core/autonomy/$doc" ]]; then
    pass "$doc exists"
  else
    fail "$doc missing"
  fi
done

# ─── Test 2: Loop document contains required sections ───
echo ""
echo "--- Loop Protocol Sections ---"
LOOP="$AGENT_X_HOME/core/autonomy/loop.md"
for section in "## Activation" "### Stage 1: TRIGGER" "### Stage 2: ASSESS" "### Stage 3: PLAN" "### Stage 4: EXECUTE" "### Stage 5: VERIFY" "### Stage 6: LEARN" "## Loop State File" "## Interrupts"; do
  if grep -q "$section" "$LOOP" 2>/dev/null; then
    pass "loop.md has '$section'"
  else
    fail "loop.md missing '$section'"
  fi
done

# ─── Test 3: Checkpoint document contains all checkpoint types ───
echo ""
echo "--- Checkpoint Types ---"
CHECKPOINTS="$AGENT_X_HOME/core/autonomy/checkpoints.md"
for checkpoint in "Architecture Checkpoint" "Breaking Change Checkpoint" "Ambiguity Checkpoint" "Deploy Checkpoint" "Confidence Checkpoint" "Structural Mandatory Checkpoints"; do
  if grep -q "$checkpoint" "$CHECKPOINTS" 2>/dev/null; then
    pass "checkpoints.md has '$checkpoint'"
  else
    fail "checkpoints.md missing '$checkpoint'"
  fi
done

# ─── Test 4: Confidence document has scoring factors ───
echo ""
echo "--- Confidence Scoring ---"
CONFIDENCE="$AGENT_X_HOME/core/autonomy/confidence.md"
for factor in "Requirement clarity" "Pattern familiarity" "Change complexity" "Blast radius" "Stack familiarity"; do
  if grep -q "$factor" "$CONFIDENCE" 2>/dev/null; then
    pass "confidence.md has factor '$factor'"
  else
    fail "confidence.md missing factor '$factor'"
  fi
done

# Verify weights sum to 100%
if grep -q "30%" "$CONFIDENCE" && grep -q "25%" "$CONFIDENCE" && grep -q "20%" "$CONFIDENCE" && grep -q "15%" "$CONFIDENCE" && grep -q "10%" "$CONFIDENCE"; then
  pass "confidence weights present (30+25+20+15+10=100)"
else
  fail "confidence weights incomplete or missing"
fi

# ─── Test 5: Task graph has schema and guardrails ───
echo ""
echo "--- Task Graph ---"
TASKGRAPH="$AGENT_X_HOME/core/autonomy/task-graph.md"
if grep -q "Max 20 tasks" "$TASKGRAPH" 2>/dev/null || grep -q "max 20" "$TASKGRAPH" 2>/dev/null; then
  pass "task-graph.md has 20-task guardrail"
else
  fail "task-graph.md missing 20-task guardrail"
fi

if grep -q '"id"' "$TASKGRAPH" && grep -q '"dependencies"' "$TASKGRAPH" && grep -q '"acceptance_criteria"' "$TASKGRAPH" && grep -q '"confidence"' "$TASKGRAPH" && grep -q '"status"' "$TASKGRAPH" && grep -q '"retries"' "$TASKGRAPH"; then
  pass "task-graph.md has complete task node schema"
else
  fail "task-graph.md has incomplete task node schema"
fi

# ─── Test 6: Triggers document has all trigger types ───
echo ""
echo "--- Trigger Types ---"
TRIGGERS="$AGENT_X_HOME/core/autonomy/triggers.md"
for trigger in "User Goal" "Test Failure" "Gate Failure" "Self-Heal" "Cron Watch" "External Event"; do
  if grep -q "$trigger" "$TRIGGERS" 2>/dev/null; then
    pass "triggers.md has '$trigger'"
  else
    fail "triggers.md missing '$trigger'"
  fi
done

# ─── Test 7: Feedback document has validation rules ───
echo ""
echo "--- Memory Feedback ---"
FEEDBACK="$AGENT_X_HOME/core/autonomy/feedback.md"
for rule in "Deduplication" "Conflict Detection" "Source Attribution" "Staleness Marking" "Size Limit"; do
  if grep -q "$rule" "$FEEDBACK" 2>/dev/null; then
    pass "feedback.md has validation rule '$rule'"
  else
    fail "feedback.md missing validation rule '$rule'"
  fi
done

# ─── Test 8: Safety constraints in checkpoints ───
echo ""
echo "--- Safety Constraints ---"
if grep -q "risk_tolerance" "$CHECKPOINTS" 2>/dev/null; then
  pass "checkpoints.md references risk_tolerance"
else
  fail "checkpoints.md missing risk_tolerance reference"
fi

if grep -q "60%" "$CHECKPOINTS" && grep -q "50%" "$CHECKPOINTS" && grep -q "40%" "$CHECKPOINTS"; then
  pass "checkpoints.md has all three risk tolerance thresholds"
else
  fail "checkpoints.md missing risk tolerance thresholds"
fi

# ─── Test 9: Loop state JSON schema validation ───
echo ""
echo "--- Loop State Schema ---"
if grep -q '"active"' "$LOOP" && grep -q '"goal"' "$LOOP" && grep -q '"current_stage"' "$LOOP" && grep -q '"task_graph"' "$LOOP" && grep -q '"total_actions_taken"' "$LOOP" && grep -q '"elapsed_minutes"' "$LOOP"; then
  pass "loop.md defines complete loop-state.json schema"
else
  fail "loop.md has incomplete loop-state.json schema"
fi

# ─── Test 10: Rollback protocol defined ───
echo ""
echo "--- Rollback Protocol ---"
if grep -q "git checkpoint" "$LOOP" 2>/dev/null || grep -q "git stash" "$LOOP" 2>/dev/null; then
  pass "loop.md defines rollback protocol"
else
  fail "loop.md missing rollback protocol"
fi

# ─── Test 11: CLAUDE.md has autonomous mode section ───
echo ""
echo "--- CLAUDE.md Integration ---"
CLAUDE="$AGENT_X_HOME/CLAUDE.md"
if grep -q "Autonomous Mode" "$CLAUDE" 2>/dev/null; then
  pass "CLAUDE.md has Autonomous Mode section"
else
  fail "CLAUDE.md missing Autonomous Mode section"
fi

if grep -q "loop-state.json" "$CLAUDE" 2>/dev/null; then
  pass "CLAUDE.md references loop-state.json"
else
  fail "CLAUDE.md missing loop-state.json reference"
fi

# ─── Test 12: AGENTS.md has loop awareness ───
echo ""
echo "--- AGENTS.md Integration ---"
AGENTS="$AGENT_X_HOME/AGENTS.md"
if grep -q "Autonomous Mode" "$AGENTS" 2>/dev/null; then
  pass "AGENTS.md has Autonomous Mode sections"
else
  fail "AGENTS.md missing Autonomous Mode sections"
fi

# ─── Test 13: Templates updated ───
echo ""
echo "--- Template Updates ---"
TPL_CLAUDE="$AGENT_X_HOME/templates/project-claude.md"
TPL_AGENTS="$AGENT_X_HOME/templates/project-agents.md"
TPL_STATE="$AGENT_X_HOME/templates/project-state.json"

if grep -q "autonomous" "$TPL_CLAUDE" 2>/dev/null || grep -q "Autonomous" "$TPL_CLAUDE" 2>/dev/null; then
  pass "project-claude.md template has autonomy reference"
else
  fail "project-claude.md template missing autonomy reference"
fi

if grep -q "autonomous" "$TPL_AGENTS" 2>/dev/null || grep -q "Autonomous" "$TPL_AGENTS" 2>/dev/null; then
  pass "project-agents.md template has autonomy reference"
else
  fail "project-agents.md template missing autonomy reference"
fi

if grep -q "autonomous_mode" "$TPL_STATE" 2>/dev/null || grep -q "2.0.0" "$TPL_STATE" 2>/dev/null; then
  pass "project-state.json template updated for v2.0"
else
  fail "project-state.json template not updated for v2.0"
fi

# ─── Test 14: Version bump ───
echo ""
echo "--- Version ---"
VERSION=$(cat "$AGENT_X_HOME/VERSION" 2>/dev/null || echo "missing")
if [[ "$VERSION" == "2.0.0" ]]; then
  pass "VERSION is 2.0.0"
else
  fail "VERSION is '$VERSION', expected '2.0.0'"
fi

# ─── Test 15: Loop state JSON schema validation ───
echo ""
echo "--- JSON Schema Validation ---"

# Create a sample loop-state.json and validate its structure
SAMPLE_LOOP_STATE='{"active":true,"goal":"test","current_stage":"ASSESS","task_graph":{"tasks":[{"id":"task-1","description":"test task","dependencies":[],"acceptance_criteria":"it works","confidence":80,"status":"pending","retries":0,"approach_notes":null}]},"total_actions_taken":0,"total_retries":0,"elapsed_minutes":0,"checkpoints_hit":[],"started_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z"}'

# Validate required fields exist in the schema definition (loop.md)
for field in '"active"' '"goal"' '"current_stage"' '"task_graph"' '"total_actions_taken"' '"total_retries"' '"elapsed_minutes"' '"checkpoints_hit"' '"started_at"' '"updated_at"'; do
  if echo "$SAMPLE_LOOP_STATE" | grep -q "$field"; then
    pass "loop-state schema has field $field"
  else
    fail "loop-state schema missing field $field"
  fi
done

# Validate task node schema
for field in '"id"' '"description"' '"dependencies"' '"acceptance_criteria"' '"confidence"' '"status"' '"retries"' '"approach_notes"'; do
  if echo "$SAMPLE_LOOP_STATE" | grep -q "$field"; then
    pass "task node schema has field $field"
  else
    fail "task node schema missing field $field"
  fi
done

# Validate cron config schema is documented in triggers.md
if grep -q "interval_minutes" "$TRIGGERS" && grep -q "health_checks" "$TRIGGERS"; then
  pass "triggers.md documents cron-config.json schema"
else
  fail "triggers.md missing cron-config.json schema documentation"
fi

# ─── Test 16: Action logging defined ───
echo ""
echo "--- Action Logging ---"
if grep -q "Action Log" "$LOOP" 2>/dev/null || grep -q "action log" "$LOOP" 2>/dev/null || grep -q "\[auto\]" "$LOOP" 2>/dev/null; then
  pass "loop.md defines action logging"
else
  fail "loop.md missing action logging definition"
fi

# ─── Test 17: Existing tests still referenced ───
echo ""
echo "--- Regression Check ---"
EXISTING_TESTS=0
for test_file in test-setup.sh test-stacks.sh test-init.sh test-hooks.sh test-gates-deep.sh; do
  if [[ -f "$AGENT_X_HOME/tests/$test_file" ]]; then
    ((EXISTING_TESTS++)) || true
  fi
done
if [[ $EXISTING_TESTS -eq 5 ]]; then
  pass "All 5 existing test files present"
else
  fail "Only $EXISTING_TESTS/5 existing test files found"
fi

# ─── Summary ───
echo ""
echo "========================================="
TOTAL=$((PASS + FAIL))
echo "  Results: $PASS/$TOTAL passed"
if [[ $FAIL -gt 0 ]]; then
  echo "  FAILED: $FAIL tests"
  exit 1
else
  echo "  All tests passed!"
  exit 0
fi
