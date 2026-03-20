#!/bin/bash
# Discord MCP Alert — Fix Claude Desktop Registration
#
# Run this script once to repair the Claude Desktop MCP config.
# It replaces the broken `poetry run python` command with the direct
# path to the virtualenv Python, which prevents the
# "No module named 'mcp'" error caused by Claude Desktop picking the
# wrong Python version.
#
# Package manager priority: Poetry → uv → pip (system Python)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Discord MCP Alert — Fix Claude Desktop Registration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ---------------------------------------------------------------------------
# Step 1: install dependencies & resolve Python executable
# ---------------------------------------------------------------------------
echo -e "${YELLOW}[1/2]${NC} Resolving Python + installing dependencies..."

BOOTSTRAP_PYTHON=""

# --- Poetry ---
if command -v poetry &> /dev/null; then
    echo -e "   ${BLUE}Poetry found — running 'poetry install'...${NC}"
    poetry install --quiet 2>/dev/null || poetry install

    VENV_PYTHON=$(poetry env info --executable 2>/dev/null || true)
    if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
        VENV_PATH=$(poetry env info --path 2>/dev/null || true)
        VENV_PYTHON="$VENV_PATH/bin/python"
    fi
    if [ -n "$VENV_PYTHON" ] && [ -f "$VENV_PYTHON" ]; then
        echo -e "   ${GREEN}✅ Poetry venv Python: $VENV_PYTHON${NC}"
        BOOTSTRAP_PYTHON="$VENV_PYTHON"
    fi
fi

# --- uv (fallback) ---
if [ -z "$BOOTSTRAP_PYTHON" ] && command -v uv &> /dev/null; then
    echo -e "   ${BLUE}uv found — running 'uv sync'...${NC}"
    uv sync --quiet 2>/dev/null || uv sync
    VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"
    if [ -f "$VENV_PYTHON" ]; then
        echo -e "   ${GREEN}✅ uv venv Python: $VENV_PYTHON${NC}"
        BOOTSTRAP_PYTHON="$VENV_PYTHON"
    fi
fi

# --- pip / system Python (last resort) ---
if [ -z "$BOOTSTRAP_PYTHON" ]; then
    SYSTEM_PYTHON=$(command -v python3 || command -v python || true)
    if [ -n "$SYSTEM_PYTHON" ]; then
        echo -e "   ${YELLOW}No Poetry/uv — trying system Python: $SYSTEM_PYTHON${NC}"
        echo -e "   ${YELLOW}Installing packages with pip...${NC}"
        "$SYSTEM_PYTHON" -m pip install --quiet mcp requests python-dotenv \
            || "$SYSTEM_PYTHON" -m pip install mcp requests python-dotenv
        # Verify mcp is importable
        if "$SYSTEM_PYTHON" -c "import mcp" 2>/dev/null; then
            echo -e "   ${GREEN}✅ System Python with mcp: $SYSTEM_PYTHON${NC}"
            BOOTSTRAP_PYTHON="$SYSTEM_PYTHON"
        fi
    fi
fi

if [ -z "$BOOTSTRAP_PYTHON" ]; then
    echo -e "${RED}❌ Could not find a Python with 'mcp' installed.${NC}"
    echo -e "${YELLOW}Install one of: Poetry, uv, or run:${NC}"
    echo -e "   pip install mcp requests python-dotenv"
    exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# Step 2: run register_mcp.py with the resolved Python
# ---------------------------------------------------------------------------
echo -e "${YELLOW}[2/2]${NC} Updating Claude Desktop config..."
"$BOOTSTRAP_PYTHON" "$SCRIPT_DIR/scripts/register_mcp.py"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Done! Please QUIT and RELAUNCH Claude Desktop.${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
