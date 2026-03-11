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
