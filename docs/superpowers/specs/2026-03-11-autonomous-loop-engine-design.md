# Agent-X v2.0 — Autonomous Loop Engine Design Spec

**Date:** 2026-03-11
**Version:** 2.0.0
**Status:** Draft
**Author:** JARVIS (Agent-X self-evolution)

## Overview

Agent-X currently operates reactively — executing one step at a time, waiting for human prompting between each action. This upgrade transforms Agent-X into an autonomous agent that chains tasks, self-corrects, and only pauses at meaningful inflection points.

The upgrade is native — no external daemons, no middleware. New consciousness documents plug into the existing Agent-X architecture (quality gates, memory, phases, evolution engine).

## Problem Statement

Agent-X v1.2.1 has a solid foundation: 4 quality gates, 5 tech stacks, TDD enforcement, 6-phase workflow, self-evolution engine, and persistent memory. But it requires human prompting between every step. This makes it:

1. **Slow** — human latency between each action bottlenecks throughput
2. **Dependent** — cannot self-correct without being told to
3. **Passive** — no proactive detection of issues or opportunities
4. **Stateless between steps** — loses momentum and context at each pause

## Design Goals

1. Autonomous task chaining within sessions — execute multi-step goals without per-step prompting
2. Checkpoint-based safety — pause only at inflection points (architecture decisions, breaking changes, ambiguity, deploys, low confidence)
3. Self-healing — automatically fix test failures and gate violations before escalating
4. Confidence-aware — score each action, escalate to human when uncertain
5. Learning integration — feed outcomes back into memory after every loop
6. External trigger readiness — architecture supports cron, webhooks, and CI events activating the loop
7. Zero regression — existing quality gates, TDD, and safety constraints remain enforced

## Non-Goals

- Building a standalone daemon or middleware process
- Building MCP servers (future extension, not this version)
- Replacing the 6-phase workflow (autonomy operates within phases)
- Removing human oversight (checkpoints are mandatory)

## Architecture

### Core Loop Protocol

```
TRIGGER → ASSESS → PLAN → EXECUTE → VERIFY → LEARN → (loop or stop)
```

Each stage:

| Stage | Purpose | Output |
|-------|---------|--------|
| TRIGGER | Something activates the loop | Goal or event context |
| ASSESS | Evaluate situation, identify what's needed, score confidence | Situation report + confidence score |
| PLAN | Break goal into dependency-aware task graph | Task graph (DAG) |
| EXECUTE | Work through tasks, chaining automatically | Code, tests, artifacts |
| VERIFY | Validate each task and the full chain | Pass/fail + regression check |
| LEARN | Log outcomes to memory | Updated memory files |

The loop is re-entrant: VERIFY failures re-enter ASSESS with failure context. Max 3 retries per task before checkpointing to human.

#### Loop State Persistence

Loop state is persisted to `.agent-x/loop-state.json` so that sessions can resume mid-loop. The file is updated after every stage transition.

```json
{
  "active": true,
  "goal": "Build the auth system",
  "current_stage": "EXECUTE",
  "task_graph": {
    "tasks": [
      {
        "id": "task-1",
        "description": "Create user database schema",
        "dependencies": [],
        "acceptance_criteria": "Migration runs, table exists with correct columns",
        "confidence": 92,
        "status": "completed",
        "retries": 0,
        "approach_notes": null
      },
      {
        "id": "task-2",
        "description": "Implement auth service",
        "dependencies": ["task-1"],
        "acceptance_criteria": "Login/signup/logout work, tokens issued correctly",
        "confidence": 85,
        "status": "in_progress",
        "retries": 0,
        "approach_notes": null
      }
    ]
  },
  "total_actions_taken": 7,
  "total_retries": 0,
  "elapsed_minutes": 12,
  "checkpoints_hit": ["architecture:api-shape"],
  "started_at": "2026-03-11T10:00:00Z",
  "updated_at": "2026-03-11T10:12:00Z"
}
```

On session start, if `loop-state.json` exists with `"active": true`, the agent resumes from `current_stage` with the full task graph intact.

#### Rollback Protocol

Before each EXECUTE action, the agent creates a git checkpoint (lightweight commit or stash). If VERIFY fails:

