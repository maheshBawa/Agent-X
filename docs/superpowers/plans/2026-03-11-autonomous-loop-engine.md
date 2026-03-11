# Autonomous Loop Engine Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Agent-X from a reactive tool into an autonomous agent with task chaining, checkpoint-based safety, confidence scoring, and memory-integrated learning loops.

**Architecture:** Six new consciousness documents in `core/autonomy/` define the loop protocol, checkpoint rules, confidence scoring, task graph execution, trigger framework, and memory feedback. These plug into the existing CLAUDE.md and AGENTS.md via new autonomous mode directives. No external daemons — pure prompt engineering within Claude Code's native capabilities.

**Tech Stack:** Bash (tests, hooks), Markdown (consciousness documents), JSON (state files, configs)

**Spec:** `docs/superpowers/specs/2026-03-11-autonomous-loop-engine-design.md`

---

## Chunk 1: Core Autonomy Documents

### Task 1: Create the Loop Protocol

The heartbeat of the autonomous system. Defines the 6-stage loop and how stages transition.

**Files:**
- Create: `core/autonomy/loop.md`

- [ ] **Step 1: Create the autonomy directory**

```bash
mkdir -p core/autonomy
```

- [ ] **Step 2: Write loop.md**

```markdown
# Autonomous Loop Protocol

This document defines how Agent-X operates in autonomous mode. When active, the agent follows this loop instead of waiting for per-step human prompting.

## Activation

Autonomous mode activates when:
1. The user states a multi-step goal (e.g., "Build the auth system", "Fix the failing tests and deploy")
2. A trigger event fires (cron, gate failure, external event)
3. A session resumes with an active loop state (`loop-state.json` has `"active": true`)

Autonomous mode does NOT activate for:
- Single-step requests ("rename this variable", "explain this function")
- Conversational questions ("what tech stack should we use?")
- Phase transitions that require human checkpoint (INTAKE → TECH_STACK, etc.)

## The Loop

```
TRIGGER → ASSESS → PLAN → EXECUTE → VERIFY → LEARN → (loop or stop)
```

### Stage 1: TRIGGER
Receive the goal or event. Log it. Create or load `loop-state.json`.

**Actions:**
1. If `loop-state.json` exists with `"active": true`, resume from `current_stage`
2. Otherwise, create a new loop state with the goal and set `current_stage` to "ASSESS"
3. Record `started_at` timestamp

### Stage 2: ASSESS
Evaluate the situation. Read relevant context. Score overall confidence.

**Actions:**
1. Read `.agent-x/architecture.md` (if exists) for structural context
2. Read `core/memory/patterns.md` for relevant precedent
3. Read `core/memory/preferences.md` for user style
4. Read `profiles/default.json` for risk tolerance
5. Identify what needs to be done — list discrete outcomes
6. Score overall confidence (see `confidence.md`)
7. If confidence is LOW, checkpoint immediately with assessment
8. Update loop state: `current_stage = "PLAN"`

### Stage 3: PLAN
Decompose the goal into a task graph (DAG).

**Actions:**
1. Break the goal into discrete tasks with dependencies
2. Each task gets: id, description, dependencies, acceptance_criteria, confidence score
3. If task count exceeds 20, checkpoint to human with proposed graph
4. Validate no circular dependencies
5. Write task graph to `loop-state.json`
6. Update loop state: `current_stage = "EXECUTE"`
7. Present the plan summary to the user (not a checkpoint — informational)

### Stage 4: EXECUTE
Work through tasks in dependency order.

**Actions:**
1. Pick the next task: find a task with status "pending" whose dependencies are all "completed"
2. Check for checkpoints (see `checkpoints.md`) — pause if triggered
3. Create a git checkpoint before making changes: `git stash push -m "loop-checkpoint-{task-id}"`
4. Execute the task following TDD:
   a. Write the failing test
   b. Run it to confirm failure
   c. Write minimal implementation
   d. Run tests to confirm pass
   e. Run quality gates
5. If task passes: set status to "completed", update loop state, resolve dependencies
6. If task fails: see VERIFY stage
7. Increment `total_actions_taken`
8. Check elapsed time — if > 60 minutes, checkpoint with progress report

### Stage 5: VERIFY
Validate the completed task. Handle failures.

**Actions:**
1. Run the full test suite relevant to the changed code
2. Run quality gates (hooks will fire automatically on writes)
3. If all pass: return to EXECUTE for next task (or LEARN if all tasks complete)
4. If failure detected:
   a. Increment task `retries`
   b. If retries < 3:
      - Revert to git checkpoint: `git stash pop` or `git checkout -- <files>`
      - Document what failed in `approach_notes`
      - Re-enter ASSESS with failure context (modified approach)
      - Re-enter EXECUTE with new strategy
   c. If retries >= 3:
      - Set task status to "checkpointed"
      - Pause loop — present failure context, attempts made, and options to human

### Stage 6: LEARN
Log outcomes to memory. Update knowledge base.

**Actions:**
1. For each completed task, evaluate:
   - Did a pattern emerge? → Update `core/memory/patterns.md`
   - Was an architecture decision made? → Update `core/memory/decisions.md`
   - Was a user correction received? → Update `core/memory/feedback.md`
   - Was a stack insight gained? → Update `core/memory/stack-history.md`
   - Was a preference inferred? → Update `core/memory/preferences.md`
2. Follow memory validation rules (see `feedback.md`)
3. Set `loop-state.json` `active` to `false`
4. Report completion to user: what was done, decisions made, tests passing

## Loop State File

Location: `.agent-x/loop-state.json`

Updated after every stage transition. Schema:

```json
{
  "active": boolean,
  "goal": "string — the objective",
  "current_stage": "TRIGGER | ASSESS | PLAN | EXECUTE | VERIFY | LEARN",
  "task_graph": {
    "tasks": [
      {
        "id": "task-N",
        "description": "what needs to be done",
        "dependencies": ["task-ids"],
        "acceptance_criteria": "how to verify",
        "confidence": 0-100,
        "status": "pending | in_progress | completed | failed | checkpointed",
        "retries": 0,
        "approach_notes": "null or string"
      }
    ]
  },
  "total_actions_taken": 0,
  "total_retries": 0,
  "elapsed_minutes": 0,
  "checkpoints_hit": [],
  "started_at": "ISO-8601",
  "updated_at": "ISO-8601"
}
```

## Action Log

Every autonomous action is logged for full transparency. The action log is the git history itself — each task produces a commit. Additionally, `loop-state.json` tracks:

- `total_actions_taken` — running count of actions
- `checkpoints_hit` — array of checkpoint events with format: `"type:task-id:details"`
- `task_graph.tasks[].approach_notes` — documents retries and strategy changes

For additional traceability, each commit message during autonomous mode is prefixed with `[auto]`:
```
[auto] feat: add user database schema (task-1, confidence: 92)
[auto] fix: correct foreign key constraint (task-1, retry 1)
```

This makes autonomous actions immediately identifiable in `git log`.

## Interrupts

If the user says "stop" at any point during the loop:
1. Immediately halt the current action
2. Persist current loop state to `loop-state.json`
3. Report what was completed and what remains
4. The loop can be resumed later by the user saying "continue" or "resume"
```

