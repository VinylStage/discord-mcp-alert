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

# Resolve the exact Python executable inside the Poetry virtualenv.
# Using the direct path prevents Claude Code from picking a different Python
# version and creating a new empty virtualenv (which would lack 'mcp' etc.).
echo -e "${YELLOW}Resolving Poetry virtualenv Python path...${NC}"
VENV_PYTHON=$(cd "$SCRIPT_DIR" && poetry env info --executable 2>/dev/null || true)

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    # Fallback: build path from venv root
    VENV_PATH=$(cd "$SCRIPT_DIR" && poetry env info --path 2>/dev/null || true)
    VENV_PYTHON="$VENV_PATH/bin/python"
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    echo -e "${RED}❌ Could not find Poetry virtualenv Python.${NC}"
    echo -e "${YELLOW}Run 'poetry install' inside $SCRIPT_DIR first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Using Python: $VENV_PYTHON${NC}"
echo ""

# Remove existing registration if any
claude mcp remove discord-alert 2>/dev/null || true

# Register with the direct venv Python path
echo -e "${BLUE}Project location: $SCRIPT_DIR${NC}"
claude mcp add --scope user discord-alert \
    -e "PYTHONPATH=$SCRIPT_DIR/src" \
    -- "$VENV_PYTHON" -m discord_mcp_alert.server

echo ""
echo -e "${GREEN}✅ Successfully registered globally!${NC}"
echo ""
echo -e "${YELLOW}📍 Registration details:${NC}"
echo -e "  • Scope:      ${GREEN}user (global)${NC}"
echo -e "  • Name:       discord-alert"
echo -e "  • Python:     $VENV_PYTHON"
echo -e "  • Location:   $SCRIPT_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Verify registration: ${BLUE}claude mcp list${NC}"
echo -e "  2. ${GREEN}Use 'notify_discord' tool in ANY project!${NC}"
echo ""
