# Gate 3: Pre-Commit Rules

## Purpose
Ensure all committed code meets quality standards.

## Checks (Implemented)
1. **Secret scanning:** Detects hardcoded secrets via assignment, JSON, and connection string patterns
2. **.env file protection:** Blocks committing .env files (allows .env.example/.env.template)
3. **Hardcoded IPs/credentials in URLs:** Detects IPs with ports and URLs with embedded credentials
4. **TODO/FIXME:** Allowed in BUILD phase, blocked in VERIFY/DEPLOY phases
5. **Tests pass:** Runs npm test / pytest if configured (skips unconfigured test scripts)

## Deferred to Gate 4 (Pre-Deploy)
- **Dependency vulnerabilities:** npm audit / pip-audit (runs in Gate 4)
- **License compatibility:** License checker (runs in Gate 4)

## Enforcement
- Runs as `PreToolUse` hook on `Bash` tool
- Fast-path: exits immediately for non-commit Bash commands (no overhead)
- Script: `.claude/hooks/pre-commit.sh`
- Blocks: Failed tests, secrets, .env files, hardcoded values
- Phase-aware: TODO check strictness depends on current phase
