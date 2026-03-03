#!/bin/bash
# Discord MCP Alert - One-Click Setup Script
# Mac and Linux only
# This script automatically sets up the entire environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Discord MCP Alert - Setup Wizard${NC}"
echo -e "${BLUE}  Mac and Linux only${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Check Poetry installation
echo -e "${YELLOW}[1/6]${NC} Checking Poetry installation..."
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}❌ Poetry is not installed.${NC}"
    echo -e "${YELLOW}Please install Poetry first:${NC}"
    echo -e "  curl -sSL https://install.python-poetry.org | python3 -"
    echo -e "  or visit: https://python-poetry.org/docs/#installation"
    exit 1
fi
echo -e "${GREEN}✅ Poetry found: $(poetry --version)${NC}"
echo ""

# Step 2: Check Python version
echo -e "${YELLOW}[2/6]${NC} Checking Python version..."
PYTHON_VERSION=$(poetry run python --version 2>&1 || python3 --version)
echo -e "${GREEN}✅ Python version: ${PYTHON_VERSION}${NC}"
echo ""

# Step 3: Install dependencies
echo -e "${YELLOW}[3/6]${NC} Installing dependencies..."
poetry install
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 4: Setup .env file
echo -e "${YELLOW}[4/6]${NC} Setting up environment configuration..."
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file already exists.${NC}"
    read -p "Do you want to reconfigure it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ️  Skipping .env configuration${NC}"
    else
        SETUP_ENV=true
    fi
else
    SETUP_ENV=true
fi

if [ "$SETUP_ENV" = true ]; then
    echo -e "${BLUE}Please enter your Discord Webhook URL:${NC}"
    echo -e "${BLUE}(You can get this from Discord: Server Settings > Integrations > Webhooks)${NC}"
    read -p "Webhook URL: " WEBHOOK_URL

    if [ -z "$WEBHOOK_URL" ]; then
        echo -e "${RED}❌ Webhook URL cannot be empty${NC}"
        exit 1
    fi

    echo "DISCORD_WEBHOOK_URL=$WEBHOOK_URL" > .env
    echo -e "${GREEN}✅ .env file created${NC}"
fi
echo ""

# Step 5: Test notification
echo -e "${YELLOW}[5/6]${NC} Testing Discord notification..."
if poetry run python -m discord_mcp_alert.main; then
    echo -e "${GREEN}✅ Test notification sent successfully!${NC}"
    echo -e "${GREEN}   Check your Discord channel for the message.${NC}"
else
    echo -e "${RED}❌ Failed to send test notification${NC}"
    echo -e "${YELLOW}Please check your webhook URL in .env file${NC}"
    exit 1
fi
echo ""

# Step 6: Register MCP server
echo -e "${YELLOW}[6/6]${NC} Registering MCP server..."
echo ""

# Register to Claude Desktop
echo -e "${BLUE}📱 Registering to Claude Desktop...${NC}"
poetry run python scripts/register_mcp.py
echo ""

# Auto-register Claude Code CLI (globally)
echo -e "${BLUE}🖥️  Registering to Claude Code CLI (globally)...${NC}"
if command -v claude &> /dev/null; then
    claude mcp remove discord-alert 2>/dev/null || true
    claude mcp add --scope user discord-alert -- poetry --directory "$SCRIPT_DIR" run python -m discord_mcp_alert.server
    echo -e "${GREEN}✅ Claude Code CLI registration complete!${NC}"
    echo -e "${BLUE}ℹ️  'notify_discord' tool is now available in ALL projects!${NC}"
else
    echo -e "${YELLOW}⚠️  'claude' command not found. Skipping CLI registration.${NC}"
    echo -e "${BLUE}   Install Claude Code, then run: ${GREEN}./register_claude_cli.sh${NC}"
fi
echo ""

# Final summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Restart Claude Desktop if it's running"
echo -e "  2. ${GREEN}Use 'notify_discord' tool in ANY project!${NC}"
echo ""
echo -e "${YELLOW}Quick commands:${NC}"
echo -e "  • Run server manually: ${BLUE}./run_server.sh${NC}"
echo -e "  • Send test notification: ${BLUE}poetry run python -m discord_mcp_alert.main${NC}"
echo -e "  • Verify MCP: ${BLUE}poetry run python tests/verify_mcp.py${NC}"
echo ""
