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
