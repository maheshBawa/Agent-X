# Agent-X Changelog

## v1.2.0 — Complete Evolution (All 32 Issues Resolved)
Final batch: all 10 remaining nice-to-have issues fixed in PR #77.

- Stack ID validation before architecture phase
- Smoke test templates per stack + mandatory /api/health endpoint
- .claude/plugins/ directory for future extensibility
- Database migration workflow docs (Prisma, Alembic, Mongoose)
- Context limit management guidance for growing projects
- 23 new deep tests (79 total) covering all 4 gates, CLI, and edge cases
- Custom rules from profile.json enforced in Gate 2
- Design spec corrected (snyk → npm audit)
- Monorepo project support documented with conventions
- Gate 2 secret detection runs universally (all repos, not just Agent-X projects)

**All 32 evolution issues closed. Zero remaining.**

## v1.1.0 — First Self-Evolution Release
Evolution Agent analyzed v1.0.0, identified 32 gaps, fixed 22 across 3 PRs.

### Critical (5 fixed)
- Pre-commit hook fast-path exit for non-commit commands
- Test runner guards for fresh/unconfigured projects
- Stack-specific quality runner (run-quality.sh)
- Hook path resolution from filesystem location
- Secret detection: 3 patterns, expanded keywords, connection strings, portable quoting

### Important (12 fixed)
- Gate 4 mandatory run instruction in CLAUDE.md
- Python FastAPI and Static Site CI/CD templates
- Build progress tracking for session resume
- Gate 3 docs updated to reflect reality
- Init backs up existing CLAUDE.md/AGENTS.md
- Safe JSON profile construction via Python
- Multi-stack guidance for React Native + backend
- Security-exceptions.md in project .gitignore
- Static site stack uses Playwright as test runner
- SAST expanded: A02 weak crypto, A05 CORS, A10 SSRF
- Portable single-quote matching (replaced \x27)
- Space-safe git ls-files loops

### Nice-to-Have (5 fixed)
- `agent-x reset [PHASE]` command
- Centralized VERSION file
- PowerShell bash availability check
- echo -e replaced with printf
- Gate 4 uses while-read for filenames

### Remaining (0 — all resolved in v1.2.0)

## v1.0.0 — Initial Release
- CLAUDE.md consciousness with full workflow rules and JARVIS personality
- AGENTS.md with 7 agent role definitions
- Quality gates 1-4 implemented as Claude Code hooks
- Intake interview system
- Architecture planning system
- Tech stack engine with 5 stacks (Next.js, React Native, FastAPI, Express, Static)
- Adaptive memory system (profile + learned)
- Self-evolution engine
- Cross-platform setup script (bash + PowerShell)
- `agent-x init` command for new projects
- State management with session resume