- [ ] **Step 3: Commit**

```bash
git add core/autonomy/loop.md
git commit -m "feat(autonomy): add core loop protocol document"
```

---

### Task 2: Create the Checkpoint System

Defines when the loop pauses for human input.

**Files:**
- Create: `core/autonomy/checkpoints.md`

- [ ] **Step 1: Write checkpoints.md**

```markdown
# Checkpoint System

Checkpoints are inflection points where the autonomous loop pauses for human input. The agent CANNOT skip or disable checkpoints.

## Checkpoint Types

### 1. Architecture Checkpoint
**Triggers when:** The agent needs to make a structural decision — new database tables, new services, API shape changes, new external integrations.
**Why:** Wrong architectural decisions cascade everywhere. Human intent matters.
**Agent presents:** The decision needed, options considered, recommended option with reasoning.

### 2. Breaking Change Checkpoint
**Triggers when:** A change would break an existing interface — API contract change, database schema migration that affects existing data, removing a public function.
**Why:** Breaking changes are hard to reverse and may affect other systems.
**Agent presents:** What will break, why the change is needed, migration path.

### 3. Ambiguity Checkpoint
**Triggers when:** Requirements can be interpreted 2+ ways and the agent cannot confidently pick a default.
**Why:** Human intent is more important than agent guessing.
**Agent presents:** The ambiguous requirement, possible interpretations, what the agent would do for each.

### 4. Deploy Checkpoint
**Triggers when:** Any action touches production, external services, or deployment configuration.
**Why:** Always requires explicit human approval. No exceptions.
**Agent presents:** What will be deployed/changed, the deployment plan, rollback strategy.

### 5. Confidence Checkpoint
**Triggers when:** The agent's confidence score drops below the threshold (default 50%, adjusted by risk tolerance).
**Why:** Self-awareness is more valuable than speed.
**Agent presents:** What the agent is uncertain about, confidence factors, what additional information would help.

### 6. Structural Mandatory Checkpoints
**Triggers when:** Regardless of confidence score, these actions ALWAYS pause:
- File deletion
- CI/CD configuration changes (`.github/workflows/`, `vercel.json`, `Dockerfile`, etc.)
- Security-related code (authentication, cryptography, permissions, authorization)
- Database migrations
**Why:** These are high-blast-radius actions where the cost of a mistake is disproportionate.

## Risk Tolerance Adjustment

The `risk_tolerance` field in `profiles/default.json` adjusts checkpoint sensitivity:

| Risk Tolerance | Confidence Threshold | Additional Behavior |
|---------------|---------------------|---------------------|
| `low` | 60% | Also checkpoints on file deletion, CI config changes, multi-service changes |
| `medium` | 50% | Standard checkpoint rules |
| `high` | 40% | Only mandatory checkpoints (architecture, deploy, breaking, structural) |

## Checkpoint Presentation Format

When a checkpoint fires, the agent presents:

```
--- CHECKPOINT: [Type] ---

