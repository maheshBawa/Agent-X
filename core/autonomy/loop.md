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
