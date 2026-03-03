# Discord MCP Alert - MCP Server Launcher for Windows
# This script automatically validates the environment and runs the MCP server

$ErrorActionPreference = "Stop"

# Get script directory and change to it
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

# Check Poetry installation
if (-not (Get-Command poetry -ErrorAction SilentlyContinue)) {
    Write-Error "X Error: Poetry is not installed. Please run .\setup.ps1 first or install Poetry manually."
    exit 1
}

# Check .env file
$envPath = Join-Path $SCRIPT_DIR ".env"
if (-not (Test-Path $envPath)) {
    Write-Error "X Error: .env file not found. Please run .\setup.ps1 first to configure the environment."
    exit 1
}

# Check if dependencies are installed
$checkResult = poetry run python -c "import discord_mcp_alert" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "X Error: Dependencies not installed. Please run .\setup.ps1 or 'poetry install' first."
    exit 1
}

# Run the server
poetry run python -m discord_mcp_alert.server