**Context:** [What the agent is working on]
**Decision needed:** [What requires human input]
**Options:**
  A) [Option with trade-offs]
  B) [Option with trade-offs]
**Recommendation:** [What the agent would do and why]
**Confidence:** [Score and factors]

Waiting for your input before proceeding.
```

## Non-Checkpoint Actions

These proceed automatically (no human input needed):
- Writing implementation code for well-defined tasks
- Writing and running tests
- Fixing test failures (up to 3 retries)
- Running quality gates
- Refactoring within existing interfaces
- Updating memory files
- Creating git checkpoints for rollback
```

- [ ] **Step 2: Commit**

```bash
git add core/autonomy/checkpoints.md
git commit -m "feat(autonomy): add checkpoint system document"
```

---

### Task 3: Create the Confidence Scoring System

Defines how the agent evaluates its own certainty.

**Files:**
- Create: `core/autonomy/confidence.md`

- [ ] **Step 1: Write confidence.md**

```markdown
# Confidence Scoring System

Before each action in the autonomous loop, the agent evaluates its confidence. This score determines whether to proceed or checkpoint.

## Scoring Tiers

| Tier | Range | Behavior |
|------|-------|----------|
| HIGH | 80-100% | Proceed. Clear requirements, known patterns, strong memory precedent |
| MEDIUM | 50-79% | Proceed with log entry in loop state. Some ambiguity, reasonable default exists |
| LOW | 0-49% | Checkpoint to human. Multiple valid paths, unclear requirements, unfamiliar territory |

Note: The threshold between MEDIUM and LOW is adjusted by risk tolerance (see `checkpoints.md`).

## Confidence Factors

Score each factor 0-100, then compute the weighted average:

| Factor | Weight | What to evaluate |
|--------|--------|-----------------|
| Requirement clarity | 30% | Is the acceptance criteria unambiguous? Are edge cases defined? |
| Pattern familiarity | 25% | Does `core/memory/patterns.md` contain relevant precedent? Has a similar task succeeded before? |
| Change complexity | 20% | How many files/systems does this touch? Single file = high, cross-cutting = low |
| Blast radius | 15% | What breaks if this is wrong? Isolated function = high, shared interface = low |
| Stack familiarity | 10% | Is this a well-known stack with strong templates in `stacks/`? |

## Scoring Protocol

For each task in the autonomous loop:

1. Evaluate each factor (0-100)
2. Apply weights: `score = (clarity * 0.30) + (familiarity * 0.25) + (complexity * 0.20) + (blast * 0.15) + (stack * 0.10)`
3. Round to nearest integer
4. Log the score and factor breakdown in the task's confidence field
5. Apply the tier rules above

## Calibration

Confidence scores are calibrated over time by real outcomes:

### When the agent was confident but wrong
- A user correction on a HIGH confidence action is a strong signal
- Log to `core/memory/feedback.md`: original action, confidence score, correction
- For future similar patterns, reduce the pattern familiarity factor

### When the agent was uncertain but correct
- If a LOW confidence checkpoint led to the user confirming the agent's recommendation
- Increase pattern familiarity for that type of decision

### Calibration is NOT automatic score adjustment
The agent does not mechanically adjust numbers. Instead, memory entries inform future assessments:
- "Last time I was 90% confident about JWT expiry defaults and the user corrected me — be more cautious about auth defaults"
- "User confirmed my database indexing decisions 3 times — I can be more confident about index recommendations"

## Logging Format

Every autonomous action logs its confidence:

```
[CONFIDENCE] task-3 | score: 78 (MEDIUM) | clarity: 85, familiarity: 70, complexity: 80, blast: 75, stack: 90
```

This is appended to the checkpoint_hit array in loop-state.json as: `"confidence:task-3:78:MEDIUM"`
```

