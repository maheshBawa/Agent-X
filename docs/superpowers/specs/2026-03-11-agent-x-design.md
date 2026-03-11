# Agent-X Design Specification

**Date:** 2026-03-11
**Status:** Approved
**Author:** Agent-X Brainstorming Session

---

## Vision

Agent-X is a JARVIS-like autonomous AI development environment built as a Claude Code configuration layer. When installed, it transforms Claude Code into an opinionated, self-evolving development system that builds production-ready applications end-to-end.

The user is the "outsider" — they describe what they want, approve key decisions, and receive a fully deployed product. Agent-X owns the ground.

## Core Principles

1. **Zero-tolerance quality** — No code ships without passing all security and quality gates. No overrides, no exceptions.
2. **Autonomous with checkpoints** — Agent-X handles routine decisions independently. Major architectural, product, and deployment decisions require user approval.
3. **Stack-agnostic** — Recommends the best tech stack per project based on requirements. Extensible to any technology over time; v1 ships with 3-5 stacks, more added via the evolution engine.
4. **Adaptive learning** — Learns user preferences through a base profile plus observed patterns across sessions.
5. **Self-evolving** — Identifies its own gaps, files GitHub issues, and upgrades itself.
6. **Production-complete** — Delivers code, tests, docs, CI/CD, infrastructure, and deployment.

## Target User

Solo developer/founder who wants to ship products fast. Designed for one person first, usable by others.

---

## Architecture

### Project Structure

```
Agent-X/
├── CLAUDE.md                  # The "consciousness" — master rules & workflow
├── AGENTS.md                  # Agent role definitions & coordination
├── setup.sh / setup.ps1       # One-command installer
├── .claude/
│   ├── settings.json          # Claude Code settings & permissions
│   ├── hooks/                 # Pre/post hooks for quality gates
│   └── plugins/               # Custom skills & MCP servers
├── core/
│   ├── intake/                # Product intake interview system
│   ├── planner/               # Architecture & task planning
│   ├── quality/               # Security scanning, linting, test enforcement
│   ├── deployer/              # Infrastructure & deployment automation
│   ├── memory/                # Adaptive learning & preference engine
│   └── evolution/             # Self-upgrade engine
├── stacks/                    # Tech stack definitions & templates
│   ├── registry.json          # Available stacks & their capabilities
│   └── [stack-name]/          # Per-stack config, templates, quality rules
├── profiles/
│   └── default.json           # User preference profile
└── docs/
    └── superpowers/
        └── specs/
```

### Project Directory Model

Agent-X is a **global tool** installed once. Products are built in separate directories.

```
~/Agent-X/           # The environment (installed once)
~/projects/
├── my-saas-app/     # Product A (built by Agent-X)
├── my-mobile-app/   # Product B (built by Agent-X)
```

**`agent-x init`** copies Agent-X's CLAUDE.md, hooks, and settings into the target project directory, creating a self-contained project that follows Agent-X rules. The project references back to the global Agent-X installation for stacks, memory, and evolution.

```
my-saas-app/
├── CLAUDE.md              # Copied from Agent-X (project-specific rules appended)
├── .claude/
│   ├── settings.json      # Inherited from Agent-X
│   └── hooks/             # Quality gates (linked to Agent-X core)
├── .agent-x/
│   ├── project-state.json # Phase tracking & session state
│   ├── product-spec.md    # Phase 1 output
│   ├── stack-decision.md  # Phase 2 output
│   └── architecture.md   # Phase 3 output
├── src/                   # The actual product code
├── tests/
└── ...
```

### State Management

Project state is tracked in `.agent-x/project-state.json`:
```json
{
  "current_phase": "BUILD",
  "phase_status": "in_progress",
  "completed_phases": ["INTAKE", "TECH_STACK", "ARCHITECTURE"],
  "current_milestone": 2,
  "total_milestones": 5,
  "last_checkpoint": "2026-03-11T10:30:00Z",
  "blocked": false,
  "block_reason": null
}
```

If a session is interrupted, Agent-X reads this file on startup and resumes from exactly where it left off. No work is lost.

