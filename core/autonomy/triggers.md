# Trigger Framework

Triggers are events that activate the autonomous loop. Each trigger type has a source, detection method, and entry point into the loop.

## Trigger Types

### 1. User Goal
**Source:** Direct conversation
**Detection:** User states a multi-step objective (e.g., "Build the auth system", "Fix all failing tests", "Add pagination to all API endpoints")
**Entry point:** ASSESS stage with the goal as context
**Example:** User says "Add user authentication with JWT" → loop activates with that goal

### 2. Test Failure (Internal)
**Source:** VERIFY stage of an active loop
**Detection:** Test suite fails during task verification
**Entry point:** Re-enter ASSESS with failure context
**Note:** This is an internal trigger — it keeps the loop running, not a new loop activation

### 3. Gate Failure (Internal)
**Source:** Quality gate hooks (pre-write, post-write, pre-commit)
**Detection:** A quality gate blocks an action during the loop
**Entry point:** Self-heal — diagnose the gate failure, fix, retry
**Note:** Gate failures during autonomous mode should be fixed automatically if confidence is HIGH. If LOW, checkpoint.

### 4. Self-Heal (Internal)
**Source:** VERIFY stage detects a fixable issue
**Detection:** Issue has a clear fix (e.g., missing import, type error, formatting issue) and confidence is HIGH
**Entry point:** Fix applied directly, loop continues
**Note:** Self-heal is limited to 3 retries per task. Not a new loop.

### 5. Cron Watch
**Source:** Claude Code cron capability
**Detection:** Scheduled interval fires
**Entry point:** ASSESS stage with the health check as context
**Configuration:** `.agent-x/cron-config.json`

```json
{
  "health_checks": [
    {
      "name": "dependency-audit",
      "interval_minutes": 1440,
      "command": "Run npm audit or pip-audit depending on stack",
      "description": "Check for known vulnerabilities in dependencies"
    },
    {
      "name": "coverage-check",
      "interval_minutes": 60,
      "command": "Run test suite with coverage flag",
      "description": "Verify test coverage hasn't dropped below threshold"
    },
    {
      "name": "security-scan",
      "interval_minutes": 1440,
      "command": "Run Gate 4 SAST patterns against codebase",
      "description": "Proactive security scan"
    }
  ]
}
```

**Cron output:** Written to `.agent-x/cron-reports/YYYY-MM-DD-<check-name>.md`
**If issues found:** Enter loop with the cron report as trigger context

### 6. External Event
**Source:** CLI hook or manual trigger
**Detection:** User runs a command or a CI/CD webhook fires
**Entry point:** ASSESS stage with event payload as context
**Examples:**
- CI pipeline fails → "CI failed on commit abc123: test_auth.py::test_login FAILED"
- PR review comment → "Reviewer requested: add input validation to signup endpoint"
- GitHub issue assigned → "Issue #42: Users can't reset password"

## Trigger Priority

If multiple triggers fire simultaneously:
1. Human interrupt (always highest priority)
2. Active loop continuation (finish current loop before starting new one)
3. External events (CI failures, PR reviews)
4. Cron checks (lowest priority — can wait)

## Trigger Logging

Every trigger activation is logged in `loop-state.json`:
- `goal` field contains the trigger description
- `started_at` records when the trigger fired
- `checkpoints_hit` tracks what happened during the resulting loop
