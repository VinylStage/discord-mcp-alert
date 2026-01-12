#!/bin/bash
# Mac and Linux only
# This script automatically detects the project directory and runs the MCP server

set -e  # Exit on error

# Get script directory and change to it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Poetry installation
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}❌ Error: Poetry is not installed.${NC}" >&2
    echo -e "${YELLOW}Please run ./setup.sh first or install Poetry manually.${NC}" >&2
    exit 1
fi

# Check .env file
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env file not found.${NC}" >&2
    echo -e "${YELLOW}Please run ./setup.sh first to configure the environment.${NC}" >&2
    exit 1
fi

# Check if dependencies are installed
if ! poetry run python -c "import discord_mcp_alert" &> /dev/null; then
    echo -e "${RED}❌ Error: Dependencies not installed.${NC}" >&2
    echo -e "${YELLOW}Please run ./setup.sh or 'poetry install' first.${NC}" >&2
    exit 1
fi

# Run the server
exec poetry run python -m discord_mcp_alert.server