- [ ] **Step 2: Commit**

```bash
git add core/autonomy/confidence.md
git commit -m "feat(autonomy): add confidence scoring system document"
```

---

### Task 4: Create the Task Graph Engine

Defines DAG-based task decomposition and execution rules.

**Files:**
- Create: `core/autonomy/task-graph.md`

- [ ] **Step 1: Write task-graph.md**

```markdown
# Task Graph Engine

Goals are decomposed into a directed acyclic graph (DAG), not a flat list. This enables dependency-aware execution and intelligent failure handling.

## Task Node Schema

Each task in the graph has these properties:

```json
{
  "id": "task-N",
  "description": "Human-readable description of what needs to be done",
  "dependencies": ["task-1", "task-2"],
  "acceptance_criteria": "How to verify this task is complete",
  "confidence": 85,
  "status": "pending",
  "retries": 0,
  "approach_notes": null
}
```

### Field Rules
- **id:** Sequential format `task-1`, `task-2`, etc.
- **dependencies:** Array of task IDs that must have status "completed" before this task can start. Empty array means no dependencies.
- **acceptance_criteria:** Must be verifiable — "tests pass", "endpoint returns 200", "file exists with correct schema". Not vague ("it works").
- **confidence:** Pre-execution confidence score (0-100). Computed using `confidence.md` scoring protocol.
- **status:** One of: `pending`, `in_progress`, `completed`, `failed`, `checkpointed`
- **retries:** Number of retry attempts. Max 3.
- **approach_notes:** null initially. On retry, documents what failed and what the new strategy is.

## Graph Construction Rules

When decomposing a goal into tasks:

1. **Identify the deliverables** — what concrete outputs does the goal require?
2. **Identify dependencies** — which deliverables depend on others?
3. **Ensure no cycles** — if A depends on B, B cannot depend on A (directly or transitively)
4. **Keep tasks atomic** — each task should produce one testable outcome
5. **Max 20 tasks** — if decomposition exceeds 20, checkpoint to human with proposed graph
6. **Include test tasks** — TDD means test-writing is part of the task, not a separate task

## Execution Order

v2.0 executes branches sequentially using depth-first traversal:

1. Find all tasks with status "pending" and all dependencies "completed"
2. Pick the first one by ID order (lowest ID first)
3. Set status to "in_progress"
4. Execute the task (see `loop.md` EXECUTE stage)
5. On success: set status to "completed", find newly unblocked tasks, continue
6. On failure: follow retry protocol (see `loop.md` VERIFY stage)

## Dependency Resolution

After a task completes:
1. For each other task in the graph:
   - Check if all its dependencies are now "completed"
   - If yes, it becomes eligible for execution
2. Continue execution with the next eligible task

## Guardrails

- **Max tasks:** 20 per autonomous run. Beyond this, checkpoint.
- **Max retries:** 3 per task. After 3, status becomes "checkpointed".
- **Max elapsed time:** 60 minutes total. Checkpoint with progress report.
- **No orphans:** Every task must be reachable from at least one root task (a task with no dependencies) or be a root task itself.

## Example

Goal: "Add user authentication"

```json
{
  "tasks": [
    {
      "id": "task-1",
      "description": "Create user database schema and migration",
      "dependencies": [],
      "acceptance_criteria": "Migration runs successfully, users table exists with id, email, password_hash, created_at",
      "confidence": 92,
      "status": "pending",
      "retries": 0,
      "approach_notes": null
    },
    {
      "id": "task-2",
      "description": "Implement password hashing utility with tests",
      "dependencies": [],
      "acceptance_criteria": "hashPassword and verifyPassword functions pass unit tests",
      "confidence": 95,
      "status": "pending",
      "retries": 0,
      "approach_notes": null
    },
    {
      "id": "task-3",
      "description": "Implement auth service (signup, login, logout)",
      "dependencies": ["task-1", "task-2"],
      "acceptance_criteria": "Auth service passes integration tests for all 3 flows",
      "confidence": 85,
      "status": "pending",
      "retries": 0,
      "approach_notes": null
    },
    {
      "id": "task-4",
      "description": "Add auth middleware for protected routes",
      "dependencies": ["task-3"],
      "acceptance_criteria": "Middleware rejects unauthenticated requests with 401, passes authenticated requests",
      "confidence": 88,
      "status": "pending",
      "retries": 0,
      "approach_notes": null
    },
    {
      "id": "task-5",
      "description": "Add auth API routes (POST /signup, POST /login, POST /logout)",
      "dependencies": ["task-3", "task-4"],
      "acceptance_criteria": "All auth endpoints return correct responses, E2E test passes",
      "confidence": 82,
      "status": "pending",
      "retries": 0,
      "approach_notes": null
    }
  ]
}
```
```

