# Gate 2: Post-Write Rules

## Purpose
Run quality checks on code after it has been written.

## Checks
1. **Secret detection:** Scan for hardcoded passwords, API keys, tokens
2. **Debug statements:** Warn about console.log, print() left in code
3. **Linting:** Run stack-specific linter (at milestone boundaries)
4. **Type checking:** Run type checker if applicable (at milestone boundaries)
5. **Complexity:** Check cognitive complexity threshold (at milestone boundaries)

## Enforcement
- Runs as `PostToolUse` hook on `Write` and `Edit` tools
- Script: `.claude/hooks/post-write.sh`
- Light checks run per file; full analysis batched at milestones
- Blocks: Hardcoded secrets
- Warns: Debug statements, complexity issues