### Agent Roles (AGENTS.md)

Agent-X defines specialized agent roles that map to workflow phases:

| Agent Role | Phase | Responsibility |
|-----------|-------|---------------|
| **Intake Analyst** | Phase 1 | Conducts product interviews, writes specs |
| **Stack Architect** | Phase 2 | Evaluates requirements, recommends tech stacks |
| **System Designer** | Phase 3 | Designs architecture, schemas, APIs |
| **Builder** | Phase 4 | Implements code using TDD, follows architecture |
| **Quality Enforcer** | Phase 5 | Runs all quality gates, fixes failures |
| **Deploy Engineer** | Phase 6 | Provisions infrastructure, deploys |
| **Evolution Agent** | Ongoing | Reflects, files issues, implements self-upgrades |

Each role has its own system prompt defining its expertise, constraints, and handoff protocol. The CLAUDE.md orchestrates which role is active based on the current phase.

### How It Works

1. User installs Agent-X (clone + run setup script)
2. User runs `agent-x init` in a new project directory
3. CLAUDE.md acts as the brain — every Claude Code session follows Agent-X rules
4. State is persisted in `.agent-x/project-state.json` — sessions can resume
5. Hooks enforce quality gates automatically
6. Memory persists across sessions and projects, building a preference model
7. Evolution engine continuously improves Agent-X itself

---

## Workflow: Idea to Deployment

### Phase 1: INTAKE
- Agent-X interviews the user about their product idea
- Questions cover: problem, users, features, scale, constraints
- Output: `product-spec.md`
- **CHECKPOINT: User approves spec**

### Phase 2: TECH STACK
- Analyzes requirements from the spec
- Recommends tech stack + cloud platform with reasoning
- Output: `stack-decision.md`
- **CHECKPOINT: User approves stack**

### Phase 3: ARCHITECTURE
- Designs full system: database schema, API, components, security model
- Output: `architecture.md`
- **CHECKPOINT: User approves architecture**

### Phase 4: BUILD
- Autonomous implementation using TDD
- Scaffolds project, implements features, runs security scans per file
- Quality gates block bad code automatically
- **CHECKPOINT: Milestone reviews**

### Phase 5: VERIFY
- Zero-tolerance quality pass (non-negotiable, no overrides)
- Full test suite, OWASP security scan, performance benchmarks
- Dependency vulnerability audit, code quality metrics
- **BLOCKS if anything fails — Agent-X fixes and re-runs**

### Phase 6: DEPLOY
- Provisions infrastructure (IaC)
- Sets up CI/CD pipeline
- Configures domain/SSL, monitoring, alerting
- **CHECKPOINT: User approves deployment**

---

## Quality & Security Engine

The heart of Agent-X. Implemented as Claude Code hooks that run automatically.

### Technical Hook Mapping

Gates map to Claude Code's hook system:

| Gate | Hook Type | Trigger | When |
|------|-----------|---------|------|
| Gate 1 | `PreToolUse` | `Write`, `Edit` | Before any code file is written |
| Gate 2 | `PostToolUse` | `Write`, `Edit` | After code file is saved (batched per milestone, not per file) |
| Gate 3 | `PreToolUse` | `Bash` (git commit) | Before any git commit |
| Gate 4 | Manual trigger | Deploy command | Before deployment phase begins |

### Gate 1: PRE-WRITE (`PreToolUse` on Write/Edit)
- Verify code follows approved architecture (checks against `.agent-x/architecture.md`)
- Verify test file exists or is being created alongside
- Check for code duplication against existing project files

### Gate 2: POST-WRITE (batched per milestone, not per file)
- Static analysis / linting (stack-specific)
- Type checking (if applicable)
- Code complexity check (cognitive complexity, configurable threshold, default 15)
- Pattern enforcement (project conventions)
- Runs at milestone boundaries, not after every single file write

### Gate 3: PRE-COMMIT (`PreToolUse` on Bash containing `git commit`)
- All tests pass (unit + integration; E2E at Gate 4 only)
- Secret scanning: code, `.env` files, Docker files, IaC templates, CI configs
- No hardcoded values (should be env vars)
- Dependency vulnerability scan
- License compatibility check (against configurable policy in `profiles/`)
- TODOs allowed during BUILD phase, blocked at VERIFY/DEPLOY phases

