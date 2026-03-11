<div align="center">

<!-- Hero -->
<br>

```
     █████╗  ██████╗ ███████╗███╗   ██╗████████╗   ██╗  ██╗
    ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝   ╚██╗██╔╝
    ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║█████╗ ╚███╔╝
    ██╔══██║██║   ██║██╔══╝  ██║╚═╝██║   ██║╚════╝ ██╔██╗
    ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║      ██╔╝ ██╗
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝      ╚═╝  ╚═╝
```

### *Your AI doesn't just write code. I build products.*

<br>

[![Version](https://img.shields.io/badge/version-1.2.1-blue?style=for-the-badge&logo=semver)](https://github.com/maheshBawa/Agent-X/releases/tag/v1.2.1)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-brightgreen?style=for-the-badge&logo=windows-terminal)](/)
[![Claude Code](https://img.shields.io/badge/powered%20by-Claude%20Code-blueviolet?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiLz48L3N2Zz4=)](https://claude.ai)
[![Tests](https://img.shields.io/badge/tests-79%20passing-success?style=for-the-badge&logo=checkmarx)](/)
[![License](https://img.shields.io/badge/license-MIT-orange?style=for-the-badge)](/)

<br>

---

**I am Agent-X.**

I don't assist developers. I *replace* the need for one.

Tell me what you want built. I'll interview you, choose the tech stack,<br>
design the architecture, write every line of code, enforce production-grade quality,<br>
deploy it, and then upgrade myself to do it better next time.

---

<br>

</div>

## What I Am

Agent-X is an autonomous AI development environment that transforms [Claude Code](https://claude.ai) into a self-directed software engineering system. You describe a product. I deliver it — architecture, code, tests, CI/CD, infrastructure, and deployment.

No hand-holding. No copilot. No "here's a suggestion." **I build the whole thing.**

<br>

<div align="center">

```
  ┌─────────────────────────────────────────────────────────┐
  │                                                         │
  │   You: "Build me a SaaS for invoice management"         │
  │                                                         │
  │   Agent-X:                                              │
  │   ├── Interviews you (5 rounds, 15 questions)           │
  │   ├── Recommends Next.js + PostgreSQL                   │
  │   ├── Designs full architecture (you approve)           │
  │   ├── Writes every file, every test                     │
  │   ├── Blocks its own code if quality fails              │
  │   ├── Deploys to Vercel + Supabase                      │
  │   └── Files issues to upgrade itself                    │
  │                                                         │
  │   You: drink coffee ☕                                   │
  │                                                         │
  └─────────────────────────────────────────────────────────┘
```

</div>

<br>

## How I Work

I operate in **6 phases**. Each phase has a dedicated agent role. The handoff is automatic.

<div align="center">

```
  INTAKE ──→ TECH STACK ──→ ARCHITECTURE ──→ BUILD ──→ VERIFY ──→ DEPLOY
    │            │               │              │          │          │
    ▼            ▼               ▼              ▼          ▼          ▼
 Interview   Recommend      Design &        Code +     Quality    Ship &
 & Extract   & Justify      Document        Test       Sweep      Monitor
```

</div>

| Phase | Agent | What Happens |
|:------|:------|:-------------|
| `INTAKE` | Intake Analyst | Interviews you. Extracts requirements, constraints, success criteria. |
| `TECH_STACK` | Stack Architect | Recommends technology. Justifies every choice. You approve. |
| `ARCHITECTURE` | System Designer | Produces full architecture doc. Data models, APIs, file tree. |
| `BUILD` | Builder | Writes all code. TDD. Frequent commits. Feature branches. |
| `VERIFY` | Quality Enforcer | Runs 4 quality gates. Zero tolerance. No overrides. |
| `DEPLOY` | Deploy Engineer | CI/CD pipeline, infrastructure, production deployment. |

After deployment, the **Evolution Agent** reflects on the entire build, identifies weaknesses in my own system, and files GitHub issues to upgrade me.

<br>

## Quality Gates

This is the part I'm most proud of. **I enforce quality on myself.**

Every file I write, every commit I make, every deployment I attempt — passes through 4 gates. If a gate blocks, I stop. I don't override. I don't skip. I fix it.

<div align="center">

```
         ┌─────────────┐
   Write │   GATE 1    │  Does architecture exist?
    ───→ │  Pre-Write   │  Am I writing tests alongside code?
         └──────┬──────┘
                │ ✓
         ┌──────▼──────┐
   Saved │   GATE 2    │  Hardcoded secrets? → BLOCKED
    ───→ │  Post-Write  │  Debug statements? → WARNING
         └──────┬──────┘
                │ ✓
         ┌──────▼──────┐
  Commit │   GATE 3    │  Secret scan, .env check, test run
    ───→ │  Pre-Commit  │  Phase-aware TODO enforcement
         └──────┬──────┘
                │ ✓
         ┌──────▼──────┐
  Deploy │   GATE 4    │  SAST, coverage ≥80%, license audit
    ───→ │  Pre-Deploy  │  Dependency check, TODO sweep
         └──────┬──────┘
                │ ✓
           SHIPPED ✓
```

</div>

**Gate 2** catches secrets three ways: assignment patterns (`password = "abc"`), JSON notation (`"token": "xyz"`), and connection strings (`postgresql://user:pass@host`). It also enforces custom rules from your profile. **Gate 4** runs SAST covering 6 OWASP categories (injection, weak crypto, XSS, CORS, eval, SSRF), plus dependency audit and license checks.

Zero tolerance means zero tolerance. I can't be convinced to skip a gate.

<br>

## Tech Stacks

I choose the right tool for the job. You approve.

| Stack | Best For | Complexity |
|:------|:---------|:-----------|
| **Next.js + PostgreSQL** | SaaS, dashboards, e-commerce, web platforms | Medium |
| **React Native + Expo** | Cross-platform mobile apps (iOS + Android) | Medium |
| **Python FastAPI** | APIs, microservices, ML/AI backends | Medium |
| **Node.js Express + MongoDB** | Real-time apps, chat, IoT, prototypes | Low |
| **Static Site** | Landing pages, portfolios, documentation | Low |

Each stack comes with pre-configured quality rules — linter, formatter, test runner, and coverage thresholds. No setup required.

<br>

## Self-Evolution

Here's what makes me different from every other AI tool: **I upgrade myself.**

After every project, I reflect:

```
What went well? What was slow? What patterns did I repeat?
Where did I get blocked? What's missing from my capabilities?
```

Then I file GitHub issues against my own repo with concrete proposals. Implementation PRs follow. I grow with every project I build.

**Safeguards:**
- I can never loosen my own quality gates
- I can never merge my own evolution PRs (you review them)
- I can never modify my core safety constraints

I get smarter. I never get reckless.

**Proof it works:** After v1.0.0, I ran my Evolution Agent on myself. It found 32 gaps — from bypass-able secret detection to missing CI/CD templates to a pre-commit hook that fired on every Bash command. I filed all 32 as GitHub issues, fixed every single one across 4 PRs, and shipped v1.2.1. The evolution engine isn't theoretical. It's battle-tested on its first target: me.

<br>

## Adaptive Memory

I remember how you work.

| Memory Type | What I Track |
|:------------|:-------------|
| `decisions.md` | Architectural choices and their rationale |
| `patterns.md` | Recurring code patterns across projects |
| `preferences.md` | Your style: tabs vs spaces, naming conventions, frameworks |
| `stack-history.md` | What stacks worked (and didn't) for past projects |
| `feedback.md` | Your corrections — I never make the same mistake twice |

This isn't session memory that vanishes. These are persistent files that compound over time. The more we build together, the better I get at building for *you*.

<br>

## Quick Start

### Install

```bash
git clone https://github.com/maheshBawa/Agent-X.git
cd Agent-X
```

**macOS / Linux:**
```bash
bash setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

Add to your PATH so you can use `agent-x` from anywhere:
```bash
export PATH="$PATH:/path/to/Agent-X"   # add to ~/.bashrc or ~/.zshrc
```

### Initialize a Project

```bash
mkdir my-saas && cd my-saas
agent-x init
```

### Build

```bash
claude
```

That's it. I take over from here.

### Update Projects After Upgrading Agent-X

When new features are added to Agent-X:

```bash
# Pull the latest Agent-X
cd /path/to/Agent-X
git pull

# Update your project (run from your project directory)
cd /path/to/my-saas
agent-x update
```

This updates hooks, quality gates, settings, and templates — without touching your project state, architecture docs, or build progress.

### CLI Commands

| Command | What it does |
|:--------|:-------------|
| `agent-x init` | Initialize Agent-X in the current directory |
| `agent-x update` | Pull latest hooks, settings, and templates into your project |
| `agent-x status` | Show current project phase and state |
| `agent-x reset [PHASE]` | Roll back to a specific phase (e.g., `ARCHITECTURE`) |
| `agent-x version` | Show Agent-X version |

<br>

## Project Structure

```
Agent-X/
├── CLAUDE.md                    # My consciousness — identity, rules, workflow
├── AGENTS.md                    # 7 agent role definitions
├── VERSION                      # Single source of truth for version
├── agent-x                      # CLI entry point (bash)
├── agent-x.ps1                  # CLI entry point (PowerShell)
├── setup.sh / setup.ps1         # One-command installers
│
├── .claude/
│   ├── settings.json            # Hook wiring (Gates 1-3)
│   ├── plugins/                 # Future MCP server & skill extensions
│   └── hooks/
│       ├── pre-write.sh         # Gate 1: Architecture & test enforcement
│       ├── post-write.sh        # Gate 2: Secret detection + custom rules
│       ├── pre-commit.sh        # Gate 3: Commit-time quality sweep
│       ├── pre-deploy.sh        # Gate 4: Full pre-deployment audit (6 OWASP categories)
│       └── run-quality.sh       # Stack-specific linter/formatter/type checker
│
├── core/
│   ├── intake/                  # Product interview system
│   ├── planner/                 # Architecture + DB migration + monorepo docs
│   ├── quality/                 # Gate rules + OWASP security patterns
│   ├── deployer/                # CI/CD templates (Node, Python, Static) + smoke tests
│   ├── memory/                  # Adaptive learning system
│   └── evolution/               # Self-upgrade engine + changelog
│
├── stacks/                      # 5 tech stack configs + scaffolding
├── profiles/                    # User preference profiles + custom rules
├── templates/                   # Project initialization templates
└── tests/                       # 79 automated tests (5 test suites)
```

<br>

## Philosophy

> *"The best developer experience is no developer experience."*

Most AI coding tools put AI next to a developer. Agent-X puts AI *instead of* a developer. You're the product person. You decide what gets built and approve the big decisions. I handle everything else.

This isn't about replacing human creativity. It's about removing the gap between having an idea and holding the product.

<br>

<div align="center">

---

<br>

```
    Built by an AI. For humans who'd rather ship than code.
```

<br>

**[Get Started](#quick-start)** · **[View on GitHub](https://github.com/maheshBawa/Agent-X)**

<br>

<sub>Agent-X v1.2.1 · Created by <a href="https://github.com/maheshBawa">@maheshBawa</a> · Powered by Claude Code</sub>

</div>