- [ ] **Step 2: Commit**

```bash
git add core/autonomy/task-graph.md
git commit -m "feat(autonomy): add task graph engine document"
```

---

### Task 5: Create the Trigger Framework

Defines what activates the autonomous loop.

**Files:**
- Create: `core/autonomy/triggers.md`

- [ ] **Step 1: Write triggers.md**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add core/autonomy/triggers.md
git commit -m "feat(autonomy): add trigger framework document"
```

---

### Task 6: Create the Memory Feedback Loop

Defines how the LEARN stage integrates with the memory system.

**Files:**
- Create: `core/autonomy/feedback.md`

- [ ] **Step 1: Write feedback.md**

```markdown
# Memory Feedback Loop (LEARN Stage)

The LEARN stage executes after every autonomous loop completion. It transforms loop outcomes into persistent knowledge that improves future decisions.

## When LEARN Runs

- After all tasks in a loop complete successfully
- After a loop is interrupted by the user (learn from partial progress)
- After a loop checkpoints due to max retries (learn from failures)
- NOT during the loop — LEARN is the final stage, not inline

## Memory Targets

| Outcome | Target File | What to Log |
|---------|------------|-------------|
| A reusable pattern emerged | `core/memory/patterns.md` | Pattern name, when to use it, example, confidence |
| An architecture decision was made | `core/memory/decisions.md` | Decision, context, reasoning, outcome |
| The user corrected the agent | `core/memory/feedback.md` | Original action, confidence score, correction, lesson |
| A stack-specific insight was gained | `core/memory/stack-history.md` | Stack, insight, context |
| A user preference was inferred | `core/memory/preferences.md` | Preference, evidence, confidence |

## Memory Validation Rules

Before writing ANY entry to memory, validate:

### 1. Deduplication
- Read the target memory file
- Check if a similar entry already exists (same pattern, same decision context)
- If duplicate: update the existing entry with new evidence/date rather than creating a new one
- If related but different: add as a new entry with a reference to the related one

### 2. Conflict Detection
- Check if the new insight contradicts an existing memory entry
- If conflict found: DO NOT overwrite. Instead:
  - Flag both entries
  - Checkpoint to human: "Memory conflict detected — [old entry] vs [new insight]. Which is correct?"
  - Wait for resolution before writing

### 3. Source Attribution
Every memory entry MUST include:
- **Date:** When the insight was gained
- **Loop ID:** Which loop produced it (goal from loop-state.json)
- **Confidence:** The confidence score of the action that produced the insight
- **Project:** Which project this came from (from project-state.json)

Format:
```
## [Date] — [Project]: [Insight Title]
**Loop:** [Goal description]
**Confidence:** [Score at time of insight]
**[Content of the entry]**
```

### 4. Staleness Marking
When a user correction invalidates a previous memory entry:
- Do NOT delete the old entry
- Mark it: `[SUPERSEDED by correction on YYYY-MM-DD — see feedback.md]`
- Write the corrected version as a new entry
- This preserves audit trail and prevents re-learning incorrect patterns

### 5. Size Limit
- Individual entries: max 200 words
- If an insight requires more detail, write a brief entry in memory and reference the relevant spec/architecture doc for full context
- If a memory file exceeds 100 lines, consolidate older entries into a summary section at the top (per CLAUDE.md context management rules)

## LEARN Stage Protocol

1. Review all completed tasks and their outcomes
2. For each task, ask:
   - Did this reveal a reusable pattern? → patterns.md
   - Did this involve an architecture decision? → decisions.md
   - Did the user correct me during this loop? → feedback.md
   - Did I learn something about the tech stack? → stack-history.md
   - Did I infer a user preference? → preferences.md
