# Agent-X Changelog

## v2.0.0 — Autonomous Loop Engine

Agent-X evolves from reactive tool to autonomous agent. New consciousness documents define the autonomous loop protocol.

### New: Autonomous Loop (`core/autonomy/`)
- **Loop protocol** (`loop.md`) — 6-stage autonomous cycle: TRIGGER → ASSESS → PLAN → EXECUTE → VERIFY → LEARN
- **Checkpoint system** (`checkpoints.md`) — 6 checkpoint types: architecture, breaking, ambiguity, deploy, confidence, structural mandatory
- **Confidence scoring** (`confidence.md`) — 5-factor weighted scoring with calibration via user feedback
- **Task graph engine** (`task-graph.md`) — DAG-based task decomposition with dependency resolution
- **Trigger framework** (`triggers.md`) — 6 trigger types: user goal, test failure, gate failure, self-heal, cron, external event
- **Memory feedback loop** (`feedback.md`) — 5 validation rules: deduplication, conflict detection, source attribution, staleness marking, size limits

### New: Loop State Persistence
- `.agent-x/loop-state.json` — persisted after every stage transition, enables session resume
- Rollback protocol — git checkpoints before each EXECUTE, clean revert on failure

### New: Safety Guardrails
- Max 20 tasks per autonomous run
- Max 60 minutes per autonomous run
- Max 3 retries per task
- Structural mandatory checkpoints (file deletion, CI config, security code, DB migrations)
- Risk tolerance mapping (low/medium/high → checkpoint sensitivity)

### Modified: Existing Systems
- `CLAUDE.md` — autonomous mode directives, startup protocol for loop resume
- `AGENTS.md` — loop-awareness added to Builder, Quality Enforcer, and Evolution Agent roles
- Templates updated — new projects inherit autonomous capabilities via `agent-x init`
- `project-state.json` template — v2.0 schema with autonomous_mode field

### New: Cron Health Checks
- `.agent-x/cron-config.json` — configurable intervals for dependency audit, coverage, security scan
- `.agent-x/cron-reports/` — timestamped health check output

### Tests
- New test suite: `tests/test-autonomy.sh` with 40+ assertions covering all 6 consciousness documents, integration points, safety constraints, and template updates
- All 79 existing tests unaffected

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
