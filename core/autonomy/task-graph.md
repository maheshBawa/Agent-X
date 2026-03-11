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
