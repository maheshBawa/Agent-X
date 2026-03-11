# Project Agent Roles

This project uses Agent-X agent roles. Full role definitions are in:
{{AGENT_X_HOME}}/AGENTS.md

## Current Phase
Check `.agent-x/project-state.json` for the active phase and corresponding agent role.

## Phase → Agent Mapping
| Phase | Agent | Reference |
|-------|-------|-----------|
| INTAKE | Intake Analyst | {{AGENT_X_HOME}}/AGENTS.md |
| TECH_STACK | Stack Architect | {{AGENT_X_HOME}}/AGENTS.md |
| ARCHITECTURE | System Designer | {{AGENT_X_HOME}}/AGENTS.md |
| BUILD | Builder | {{AGENT_X_HOME}}/AGENTS.md |
| VERIFY | Quality Enforcer | {{AGENT_X_HOME}}/AGENTS.md |
| DEPLOY | Deploy Engineer | {{AGENT_X_HOME}}/AGENTS.md |

## Autonomous Loop Integration
All agents gain autonomous mode capabilities during their active phase.
Full protocol: {{AGENT_X_HOME}}/core/autonomy/loop.md
Checkpoint rules: {{AGENT_X_HOME}}/core/autonomy/checkpoints.md