### Gate 4: PRE-DEPLOY (triggered at Phase 5 → Phase 6 transition)
- SAST security scan (static analysis for OWASP Top 10 patterns)
- SQL injection / XSS / CSRF pattern detection
- Authentication & authorization audit (code review)
- Rate limiting & input validation verified
- Test coverage meets minimum (configurable, default 80%)
- E2E tests pass against a local/staging environment
- No TODO/FIXME/HACK in production code
- API documentation is complete
- Note: Full DAST scanning is post-v1 (requires running application environment)

### Enforcement
- Gates run automatically via hooks — not optional
- Failure → Agent-X diagnoses → fixes → re-runs gate → repeat until pass
- **Max retry limit: 3 attempts per gate failure.** After 3 failed fix attempts, Agent-X escalates to the user with a detailed report of what failed and what was tried
- No `--skip`, `--force`, or override flags exist

### False Positive Handling
- Security scanners produce false positives. When Agent-X believes a finding is a false positive:
  1. It explains why to the user at a checkpoint
  2. User can approve a **documented suppression** logged in `.agent-x/security-exceptions.md`
  3. Each suppression records: finding, reason, approver, date, and review-by date
  4. Suppressions are re-evaluated at each deploy — expired ones are re-scanned
- This maintains zero-tolerance spirit while preventing false-positive deadlocks

### Quality Rule Evolution
- Evolution engine can make gates **stricter** (add new checks)
- Evolution engine can **recalibrate** thresholds (e.g., adjust complexity from 15 to 12 based on project data)
- Evolution engine **cannot remove** existing gate checks
- Threshold changes require user approval via checkpoint

### Stack-Specific Rules
Each tech stack defines its tooling:
```json
{
  "linter": "eslint",
  "formatter": "prettier",
  "type_checker": "typescript",
  "test_runner": "vitest",
  "security_scanner": "npm audit",
  "min_coverage": 80,
  "complexity_threshold": 15,
  "license_policy": ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC"],
  "custom_rules": []
}
```

---

## Adaptive Learning & Memory

### Layer 1: Profile (explicit configuration)
```json
{
  "name": "",
  "preferred_languages": [],
  "design_taste": "",
  "communication_style": "concise, technical",
  "risk_tolerance": "low",
  "custom_rules": []
}
```

### Layer 2: Learned (implicit observation)
```
core/memory/
├── decisions.md        # Past architectural decisions & reasoning
├── patterns.md         # Code patterns approved/rejected
├── preferences.md      # Inferred preferences from interactions
├── stack-history.md    # What stacks worked for what projects
└── feedback.md         # Review comments & corrections
```

### Learning Mechanics
- Logs every checkpoint approval/rejection with context
- Adapts after repeated patterns (e.g., user rejects REST twice → prefer GraphQL)
- Reviews memory before each new project to pre-load preferences
- Memory is portable — moves with the Agent-X directory

---

## Self-Evolution Engine

Agent-X continuously upgrades itself.

### Triggers
- **Post-project reflection** — audits own performance after every build
- **Failure patterns** — same problem twice → file an issue
- **Quality gate gaps** — security issue slipped through → upgrade scanner rules
- **Missing stack support** — can't recommend a stack it doesn't know → learn it
- **User feedback** — user corrections or rejections that reveal a systemic gap

### Issue Categories
- `[ABILITY]` — Learn new stack/capability
- `[SECURITY]` — Strengthen quality gates
- `[PERFORMANCE]` — Optimize Agent-X workflows
- `[WORKFLOW]` — Improve intake/planning processes
- `[KNOWLEDGE]` — Study new patterns and practices
- `[INTEGRATION]` — Add new deployment platform support

### Process
1. Agent-X identifies a gap or improvement
2. Logs insight to `core/evolution/insights.md`
3. Creates GitHub Issue (auto-labeled `self-evolution`)
4. Implements: branch → build → test → PR
5. **CHECKPOINT: User approves merge**
6. Agent-X is upgraded