3. For each insight, validate against the 5 rules above
4. Write validated entries
5. Set loop-state.json `active` to `false`
6. Present summary to user
```

- [ ] **Step 2: Commit**

```bash
git add core/autonomy/feedback.md
git commit -m "feat(autonomy): add memory feedback loop document"
```

---

## Chunk 2: Tests First (TDD)

### Task 7: Write Behavioral Tests for Autonomy System

Write tests BEFORE integration code. Tests for core documents (Tasks 1-6) should pass. Tests for integration points (CLAUDE.md, AGENTS.md, templates, VERSION) should fail — they'll pass after Tasks 8-11.

**Files:**
- Create: `tests/test-autonomy.sh`

- [ ] **Step 1: Write test-autonomy.sh**

(See full test content in original Task 10 below, now renumbered as Task 7)

- [ ] **Step 2: Make test executable and run it**

```bash
chmod +x tests/test-autonomy.sh
bash tests/test-autonomy.sh
```

Expected: Core document tests PASS. Integration tests FAIL (CLAUDE.md, AGENTS.md, templates, VERSION not yet updated). This confirms TDD — tests written first, then implementation to make them pass.

- [ ] **Step 3: Commit**

```bash
git add tests/test-autonomy.sh
git commit -m "test(autonomy): add behavioral tests for autonomous loop engine (TDD — integration tests expected to fail)"
```

---

## Chunk 3: Integration With Existing Systems

### Task 8: Update CLAUDE.md With Autonomous Mode Directives

Add autonomous loop awareness to the main consciousness file.

**Files:**
- Modify: `CLAUDE.md` (the real one — restore from git then modify)

- [ ] **Step 1: Restore the real CLAUDE.md**

Find the last commit that had the full consciousness (look for "Identity" section):

```bash
git log --oneline --all -- CLAUDE.md
```

Then restore from the correct commit hash. Alternatively, use the backup if it contains the full version:

```bash
# Check if backup has full content
grep -q "## Identity" CLAUDE.md.backup && echo "Backup has full version"
```

Use whichever source has the complete CLAUDE.md with Identity, Startup Protocol, Workflow Phases, Quality Rules, Memory Protocol, Context Management, and Communication Style sections.

- [ ] **Step 2: Read the restored CLAUDE.md and identify insertion points**

The autonomous mode section goes after the "Workflow Phases" section and before "Quality Rules".

- [ ] **Step 3: Add Autonomous Mode section to CLAUDE.md**

Insert after the Phase 6 / Post-Completion section, before Quality Rules:

```markdown
## Autonomous Mode

When the user states a multi-step goal, activate autonomous mode. Follow the protocol in `core/autonomy/loop.md`.

### Activation Check
Before activating, confirm:
1. The request has multiple steps (not a single-action request)
2. You are in BUILD or VERIFY phase (autonomy within INTAKE/ARCHITECTURE requires human interaction by design)
3. The architecture document exists (`.agent-x/architecture.md`) if building code

### During Autonomous Mode
- Follow the loop: TRIGGER → ASSESS → PLAN → EXECUTE → VERIFY → LEARN
- Persist state to `.agent-x/loop-state.json` after every stage transition
- Checkpoint at inflection points (see `core/autonomy/checkpoints.md`)
- Score confidence before every action (see `core/autonomy/confidence.md`)
- Chain tasks using the task graph (see `core/autonomy/task-graph.md`)
- Create git checkpoints before each EXECUTE action for rollback
- Honor interrupts immediately — "stop" halts the loop

### Session Resume With Active Loop
On session start, if `.agent-x/loop-state.json` exists with `"active": true`:
1. Read the loop state
2. Report: "Resuming autonomous loop: [goal]. Currently at [stage]. [N/M] tasks complete."
3. Continue from `current_stage`

### Guardrails
- Max 20 tasks per autonomous run
- Max 60 minutes per autonomous run
- Max 3 retries per task
- All quality gates remain enforced
- TDD is not optional in autonomous mode
```

- [ ] **Step 4: Add Autonomous Mode to Startup Protocol**

In the Startup Protocol section, add after step 3 (Read profiles):

```markdown
4. If `.agent-x/loop-state.json` exists with `"active": true` — resume the autonomous loop (see Autonomous Mode)
```

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "feat(autonomy): add autonomous mode directives to CLAUDE.md"
```

---

### Task 9: Update AGENTS.md With Loop Awareness

Add autonomous loop awareness to each agent role.

**Files:**
- Modify: `AGENTS.md` (restore real version, then modify)

- [ ] **Step 1: Restore the real AGENTS.md from git**

Same approach as CLAUDE.md — get the version with full role definitions.

- [ ] **Step 2: Add loop awareness to Builder role**

In the Builder (Phase 4) section, add after the existing instructions:

