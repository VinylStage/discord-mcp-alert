#!/bin/bash
# Discord MCP Alert - Claude Code CLI Registration Script
# Mac and Linux only

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Claude Code CLI - MCP Registration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if claude command exists
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Error: 'claude' command not found.${NC}"
    echo -e "${YELLOW}Please install Claude Code CLI first.${NC}"
    echo -e "${BLUE}Visit: https://github.com/anthropics/claude-code${NC}"
    exit 1
fi

# Register MCP server
echo -e "${YELLOW}Registering discord-alert MCP server...${NC}"
echo ""

# Remove existing registration if any
claude mcp remove discord-alert 2>/dev/null || true

# Register the server with bash -c to ensure proper working directory
claude mcp add discord-alert -- bash -c "cd \"$SCRIPT_DIR\" && poetry run python -m discord_mcp_alert.server"

echo ""
echo -e "${GREEN}✅ Successfully registered!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Verify registration: ${BLUE}claude mcp list${NC}"
echo -e "  2. Start using the 'notify_discord' tool in Claude Code CLI"
echo ""
