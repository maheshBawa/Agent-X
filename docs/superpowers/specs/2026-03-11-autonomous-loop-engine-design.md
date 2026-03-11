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

Execution rules:
- Independent branches may execute concurrently (via background agents)
- Blocked tasks wait for dependencies
- Failed tasks retry once with a modified approach
- After 3 failures, task status becomes "checkpointed" and loop pauses for human
- Task completion triggers dependency resolution — unblocked tasks start automatically

### Trigger Framework

| Trigger Type | Source | Activation Method |
|-------------|--------|-------------------|
| User Goal | Direct conversation | User states a multi-step objective |
| Test Failure | VERIFY stage | Failed test re-enters ASSESS |
| Gate Failure | Quality gate hooks | Gate block triggers self-heal |
| Self-Heal | VERIFY stage | Fixable issue detected, confidence HIGH |
| Cron Watch | Claude Code cron | Periodic: dependency audit, coverage check, security scan |
| External Event | CLI/hook trigger | CI failure, PR review request, new GitHub issue |

Cron triggers run at configurable intervals and produce status reports. If issues are found, they enter the loop as triggers.

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

### Integration With Existing Systems

| Existing System | Integration Point |
|----------------|-------------------|
| Quality Gates (1-4) | Gates become automatic checkpoints — failures trigger self-heal before escalating |
| 6-Phase Workflow | Phases structure the work; the loop handles task chaining within each phase |
| AGENTS.md Roles | Each role gains loop-awareness — knows when to chain vs checkpoint |
| Memory System | LEARN stage feeds memory continuously, not just at project end |
| Evolution Engine | Reflection triggers fire after loop completions, not just project completions |
| Tech Stack Engine | Stack configs inform confidence (familiar stack = higher base confidence) |
| Profile System | User risk tolerance from `profiles/default.json` adjusts checkpoint sensitivity |

### Safety Constraints (Immutable)

1. Checkpoints are mandatory — the loop cannot disable or skip them
2. Quality gates still block — autonomy does not bypass safety
3. No self-merging — PRs always require human approval
4. No deploy without explicit human approval — even in autonomous mode
5. Confidence scoring is honest — no score inflation to avoid checkpoints
6. Max loop depth of 3 retries per task — prevents infinite self-heal spirals
7. All autonomous actions are logged — full transparency, reviewable
8. Human interrupt honored immediately — "stop" kills the loop
9. Existing TDD requirement unchanged — tests before implementation
10. No secret commits — Gate 3 remains enforced in all modes

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
```

Modified files:

```
CLAUDE.md                      # Add autonomous mode directives and loop protocol reference
AGENTS.md                      # Add loop-awareness to each agent role
templates/project-claude.md    # Propagate autonomous directives to new projects
templates/project-agents.md    # Propagate loop-awareness to new projects
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

- Unit tests for each consciousness document (validate rules are followed in simulated scenarios)
- Integration test: give a multi-step goal, verify autonomous chaining with correct checkpoints
- Regression: all 79 existing tests pass
- Safety test: verify checkpoints fire correctly (architecture decision, low confidence, deploy)
- Self-heal test: introduce a failing test, verify loop retries and fixes
- Memory test: verify LEARN stage updates correct memory files
- Interrupt test: verify "stop" halts the loop mid-execution

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Infinite loop / runaway autonomy | Max 3 retries per task, max loop depth, logged actions |
| Wrong architectural decision made autonomously | Architecture checkpoint is mandatory — always pauses |
| Confidence score gaming | Calibration via user corrections, honest scoring is an immutable constraint |
| Memory pollution (bad patterns saved) | LEARN validates against existing memory, user corrections override |
| Loss of human control | Interrupt always honored, checkpoints cannot be disabled, no self-merge |

## Future Extensions (Not In Scope)

- MCP server integrations (GitHub, Slack, cloud APIs) — adds reach to the loop
- Multi-agent parallel orchestration — multiple loops coordinated
- Voice/notification interface — JARVIS-style spoken status updates
- Cross-project learning — memory shared between projects (with user consent)
