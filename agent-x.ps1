# Agent-X CLI for Windows
# Usage: agent-x <command> [args]
param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

$AgentXHome = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Get-Location

switch ($Command) {
    "init" {
        Write-Host "Initializing Agent-X in: $ProjectDir"

        # Create .agent-x directory
        New-Item -ItemType Directory -Path "$ProjectDir\.agent-x" -Force | Out-Null

        # Copy project state template
        Copy-Item "$AgentXHome\templates\project-state.json" "$ProjectDir\.agent-x\project-state.json"

        # Update state
        $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $projectName = Split-Path -Leaf $ProjectDir
        $state = Get-Content "$ProjectDir\.agent-x\project-state.json" | ConvertFrom-Json
        $state.project_name = $projectName
        $state.agent_x_home = $AgentXHome.Replace('\', '/')
        $state.created_at = $timestamp
        $state.updated_at = $timestamp
        $state | ConvertTo-Json -Depth 3 | Set-Content "$ProjectDir\.agent-x\project-state.json"

        # Copy CLAUDE.md template (back up existing if present)
        if (Test-Path "$ProjectDir\CLAUDE.md") {
            Copy-Item "$ProjectDir\CLAUDE.md" "$ProjectDir\CLAUDE.md.backup"
            Write-Host "  Existing CLAUDE.md backed up to CLAUDE.md.backup"
        }
        $claudeContent = Get-Content "$AgentXHome\templates\project-claude.md" -Raw
        $claudeContent = $claudeContent.Replace('{{AGENT_X_HOME}}', $AgentXHome.Replace('\', '/'))
        Set-Content "$ProjectDir\CLAUDE.md" $claudeContent

        # Copy AGENTS.md template (back up existing if present)
        if (Test-Path "$ProjectDir\AGENTS.md") {
            Copy-Item "$ProjectDir\AGENTS.md" "$ProjectDir\AGENTS.md.backup"
            Write-Host "  Existing AGENTS.md backed up to AGENTS.md.backup"
        }
        $agentsContent = Get-Content "$AgentXHome\templates\project-agents.md" -Raw
        $agentsContent = $agentsContent.Replace('{{AGENT_X_HOME}}', $AgentXHome.Replace('\', '/'))
        Set-Content "$ProjectDir\AGENTS.md" $agentsContent

        # Copy hooks
        New-Item -ItemType Directory -Path "$ProjectDir\.claude\hooks" -Force | Out-Null
        Copy-Item "$AgentXHome\.claude\hooks\*" "$ProjectDir\.claude\hooks\" -Force
        Copy-Item "$AgentXHome\.claude\settings.json" "$ProjectDir\.claude\settings.json" -Force

        # Initialize git if needed
        if (-not (Test-Path "$ProjectDir\.git")) {
            git init
        }

        # Create .gitignore
        if (-not (Test-Path "$ProjectDir\.gitignore")) {
            @"
.env
.env.local
.env.*.local
node_modules/
venv/
__pycache__/
.next/
dist/
build/
.vscode/
.idea/
.DS_Store
Thumbs.db
.agent-x/security-exceptions.md
"@ | Set-Content "$ProjectDir\.gitignore"
        }

        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  Agent-X initialized: $projectName" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Run 'claude' to start. Agent-X will take over."
    }

    "update" {
        # Update hooks, settings, and templates from Agent-X home — preserves project state
        if (-not (Test-Path "$ProjectDir\.agent-x")) {
            Write-Host "No Agent-X project found. Run 'agent-x init' first."
            exit 1
        }

        $Version = Get-Content "$AgentXHome\VERSION" -ErrorAction SilentlyContinue
        if (-not $Version) { $Version = "unknown" }
        Write-Host "Updating project to Agent-X v$($Version.Trim())..."

        # Update hooks
        New-Item -ItemType Directory -Path "$ProjectDir\.claude\hooks" -Force | Out-Null
        Copy-Item "$AgentXHome\.claude\hooks\*" "$ProjectDir\.claude\hooks\" -Force
        Write-Host "  ✓ Hooks updated" -ForegroundColor Green

        # Update settings
        Copy-Item "$AgentXHome\.claude\settings.json" "$ProjectDir\.claude\settings.json" -Force
        Write-Host "  ✓ Settings updated" -ForegroundColor Green

        # Update CLAUDE.md (back up existing)
        if (Test-Path "$ProjectDir\CLAUDE.md") {
            Copy-Item "$ProjectDir\CLAUDE.md" "$ProjectDir\CLAUDE.md.backup"
        }
        $claudeContent = Get-Content "$AgentXHome\templates\project-claude.md" -Raw
        $claudeContent = $claudeContent.Replace('{{AGENT_X_HOME}}', $AgentXHome.Replace('\', '/'))
        Set-Content "$ProjectDir\CLAUDE.md" $claudeContent
        Write-Host "  ✓ CLAUDE.md updated (previous backed up)" -ForegroundColor Green

        # Update AGENTS.md (back up existing)
        if (Test-Path "$ProjectDir\AGENTS.md") {
            Copy-Item "$ProjectDir\AGENTS.md" "$ProjectDir\AGENTS.md.backup"
        }
        $agentsContent = Get-Content "$AgentXHome\templates\project-agents.md" -Raw
        $agentsContent = $agentsContent.Replace('{{AGENT_X_HOME}}', $AgentXHome.Replace('\', '/'))
        Set-Content "$ProjectDir\AGENTS.md" $agentsContent
        Write-Host "  ✓ AGENTS.md updated (previous backed up)" -ForegroundColor Green

        # Update agent_x_home in project state
        $stateFile = "$ProjectDir\.agent-x\project-state.json"
        if (Test-Path $stateFile) {
            $state = Get-Content $stateFile | ConvertFrom-Json
            $state.agent_x_home = $AgentXHome.Replace('\', '/')
            $state.updated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            $state | ConvertTo-Json -Depth 3 | Set-Content $stateFile
        }

        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  Agent-X updated to v$($Version.Trim())" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Project state, build progress, and .agent-x/ docs preserved."
    }

    "reset" {
        $stateFile = "$ProjectDir\.agent-x\project-state.json"
        $targetPhase = if ($args.Count -gt 0) { $args[0] } else { "INTAKE" }
        $validPhases = @("INTAKE", "TECH_STACK", "ARCHITECTURE", "BUILD", "VERIFY", "DEPLOY")
        if (-not (Test-Path $stateFile)) {
            Write-Host "No Agent-X project found. Run 'agent-x init' first."
            exit 1
        }
        if ($targetPhase -notin $validPhases) {
            Write-Host "Invalid phase: $targetPhase"
            Write-Host "Valid phases: $($validPhases -join ', ')"
            exit 1
        }
        $state = Get-Content $stateFile | ConvertFrom-Json
        $state.current_phase = $targetPhase
        $state.phase_status = "not_started"
        $state | ConvertTo-Json -Depth 3 | Set-Content $stateFile
        Write-Host "Agent-X reset to phase: $targetPhase"
        Write-Host "Run 'claude' to continue from this phase."
    }

    "status" {
        $stateFile = "$ProjectDir\.agent-x\project-state.json"
        if (Test-Path $stateFile) {
            Write-Host "Agent-X Project Status:"
            Get-Content $stateFile | ConvertFrom-Json | Format-List
        } else {
            Write-Host "No Agent-X project found in current directory."
            Write-Host "Run 'agent-x init' to initialize."
        }
    }

    "version" {
        $Version = Get-Content "$AgentXHome\VERSION" -ErrorAction SilentlyContinue
        if (-not $Version) { $Version = "unknown" }
        Write-Host "Agent-X v$($Version.Trim())"
    }

    default {
        Write-Host "Agent-X — Autonomous AI Development Environment"
        Write-Host ""
        Write-Host "Usage: agent-x <command>"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  init              Initialize Agent-X in the current directory"
        Write-Host "  update            Update hooks, settings, and templates from Agent-X repo"
        Write-Host "  status            Show project status"
        Write-Host "  reset [PHASE]     Reset project to a specific phase (default: INTAKE)"
        Write-Host "  version           Show Agent-X version"
        Write-Host "  help              Show this help message"
        Write-Host ""
        Write-Host "After init, run 'claude' to start building."
    }
}
