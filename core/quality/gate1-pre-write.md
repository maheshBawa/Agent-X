# Gate 1: Pre-Write Rules

## Purpose
Validate that code being written aligns with the approved architecture and follows project conventions.

## Checks
1. **Architecture alignment:** The file being written must correspond to a component in `.agent-x/architecture.md`
2. **Test-first:** A test file must exist or be created alongside the implementation file
3. **No duplication:** The functionality must not duplicate existing code in the project

## Enforcement
- Runs as `PreToolUse` hook on `Write` and `Edit` tools
- Script: `.claude/hooks/pre-write.sh`
- Blocks: Missing architecture doc, no test alongside code
- Warns: Potential duplication detected

## When to Skip
- Non-code files (markdown, JSON, YAML, config files)
- Test files themselves
- Files in `.agent-x/` directory