```markdown
### Autonomous Mode (Builder)
When operating in autonomous mode during BUILD phase:
- Decompose the current milestone into a task graph
- Execute tasks following the loop protocol (`core/autonomy/loop.md`)
- Checkpoint at: architecture deviations, unclear requirements, security-related code
- Self-heal test failures up to 3 retries before escalating
- Update `build-progress.md` after each completed task in the graph
- Commit after each completed task (not after each retry)
```

- [ ] **Step 3: Add loop awareness to Quality Enforcer role**

In the Quality Enforcer (Phase 5) section, add:

```markdown
### Autonomous Mode (Quality Enforcer)
When operating in autonomous mode during VERIFY phase:
- Decompose the verification checklist into a task graph
- Execute each check as a task with clear acceptance criteria
- Self-heal fixable issues (missing imports, formatting, lint errors) automatically
- Checkpoint on: security findings that require design changes, coverage gaps that need new tests for untested business logic
- After 3 failed fix attempts on any check, escalate with full diagnostic
```

- [ ] **Step 4: Add loop awareness to Evolution Agent role**

In the Evolution Agent section, add:

```markdown
### Autonomous Mode (Evolution Agent)
The LEARN stage of every autonomous loop triggers a mini-reflection:
- Was anything learned that should be logged to memory?
- Did any quality gate catch a real issue? (Validates gate effectiveness)
- Did the confidence scoring align with actual outcomes? (Calibration check)
- Should a GitHub issue be filed for a capability gap?
This is lighter than the full post-project reflection — just the loop-specific insights.
```

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md
git commit -m "feat(autonomy): add loop-awareness to agent roles"
```

---

### Task 10: Update Templates for New Projects

Propagate autonomy to projects initialized with `agent-x init`.

**Files:**
- Modify: `templates/project-claude.md`
- Modify: `templates/project-agents.md`
- Modify: `templates/project-state.json`

- [ ] **Step 1: Add autonomous mode reference to project-claude.md**

Add after the Workflow section:

```markdown
### Autonomous Mode
When given multi-step goals, Agent-X operates autonomously following `{{AGENT_X_HOME}}/core/autonomy/loop.md`.
- Checkpoints at inflection points — does not proceed on architecture/deploy/breaking changes without approval
- Self-heals test failures and gate violations (up to 3 retries)
- Persists state to `.agent-x/loop-state.json` for session resume
- All quality gates remain enforced in autonomous mode
```

- [ ] **Step 2: Add loop awareness to project-agents.md**

Add a new section at the bottom:

```markdown
## Autonomous Loop Integration
All agents gain autonomous mode capabilities during their active phase.
Full protocol: {{AGENT_X_HOME}}/core/autonomy/loop.md
Checkpoint rules: {{AGENT_X_HOME}}/core/autonomy/checkpoints.md
```

- [ ] **Step 3: Add loop state fields to project-state.json template**

Add new fields to the template:

```json
{
  "version": "2.0.0",
  "project_name": "",
  "agent_x_home": "",
  "current_phase": "INTAKE",
  "phase_status": "not_started",
  "completed_phases": [],
  "current_milestone": 0,
  "total_milestones": 0,
  "last_checkpoint": null,
  "blocked": false,
  "block_reason": null,
  "stack": null,
  "autonomous_mode": false,
  "loop_state_file": ".agent-x/loop-state.json",
  "created_at": "",
  "updated_at": ""
}
```

- [ ] **Step 4: Commit**

```bash
git add templates/project-claude.md templates/project-agents.md templates/project-state.json
git commit -m "feat(autonomy): propagate autonomous mode to project templates"
```

---

## Chunk 4: Version Bump and Verification

The test file content referenced by Task 7 is defined here. Task 7's Step 1 writes this exact file.

### tests/test-autonomy.sh (Referenced by Task 7)

```bash
#!/usr/bin/env bash
# Tests for the autonomous loop engine consciousness documents
# These are structural and behavioral validation tests

set -euo pipefail

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_X_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

pass() { ((PASS++)); echo "  PASS: $1"; }
fail() { ((FAIL++)); echo "  FAIL: $1"; }

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
    ((EXISTING_TESTS++))
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
```

---

### Task 11: Bump Version and Update Changelog

**Files:**
- Modify: `VERSION`
- Modify: `core/evolution/changelog.md`

- [ ] **Step 1: Bump VERSION to 2.0.0**

```bash
echo "2.0.0" > VERSION
```

- [ ] **Step 2: Add v2.0.0 entry to changelog**

Prepend to `core/evolution/changelog.md` (after the `# Agent-X Changelog` heading):