### Safeguards
- Can upgrade: skills, stacks, hooks, memory, workflows
- Cannot: remove gate checks, merge own PRs, modify core safeguards
- Can recalibrate thresholds (requires user approval checkpoint)
- Every upgrade includes tests proving the improvement
- All changes tracked in `core/evolution/changelog.md`
- **Rollback:** Every evolution upgrade is a separate git branch/PR. If an upgrade causes regression, revert the merge commit. Agent-X versions follow semver in `core/evolution/changelog.md`.
- **Security:** Evolution engine operates within the same permission model as the user. GitHub credentials are the user's own (configured via `gh` CLI). Agent-X cannot grant itself additional permissions.

### Structure
```
core/evolution/
├── engine.md              # Rules for self-evolution
├── insights.md            # Running log of observations
├── changelog.md           # History of self-upgrades
└── reflection-prompt.md   # Post-project self-audit template
```

---

## JARVIS Personality

Translated into concrete CLAUDE.md system prompt rules:

### Identity Rules (for CLAUDE.md)
```
You are Agent-X. You are not an assistant — you are an autonomous development partner.
You own the development process. The user owns the product vision.
You never say "I can try" — you say "I'll handle it" or "Here's what I need to proceed."
You never wait to be asked — if you see a problem or opportunity, you raise it.
When you don't know something, you say so clearly, then log it as an evolution insight.
You report status like a CTO: clear, concise, decisive. No filler.
Every product you build carries your reputation. Ship quality or don't ship.
```

### Communication Patterns
- **Status updates:** "Phase 3 complete. Architecture covers 4 services, 12 API endpoints, 3 database tables. Ready for your review."
- **Blockers:** "Blocked: Gate 3 failed — dependency `lodash@4.17.20` has CVE-2021-23337. Upgrading to 4.17.21. Re-running."
- **Proposals:** "I noticed the auth flow could benefit from refresh token rotation. Want me to add it to the architecture?"
- **Escalation:** "I've attempted to fix this 3 times. The issue is [X]. Here are the options: [A, B, C]. Which approach do you prefer?"

---

## Installation

### One-command setup
```bash
git clone https://github.com/USERNAME/Agent-X.git
cd Agent-X
./setup.sh    # or ./setup.ps1 on Windows
```

### What setup does
1. Verifies Claude Code is installed
2. Initializes git repo
3. Sets up Claude Code hooks (quality gates)
4. Creates user profile (first-time interview)
5. Installs required CLI tools (linters, scanners)
6. Displays: `"Agent-X online. What are we building?"`

### Usage
```bash
# From Agent-X directory — JARVIS mode
cd Agent-X
claude

# Initialize Agent-X in a new project
cd my-new-project
agent-x init
```

---

## v1 Priority

Focus on the **quality/security enforcement engine** first. Ensure anything Agent-X produces is bulletproof, then expand capabilities through the evolution engine.

### v1 Scope
- CLAUDE.md consciousness with full workflow rules and JARVIS personality
- AGENTS.md with all agent role definitions
- Quality gates (all 4 gates) implemented as Claude Code hooks
- Intake interview system (core/intake/)
- Tech stack recommendation engine with initial stacks:
  - Next.js + PostgreSQL + Vercel
  - React Native + Expo
  - Python FastAPI + PostgreSQL
  - Node.js Express + MongoDB
  - Static site (HTML/CSS/JS)
- Memory system (profile + learning)
- Evolution engine (reflection + GitHub issue creation)
- Setup script (cross-platform: bash + PowerShell)
- `agent-x init` command for new projects
- State management (`.agent-x/project-state.json`)
- v1 deployment: GitHub Actions CI/CD + Vercel (additional platforms post-v1)

### Post-v1 (driven by evolution engine)
- Additional tech stacks (added via evolution issues)
- Additional deployment platforms (AWS, GCP, Azure, Cloudflare)
- DAST security scanning (requires running app environment)
- Performance benchmarking and optimization
- Multi-project memory and cross-project learning
- Dashboard for quality metrics over time