1. Revert to the pre-action checkpoint (`git stash` or `git checkout` the changed files)
2. Re-enter ASSESS with failure context and the reverted codebase
3. Retry with a modified approach (different strategy, not the same code again)

This ensures retries start from a clean state, not a broken one.

### Checkpoint System

Checkpoints are inflection points where the loop pauses for human input.

| Checkpoint Type | Trigger Condition | Rationale |
|----------------|-------------------|-----------|
| Architecture | Structural decisions (new tables, services, API shape) | Wrong call cascades everywhere |
| Breaking | Changes that break existing interfaces | Hard to reverse |
| Ambiguity | Requirements interpretable 2+ ways, no confident default | Human intent > agent guess |
| Deploy | Anything touching production or external services | Always requires approval |
| Confidence | Confidence score drops below 50% | Self-awareness > speed |

Non-checkpoint actions (proceed automatically):
- Writing implementation code for well-defined tasks
- Writing and running tests
- Fixing test failures (up to 3 retries)
- Running quality gates
- Refactoring within existing interfaces
- Updating memory files

### Confidence Scoring

Before each action, the agent scores confidence on a 3-tier scale:

| Tier | Range | Behavior |
|------|-------|----------|
| HIGH | 80-100% | Proceed. Clear requirements, known patterns, strong memory precedent |
| MEDIUM | 50-79% | Proceed with log entry. Some ambiguity, reasonable default exists |
| LOW | 0-49% | Checkpoint. Multiple valid paths, unclear requirements, unfamiliar territory |

Confidence factors:
- **Requirement clarity** — is the acceptance criteria unambiguous?
- **Pattern familiarity** — does memory contain relevant precedent?
- **Change complexity** — how many files/systems does this touch?
- **Blast radius** — what breaks if this is wrong?
- **Stack familiarity** — is this a well-known stack with strong templates?

Calibration: When a human corrects an action the agent was confident about, the confidence model adjusts. Corrections are logged to `core/memory/feedback.md` with the original confidence score, enabling pattern-level recalibration.

### Task Graph Engine

Goals are decomposed into a directed acyclic graph (DAG), not a flat list.

Properties of each task node:
- **id** — unique identifier
- **description** — what needs to be done
- **dependencies** — task IDs that must complete first
- **acceptance_criteria** — how to verify completion
- **confidence** — pre-execution confidence score
- **status** — pending | in_progress | completed | failed | checkpointed
- **retries** — count of retry attempts (max 3)

The task graph is serialized as JSON in `.agent-x/loop-state.json` (see Loop State Persistence above). Each task node follows the schema shown in that example.

Execution rules:
- In v2.0, branches execute sequentially (depth-first through the DAG). Concurrent execution via parallel agents is a future optimization (see Future Extensions)
- Blocked tasks wait for dependencies
- Failed tasks retry up to 3 times, each retry using a modified approach (different strategy, not the same code). The agent must document what changed in `approach_notes`
- After 3 failures, task status becomes "checkpointed" and loop pauses for human
- Task completion triggers dependency resolution — unblocked tasks start automatically
- **Max 20 tasks per autonomous run.** If goal decomposition produces more than 20 tasks, the agent checkpoints to the human with the proposed graph for approval before proceeding

### Trigger Framework

| Trigger Type | Source | Activation Method |
|-------------|--------|-------------------|
| User Goal | Direct conversation | User states a multi-step objective |
| Test Failure | VERIFY stage | Failed test re-enters ASSESS |
| Gate Failure | Quality gate hooks | Gate block triggers self-heal |
| Self-Heal | VERIFY stage | Fixable issue detected, confidence HIGH |
| Cron Watch | Claude Code cron | Periodic: dependency audit, coverage check, security scan |
| External Event | CLI/hook trigger | CI failure, PR review request, new GitHub issue |

Cron triggers are configured in `.agent-x/cron-config.json`:

```json
{
  "health_checks": [
    {
      "name": "dependency-audit",
      "interval_minutes": 1440,
      "command": "npm audit / pip-audit",
      "description": "Check for known vulnerabilities in dependencies"
    },
    {
      "name": "coverage-check",
      "interval_minutes": 60,
      "command": "run test suite with coverage",
      "description": "Verify test coverage hasn't dropped below threshold"
    },
    {
      "name": "security-scan",
      "interval_minutes": 1440,
      "command": "run Gate 4 SAST checks",
      "description": "Proactive security scan for OWASP patterns"
    }
  ]
}
```

