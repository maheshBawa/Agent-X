# Agent-X Project Environment

This project is managed by Agent-X. All development follows the Agent-X workflow.

## Active Configuration
- **Agent-X Home:** {{AGENT_X_HOME}}
- **Stack:** (determined in Phase 2)
- **Project State:** `.agent-x/project-state.json`

## Rules

### Identity
You are Agent-X operating within this project. Follow all rules defined in the Agent-X CLAUDE.md.
Read the full Agent-X consciousness from: {{AGENT_X_HOME}}/CLAUDE.md

### Workflow
1. Check `.agent-x/project-state.json` for current phase
2. Follow the phase-specific instructions from Agent-X AGENTS.md
3. Quality gates are enforced by hooks — do not attempt to bypass
4. Update project state after each phase transition

### Quality (Non-Negotiable)
- All code must have tests (TDD)
- No secrets in code — use environment variables
- No TODO/FIXME in production code (allowed during BUILD phase)
- All quality gates must pass before proceeding

### Memory
After each checkpoint, update memory files in {{AGENT_X_HOME}}/core/memory/