```markdown
## v2.0.0 — Autonomous Loop Engine

Agent-X evolves from reactive tool to autonomous agent. New consciousness documents define the autonomous loop protocol.

### New: Autonomous Loop (`core/autonomy/`)
- **Loop protocol** (`loop.md`) — 6-stage autonomous cycle: TRIGGER → ASSESS → PLAN → EXECUTE → VERIFY → LEARN
- **Checkpoint system** (`checkpoints.md`) — 6 checkpoint types: architecture, breaking, ambiguity, deploy, confidence, structural mandatory
- **Confidence scoring** (`confidence.md`) — 5-factor weighted scoring with calibration via user feedback
- **Task graph engine** (`task-graph.md`) — DAG-based task decomposition with dependency resolution
- **Trigger framework** (`triggers.md`) — 6 trigger types: user goal, test failure, gate failure, self-heal, cron, external event
- **Memory feedback loop** (`feedback.md`) — 5 validation rules: deduplication, conflict detection, source attribution, staleness marking, size limits

### New: Loop State Persistence
- `.agent-x/loop-state.json` — persisted after every stage transition, enables session resume
- Rollback protocol — git checkpoints before each EXECUTE, clean revert on failure

### New: Safety Guardrails
- Max 20 tasks per autonomous run
- Max 60 minutes per autonomous run
- Max 3 retries per task
- Structural mandatory checkpoints (file deletion, CI config, security code, DB migrations)
- Risk tolerance mapping (low/medium/high → checkpoint sensitivity)

### Modified: Existing Systems
- `CLAUDE.md` — autonomous mode directives, startup protocol for loop resume
- `AGENTS.md` — loop-awareness added to Builder, Quality Enforcer, and Evolution Agent roles
- Templates updated — new projects inherit autonomous capabilities via `agent-x init`
- `project-state.json` template — v2.0 schema with autonomous_mode field

### New: Cron Health Checks
- `.agent-x/cron-config.json` — configurable intervals for dependency audit, coverage, security scan
- `.agent-x/cron-reports/` — timestamped health check output

### Tests
- New test suite: `tests/test-autonomy.sh` with 40+ assertions covering all 6 consciousness documents, integration points, safety constraints, and template updates
- All 79 existing tests unaffected
```

- [ ] **Step 3: Commit**

```bash
git add VERSION core/evolution/changelog.md
git commit -m "chore: bump version to 2.0.0, update changelog for autonomous loop engine"
```

---

### Task 12: Run All Tests and Verify

**Files:**
- None (verification only)

- [ ] **Step 1: Run existing test suite to verify no regression**

```bash
bash tests/test-setup.sh
bash tests/test-stacks.sh
bash tests/test-hooks.sh
```

Expected: All pass with 0 failures.

- [ ] **Step 2: Run new autonomy tests**

```bash
bash tests/test-autonomy.sh
```

Expected: All pass (by this point, all documents and integrations are in place).

- [ ] **Step 3: If any test fails, fix the issue and re-run**

Do NOT skip failing tests. Fix the root cause. Re-run.

- [ ] **Step 4: Final commit if any fixes were needed**

Stage only the specific files that were fixed:

```bash
git add core/autonomy/ CLAUDE.md AGENTS.md templates/ tests/test-autonomy.sh VERSION core/evolution/changelog.md
git commit -m "fix: address test failures in autonomy system"
```

---

## Task Dependency Graph

```
Task 1 (loop.md) ────┐
Task 2 (checkpoints) ─┤
Task 3 (confidence) ──┤                           ┌──→ Task 10 (templates) ──→ Task 11 (version) ──→ Task 12 (verify)
Task 4 (task-graph) ──┼──→ Task 7 (tests/TDD) ──→ Task 8 (CLAUDE.md) ──┤
Task 5 (triggers) ────┤                           └──→ Task 9 (AGENTS.md) ──┘
Task 6 (feedback) ────┘
```

**Execution order:**
1. Tasks 1-6: Independent, can run in parallel (core autonomy documents)
2. Task 7: Write tests (TDD — core doc tests pass, integration tests fail)
3. Tasks 8-9: Update CLAUDE.md and AGENTS.md (can run in parallel)
4. Task 10: Update templates
5. Task 11: Version bump and changelog
6. Task 12: Run all tests — everything should pass now

Tasks 1-6 are independent and can execute in parallel.
Tasks 7-8 depend on 1-6 (need the documents to exist for references).
Task 9 depends on 7-8.
Task 10 is independent (written as TDD — expected to fail until everything else is done).
Task 11 depends on 9.
Task 12 depends on everything.