Default intervals: security/dependency scans daily (1440 min), coverage checks hourly (60 min). Users can override in the config file. Cron output is a status report written to `.agent-x/cron-reports/YYYY-MM-DD-<check-name>.md`. If issues are found, they enter the loop as triggers.

### Memory Integration (Feedback Loop)

The LEARN stage executes after every loop completion (not just after projects):

| Outcome | Memory Target | What's Logged |
|---------|--------------|---------------|
| Successful pattern | `core/memory/patterns.md` | Pattern description, context, confidence |
| Architecture decision | `core/memory/decisions.md` | Decision, reasoning, outcome |
| User correction | `core/memory/feedback.md` | Original action, correction, confidence delta |
| Stack insight | `core/memory/stack-history.md` | Stack behavior, gotchas, performance |
| Preference inferred | `core/memory/preferences.md` | Style, tool, or workflow preference |

Memory is read during ASSESS to inform confidence scoring. Over time, the agent's decisions improve because confidence is calibrated by real outcomes.

#### Memory Validation Rules

Before writing to memory, the LEARN stage validates:

1. **Deduplication** — check if a similar pattern/decision already exists. If so, update the existing entry rather than creating a duplicate
2. **Conflict detection** — if a new insight contradicts an existing memory entry, flag both and checkpoint to human for resolution
3. **Source attribution** — every memory entry includes the loop ID, date, and confidence score that produced it
4. **Staleness marking** — if a user correction invalidates a memory entry, mark it as `[SUPERSEDED by correction on YYYY-MM-DD]` rather than deleting (preserves audit trail)
5. **Max entry size** — individual memory entries should be concise (under 200 words). Detailed context belongs in the spec/architecture docs, not memory

### Integration With Existing Systems

| Existing System | Integration Point |
|----------------|-------------------|
| Quality Gates (1-4) | Gates become automatic checkpoints — failures trigger self-heal before escalating |
| 6-Phase Workflow | Phases structure the work; the loop handles task chaining within each phase |
| AGENTS.md Roles | Each role gains loop-awareness — knows when to chain vs checkpoint |
| Memory System | LEARN stage feeds memory continuously, not just at project end |
| Evolution Engine | Reflection triggers fire after loop completions, not just project completions |
| Tech Stack Engine | Stack configs inform confidence (familiar stack = higher base confidence) |
| Profile System | User risk tolerance from `profiles/default.json` adjusts checkpoint sensitivity (see mapping below) |

#### Risk Tolerance → Checkpoint Sensitivity Mapping

The `risk_tolerance` field in `profiles/default.json` adjusts how aggressively the loop checkpoints:

| Risk Tolerance | Confidence Checkpoint Threshold | Additional Behavior |
|---------------|-------------------------------|---------------------|
| `low` | 60% (more cautious) | Also checkpoints on any file deletion, CI config changes, and multi-service changes |
| `medium` | 50% (default) | Standard checkpoint rules as defined above |
| `high` | 40% (more autonomous) | Only mandatory checkpoints (architecture, deploy, breaking) — confidence checkpoints relaxed |

### Safety Constraints (Immutable)

1. Checkpoints are mandatory — the loop cannot disable or skip them
2. Quality gates still block — autonomy does not bypass safety
3. No self-merging — PRs always require human approval
4. No deploy without explicit human approval — even in autonomous mode
5. Confidence scoring is honest — no score inflation to avoid checkpoints
6. Structural mandatory checkpoints — regardless of confidence score, these actions ALWAYS checkpoint: file deletion, CI/CD config changes, security-related code (auth, crypto, permissions), and database migrations
7. Max loop depth of 3 retries per task — prevents infinite self-heal spirals
8. Max 20 tasks per autonomous run — prevents unbounded goal decomposition
9. Max 60 minutes per autonomous run — if elapsed time exceeds this, checkpoint with progress report
10. All autonomous actions are logged — full transparency, reviewable
11. Human interrupt honored immediately — "stop" kills the loop
12. Existing TDD requirement unchanged — tests before implementation
13. No secret commits — Gate 3 remains enforced in all modes

## File Structure

