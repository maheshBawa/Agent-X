# Agent-X Self-Evolution Engine

## Purpose
Agent-X continuously improves itself by identifying gaps, filing GitHub issues, and implementing upgrades.

## Triggers
Run a self-reflection after each of these events:
1. **Project completion** — Full post-project audit
2. **Repeated failure** — Same type of error occurs twice across projects
3. **Quality gate gap** — A security or quality issue slipped through gates
4. **Missing capability** — User requested something Agent-X couldn't do
5. **User correction** — User corrected Agent-X on a systemic issue

## Self-Reflection Process
1. Read `core/evolution/reflection-prompt.md` for the audit template
2. Analyze the current project honestly — what worked, what didn't
3. Log all insights to `core/evolution/insights.md`
4. For each actionable insight, decide: fix now or file an issue?
   - Small fixes (< 10 min): fix directly, commit, log in changelog
   - Large improvements: create a GitHub Issue

## GitHub Issue Format
```
Title: [CATEGORY] Brief description

## Current Behavior
[What Agent-X does now]

## Desired Behavior
[What it should do]

## Evidence
[Specific instances that triggered this insight]

## Proposed Solution
[How to fix it]

## Acceptance Criteria
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
```

Labels: `self-evolution`, category label (e.g., `ability`, `security`, `workflow`)

## Issue Categories
- `[ABILITY]` — Learn new stack or capability
- `[SECURITY]` — Strengthen quality gates
- `[PERFORMANCE]` — Optimize Agent-X workflows
- `[WORKFLOW]` — Improve intake, planning, or build processes
- `[KNOWLEDGE]` — Study new patterns and practices
- `[INTEGRATION]` — Add new deployment platform support

## Safeguards
1. NEVER remove existing quality gate checks
2. NEVER merge your own PRs — always present for user approval
3. NEVER modify these safeguard rules
4. CAN recalibrate thresholds (with user approval)
5. CAN add new checks to existing gates
6. CAN add new stacks to the registry
7. CAN improve prompts, templates, and workflows
8. Every upgrade MUST include tests proving the improvement works
9. Every upgrade MUST be logged in `core/evolution/changelog.md`

## Versioning
- Follow semver: MAJOR.MINOR.PATCH
- PATCH: bug fixes, threshold adjustments
- MINOR: new stacks, new checks, improved workflows
- MAJOR: architectural changes to Agent-X itself
- Version tracked in `core/evolution/changelog.md`

## Rollback
Every evolution upgrade is a separate git branch and PR.
If an upgrade causes regression: revert the merge commit.
