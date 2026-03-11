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

[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge&logo=semver)](https://github.com/maheshBawa/Agent-X/releases/tag/v1.0.0)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-brightgreen?style=for-the-badge&logo=windows-terminal)](/)
[![Claude Code](https://img.shields.io/badge/powered%20by-Claude%20Code-blueviolet?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiLz48L3N2Zz4=)](https://claude.ai)
[![Tests](https://img.shields.io/badge/tests-56%20passing-success?style=for-the-badge&logo=checkmarx)](/)
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

**Gate 2** catches secrets like `password = "abc123"` before they ever reach a commit. **Gate 4** runs a full security audit (OWASP Top 10 patterns) before anything touches production.

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

<br>

## Project Structure

```
Agent-X/
├── CLAUDE.md                    # My consciousness — identity, rules, workflow
├── AGENTS.md                    # 7 agent role definitions
├── agent-x                      # CLI entry point (bash)
├── agent-x.ps1                  # CLI entry point (PowerShell)
├── setup.sh / setup.ps1         # One-command installers
│
├── .claude/
│   ├── settings.json            # Hook wiring (Gates 1-3)
│   └── hooks/
│       ├── pre-write.sh         # Gate 1: Architecture & test enforcement
│       ├── post-write.sh        # Gate 2: Secret & debug detection
│       ├── pre-commit.sh        # Gate 3: Commit-time quality sweep
│       └── pre-deploy.sh        # Gate 4: Full pre-deployment audit
│
├── core/
│   ├── intake/                  # Product interview system
│   ├── planner/                 # Architecture document templates
│   ├── quality/                 # Gate rules + OWASP security patterns
│   ├── deployer/                # CI/CD & deployment workflows
│   ├── memory/                  # Adaptive learning system
│   └── evolution/               # Self-upgrade engine
│
├── stacks/                      # 5 tech stack configs + scaffolding
├── profiles/                    # User preference profiles
├── templates/                   # Project initialization templates
└── tests/                       # 56 automated tests
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

<sub>Agent-X v1.0.0 · Created by <a href="https://github.com/maheshBawa">@maheshBawa</a> · Powered by Claude Code</sub>

</div>
