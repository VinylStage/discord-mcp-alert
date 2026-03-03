# Discord MCP Alert - Claude Code CLI Registration Script for Windows
# Requires PowerShell 5.1 or later
# Run with: powershell -ExecutionPolicy Bypass -File register_claude_cli.ps1

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  Claude Code CLI - Global MCP Registration" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# Check if claude command exists
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "X Error: 'claude' command not found." -ForegroundColor Red
    Write-Host "Please install Claude Code CLI first." -ForegroundColor Yellow
    Write-Host "Visit: https://github.com/anthropics/claude-code" -ForegroundColor Blue
    exit 1
}

# Register MCP server globally
Write-Host "Registering discord-alert MCP server globally..." -ForegroundColor Yellow
Write-Host "INFO: This will make the MCP server available in ALL projects" -ForegroundColor Blue
Write-Host ""

# Remove existing registration if any
claude mcp remove discord-alert 2>$null
if ($LASTEXITCODE -ne 0) {
    # Ignore error if not registered
}

# Register the server globally with --scope user and poetry --directory
Write-Host "Project location: $SCRIPT_DIR" -ForegroundColor Blue
claude mcp add --scope user discord-alert -- poetry --directory "$SCRIPT_DIR" run python -m discord_mcp_alert.server

Write-Host ""
Write-Host "OK Successfully registered globally!" -ForegroundColor Green
Write-Host ""
Write-Host "Registration details:" -ForegroundColor Yellow
Write-Host "  - Scope: user (global)" -ForegroundColor Green
Write-Host "  - Name: discord-alert"
Write-Host "  - Location: $SCRIPT_DIR"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Verify registration: " -NoNewline
Write-Host "claude mcp list" -ForegroundColor Blue
Write-Host "  2. Use 'notify_discord' tool in ANY project!" -ForegroundColor Green
Write-Host ""
