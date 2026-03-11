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

        # Copy CLAUDE.md template
        $claudeContent = Get-Content "$AgentXHome\templates\project-claude.md" -Raw
        $claudeContent = $claudeContent.Replace('{{AGENT_X_HOME}}', $AgentXHome.Replace('\', '/'))
        Set-Content "$ProjectDir\CLAUDE.md" $claudeContent

        # Copy AGENTS.md template
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
"@ | Set-Content "$ProjectDir\.gitignore"
        }

        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "  Agent-X initialized: $projectName" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Run 'claude' to start. Agent-X will take over."
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
        Write-Host "Agent-X v1.0.0"
    }

    default {
        Write-Host "Agent-X — Autonomous AI Development Environment"
        Write-Host ""
        Write-Host "Usage: agent-x <command>"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  init      Initialize Agent-X in the current directory"
        Write-Host "  status    Show project status"
        Write-Host "  version   Show Agent-X version"
        Write-Host "  help      Show this help message"
        Write-Host ""
        Write-Host "After init, run 'claude' to start building."
    }
}
