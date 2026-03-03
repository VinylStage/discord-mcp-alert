# Discord MCP Alert - One-Click Setup Script for Windows
# Requires PowerShell 5.1 or later
# Run with: powershell -ExecutionPolicy Bypass -File setup.ps1

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  Discord MCP Alert - Setup Wizard" -ForegroundColor Blue
Write-Host "  Windows (PowerShell)" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# Step 1: Check Poetry installation
Write-Host "[1/6] Checking Poetry installation..." -ForegroundColor Yellow
if (-not (Get-Command poetry -ErrorAction SilentlyContinue)) {
    Write-Host "X Poetry is not installed." -ForegroundColor Red
    Write-Host "Please install Poetry first:" -ForegroundColor Yellow
    Write-Host "  (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -"
    Write-Host "  or visit: https://python-poetry.org/docs/#installation"
    exit 1
}
$poetryVersion = poetry --version
Write-Host "OK Poetry found: $poetryVersion" -ForegroundColor Green
Write-Host ""

# Step 2: Check Python version
Write-Host "[2/6] Checking Python version..." -ForegroundColor Yellow
Set-Location $SCRIPT_DIR
$pythonVersion = poetry run python --version 2>&1
Write-Host "OK Python version: $pythonVersion" -ForegroundColor Green
Write-Host ""

# Step 3: Install dependencies
Write-Host "[3/6] Installing dependencies..." -ForegroundColor Yellow
poetry install
Write-Host "OK Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 4: Setup .env file
Write-Host "[4/6] Setting up environment configuration..." -ForegroundColor Yellow
$setupEnv = $false
$envPath = Join-Path $SCRIPT_DIR ".env"

if (Test-Path $envPath) {
    Write-Host "WARNING: .env file already exists." -ForegroundColor Yellow
    $answer = Read-Host "Do you want to reconfigure it? (y/N)"
    if ($answer -match "^[Yy]$") {
        $setupEnv = $true
    } else {
        Write-Host "INFO: Skipping .env configuration" -ForegroundColor Blue
    }
} else {
    $setupEnv = $true
}

if ($setupEnv) {
    Write-Host "Please enter your Discord Webhook URL:" -ForegroundColor Blue
    Write-Host "(You can get this from Discord: Server Settings > Integrations > Webhooks)" -ForegroundColor Blue
    $webhookUrl = Read-Host "Webhook URL"

    if ([string]::IsNullOrWhiteSpace($webhookUrl)) {
        Write-Host "X Webhook URL cannot be empty" -ForegroundColor Red
        exit 1
    }

    "DISCORD_WEBHOOK_URL=$webhookUrl" | Set-Content -Path $envPath -Encoding UTF8
    Write-Host "OK .env file created" -ForegroundColor Green
}
Write-Host ""

# Step 5: Test notification
Write-Host "[5/6] Testing Discord notification..." -ForegroundColor Yellow
try {
    poetry run python -m discord_mcp_alert.main
    Write-Host "OK Test notification sent successfully!" -ForegroundColor Green
    Write-Host "   Check your Discord channel for the message." -ForegroundColor Green
} catch {
    Write-Host "X Failed to send test notification" -ForegroundColor Red
    Write-Host "Please check your webhook URL in .env file" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 6: Register MCP server
Write-Host "[6/6] Registering MCP server..." -ForegroundColor Yellow
Write-Host ""

# 6a: Register to Claude Desktop
Write-Host "Registering to Claude Desktop..." -ForegroundColor Blue
poetry run python scripts/register_mcp.py
Write-Host ""

# 6b: Register to Claude Code CLI (auto)
Write-Host "Registering to Claude Code CLI (globally)..." -ForegroundColor Blue
if (Get-Command claude -ErrorAction SilentlyContinue) {
    claude mcp remove discord-alert 2>$null
    claude mcp add --scope user discord-alert -- poetry --directory "$SCRIPT_DIR" run python -m discord_mcp_alert.server
    Write-Host "OK Claude Code CLI registration complete!" -ForegroundColor Green
    Write-Host "INFO: 'notify_discord' tool is now available in ALL projects!" -ForegroundColor Blue
} else {
    Write-Host "WARNING: 'claude' command not found. Skipping CLI registration." -ForegroundColor Yellow
    Write-Host "   Install Claude Code, then run: .\register_claude_cli.ps1" -ForegroundColor Blue
}
Write-Host ""

# Final summary
Write-Host "========================================" -ForegroundColor Blue
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Claude Desktop if it's running"
Write-Host "  2. Use 'notify_discord' tool in ANY Claude project!"  -ForegroundColor Green
Write-Host ""
Write-Host "Quick commands:" -ForegroundColor Yellow
Write-Host "  - Run server manually: " -NoNewline
Write-Host ".\run_server.ps1" -ForegroundColor Blue
Write-Host "  - Send test notification: " -NoNewline
Write-Host "poetry run python -m discord_mcp_alert.main" -ForegroundColor Blue
Write-Host "  - Verify MCP: " -NoNewline
Write-Host "poetry run python tests/verify_mcp.py" -ForegroundColor Blue
Write-Host ""
