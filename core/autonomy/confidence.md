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