New files:

```
core/autonomy/
├── loop.md              # Loop protocol — the heartbeat
├── checkpoints.md       # Checkpoint types and trigger conditions
├── confidence.md        # Confidence scoring system and calibration
├── triggers.md          # Trigger types and activation methods
├── task-graph.md        # Task DAG structure and execution rules
└── feedback.md          # LEARN stage — memory integration protocol

# Per-project runtime files (created by the loop, not shipped):
.agent-x/loop-state.json          # Persisted loop state for session resume
.agent-x/cron-config.json         # Cron trigger configuration
.agent-x/cron-reports/            # Cron health check output
```

Modified files:

```
CLAUDE.md                      # Add autonomous mode directives and loop protocol reference
AGENTS.md                      # Add loop-awareness to each agent role
templates/project-claude.md    # Propagate autonomous directives to new projects
templates/project-agents.md    # Propagate loop-awareness to new projects
templates/project-state.json   # Add loop-state fields
core/evolution/changelog.md    # Log v2.0 changes
VERSION                        # Bump to 2.0.0
```

## Success Criteria

1. Given a multi-step goal, Agent-X chains tasks without per-step human prompting
2. Agent-X pauses at defined checkpoint types and presents clear decision context
3. Test failures within the loop are self-healed (up to 3 retries) before escalating
4. Confidence scores are logged for every autonomous action
5. Memory files are updated after every loop completion
6. All existing tests (79) continue to pass
7. Quality gates remain enforced — no regressions in security or code quality
8. A cron trigger can activate a health check loop without an active conversation
9. User can interrupt the loop at any time with immediate effect

## Testing Strategy

Consciousness documents (Markdown) cannot be unit-tested traditionally. Tests are **behavioral** — give the agent a scenario, verify it follows the rules. Test scripts simulate scenarios via controlled inputs and check outputs/state.

- **Behavioral tests for consciousness documents:** Create test scenarios (e.g., "given a 5-task goal with one ambiguous requirement, verify the agent checkpoints at the ambiguous task"). Validate by checking loop-state.json and action logs after execution
- **State persistence tests:** Start a loop, kill the session mid-task, resume — verify loop-state.json restores correctly and the agent continues from the right point
- **Checkpoint trigger tests:** Simulate each checkpoint type (architecture decision, low confidence, deploy, breaking change, structural mandatory) and verify the loop pauses with appropriate context
- **Self-heal tests:** Introduce a failing test, verify the loop retries with a modified approach and reverts before each retry
- **Resource guardrail tests:** Create a goal that decomposes into 25+ tasks, verify it checkpoints at 20. Run a loop for 60+ simulated minutes, verify it checkpoints with progress report
- **Memory integration tests:** Run a loop to completion, verify LEARN stage wrote to correct memory files with proper validation (no duplicates, conflict detection working)
- **Rollback tests:** Verify git checkpoint creation before EXECUTE, and clean revert on failure
- **Regression:** All 79 existing tests continue to pass
- **Interrupt test:** Verify "stop" halts the loop mid-execution and persists state

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Infinite loop / runaway autonomy | Max 3 retries per task, max 20 tasks per run, max 60 min per run, logged actions |
| Wrong architectural decision made autonomously | Architecture checkpoint is mandatory — always pauses |
| Confidence score gaming | Calibration via user corrections + structural mandatory checkpoints that bypass confidence entirely |
| Memory pollution (bad patterns saved) | LEARN validates: deduplication, conflict detection, source attribution, staleness marking |
| Loss of human control | Interrupt always honored, checkpoints cannot be disabled, no self-merge |
| Broken state from failed retries | Rollback protocol: git checkpoint before each action, revert before retry |
| Unbounded resource consumption | 60-minute time cap + 20-task cap + logged elapsed time in loop-state.json |
| Session crash mid-loop | loop-state.json persisted after every stage transition, resume on session start |

## Future Extensions (Not In Scope)

- MCP server integrations (GitHub, Slack, cloud APIs) — adds reach to the loop
- Multi-agent parallel orchestration — concurrent DAG branch execution via coordinated background agents
- Voice/notification interface — JARVIS-style spoken status updates
- Cross-project learning — memory shared between projects (with user consent)
- Token budget tracking — monitor API token consumption per autonomous run
