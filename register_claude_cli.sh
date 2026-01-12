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
echo -e "${BLUE}  Claude Code CLI - Global MCP Registration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if claude command exists
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Error: 'claude' command not found.${NC}"
    echo -e "${YELLOW}Please install Claude Code CLI first.${NC}"
    echo -e "${BLUE}Visit: https://github.com/anthropics/claude-code${NC}"
    exit 1
fi

# Register MCP server globally
echo -e "${YELLOW}Registering discord-alert MCP server globally...${NC}"
echo -e "${BLUE}ℹ️  This will make the MCP server available in ALL projects${NC}"
echo ""

# Remove existing registration if any (check both user and local scopes)
claude mcp remove discord-alert 2>/dev/null || true

# Register the server globally with --scope user and absolute path
echo -e "${BLUE}Project location: $SCRIPT_DIR${NC}"
claude mcp add --scope user discord-alert -- bash -c "cd \"$SCRIPT_DIR\" && poetry run python -m discord_mcp_alert.server"

echo ""
echo -e "${GREEN}✅ Successfully registered globally!${NC}"
echo ""
echo -e "${YELLOW}📍 Registration details:${NC}"
echo -e "  • Scope: ${GREEN}user (global)${NC}"
echo -e "  • Name: discord-alert"
echo -e "  • Location: $SCRIPT_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Verify registration: ${BLUE}claude mcp list${NC}"
echo -e "  2. ${GREEN}Use 'notify_discord' tool in ANY project!${NC}"
echo ""
