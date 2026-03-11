# Agent-X Setup Script
# One-command installer for Windows
$ErrorActionPreference = "Stop"

$AgentXHome = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProfileFile = Join-Path $AgentXHome "profiles\default.json"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  AGENT-X SETUP" -ForegroundColor Cyan
Write-Host "  Autonomous AI Development Environment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ Claude Code found" -ForegroundColor Green
} else {
    Write-Host "ERROR: Claude Code is not installed." -ForegroundColor Red
    Write-Host "Install it from: https://claude.ai/code"
    exit 1
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ git found" -ForegroundColor Green
} else {
    Write-Host "ERROR: git is not installed." -ForegroundColor Red
    exit 1
}

if (Get-Command bash -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ bash found (required for quality hooks)" -ForegroundColor Green
} else {
    Write-Host "WARNING: bash not found. Quality gate hooks require bash (Git Bash or WSL)." -ForegroundColor Yellow
    Write-Host "  Install Git for Windows (includes Git Bash) to enable quality gates."
}

if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "  ✓ Node.js found ($nodeVersion)" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Node.js not found (needed for JavaScript/TypeScript stacks)" -ForegroundColor Yellow
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyVersion = python --version
    Write-Host "  ✓ Python found ($pyVersion)" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Python not found (needed for Python stacks)" -ForegroundColor Yellow
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ GitHub CLI found" -ForegroundColor Green
} else {
    Write-Host "  ⚠ GitHub CLI (gh) not found (needed for evolution engine)" -ForegroundColor Yellow
    Write-Host "    Install from: https://cli.github.com/"
}

Write-Host ""

# Step 2: Initialize git if needed
Write-Host "[2/5] Setting up repository..." -ForegroundColor Yellow
if (-not (Test-Path (Join-Path $AgentXHome ".git"))) {
    Set-Location $AgentXHome
    git init
    Write-Host "  ✓ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "  ✓ Git repository exists" -ForegroundColor Green
}

# Step 3: Configure hooks
Write-Host "[3/5] Configuring quality gates..." -ForegroundColor Yellow
$hooksDir = Join-Path $AgentXHome ".claude\hooks"
if (Test-Path $hooksDir) {
    Write-Host "  ✓ Quality gate hooks configured" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Hooks directory not found" -ForegroundColor Yellow
}

# Step 4: Create user profile
Write-Host "[4/5] Setting up profile..." -ForegroundColor Yellow
if (Test-Path $ProfileFile) {
    $profile = Get-Content $ProfileFile | ConvertFrom-Json
    if ([string]::IsNullOrEmpty($profile.name)) {
        Write-Host "  First-time setup detected. Let's configure your profile."
        Write-Host ""
        $userName = Read-Host "  Your name"
        $userLangs = Read-Host "  Preferred languages (comma-separated, e.g., TypeScript,Python)"
        $userTaste = Read-Host "  Design taste (e.g., minimal, modern, corporate)"

        $langsArray = $userLangs -split "," | ForEach-Object { $_.Trim() }
        $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

        $newProfile = @{
            version = "1.0.0"
            name = $userName
            preferred_languages = $langsArray
            design_taste = $userTaste
            communication_style = "concise, technical"
            risk_tolerance = "low"
            default_cloud = $null
            auto_deploy = $false
            custom_rules = @()
            created_at = $timestamp
            updated_at = $timestamp
        }

        $newProfile | ConvertTo-Json -Depth 3 | Set-Content $ProfileFile
        Write-Host "  ✓ Profile created" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Profile exists (welcome back, $($profile.name))" -ForegroundColor Green
    }
}

# Step 5: CLI setup
Write-Host "[5/5] Setting up CLI..." -ForegroundColor Yellow
Write-Host "  ✓ CLI ready" -ForegroundColor Green
Write-Host "  To use globally, add to PATH:" -ForegroundColor Gray
Write-Host "    `$env:PATH += `";$AgentXHome`"" -ForegroundColor Gray

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Agent-X online. Ready to build." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:"
Write-Host "  cd your-project-dir"
Write-Host "  $AgentXHome\agent-x init"
Write-Host "  claude"
Write-Host ""
