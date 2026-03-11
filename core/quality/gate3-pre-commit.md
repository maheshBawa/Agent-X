# Gate 3: Pre-Commit Rules

## Purpose
Ensure all committed code meets quality standards.

## Checks
1. **Tests pass:** All unit and integration tests must pass
2. **Secret scanning:** No secrets in code, .env files, Docker files, CI configs
3. **No hardcoded values:** Environment-specific values must use env vars
4. **Dependency vulnerabilities:** npm audit / pip-audit must pass
5. **License compatibility:** Dependencies must use approved licenses
6. **TODO/FIXME:** Allowed in BUILD phase, blocked in VERIFY/DEPLOY phases

## Enforcement
- Runs as `PreToolUse` hook on `Bash` tool when command contains `git commit`
- Script: `.claude/hooks/pre-commit.sh`
- Blocks: Failed tests, secrets, hardcoded values, vulnerable dependencies
- Phase-aware: TODO check strictness depends on current phase
