#!/bin/bash
# Discord MCP Alert — Full Diagnostic Script
# Run this and paste the output if something is still broken.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

sep() { echo -e "${BLUE}─────────────────────────────────────────────${NC}"; }

echo -e "${CYAN}╔═════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Discord MCP Alert — Diagnostics           ║${NC}"
echo -e "${CYAN}╚═════════════════════════════════════════════╝${NC}"
echo ""

# ── 1. Python versions ──────────────────────────────────────────────────────
sep
echo -e "${YELLOW}[1] Python versions on PATH${NC}"
for py in python3 python; do
    if command -v $py &>/dev/null; then
        echo -e "  $py → $(command -v $py)  $(${py} --version 2>&1)"
    fi
done
if command -v pyenv &>/dev/null; then
    echo -e "  pyenv version: $(pyenv version 2>/dev/null || echo 'n/a')"
fi
echo ""

# ── 2. Poetry venv ───────────────────────────────────────────────────────────
sep
echo -e "${YELLOW}[2] Poetry virtualenv${NC}"
if command -v poetry &>/dev/null; then
    cd "$SCRIPT_DIR"
    VENV_EXEC=$(poetry env info --executable 2>/dev/null || echo "NOT FOUND")
    VENV_PATH=$(poetry env info --path     2>/dev/null || echo "NOT FOUND")
    echo -e "  venv path      : $VENV_PATH"
    echo -e "  Python exec    : $VENV_EXEC"
    if [ -f "$VENV_EXEC" ]; then
        echo -e "  Python version : $($VENV_EXEC --version 2>&1)"
        $VENV_EXEC -c "import mcp; print('  mcp importable : YES ✅')" 2>/dev/null \
            || echo -e "  mcp importable : ${RED}NO ❌ — run: poetry install${NC}"
        $VENV_EXEC -c "import requests; print('  requests       : YES ✅')" 2>/dev/null \
            || echo -e "  requests       : ${RED}NO ❌${NC}"
        $VENV_EXEC -c "import dotenv; print('  python-dotenv  : YES ✅')" 2>/dev/null \
            || echo -e "  python-dotenv  : ${RED}NO ❌${NC}"
    else
        echo -e "  ${RED}❌ Executable not found. Run: cd $SCRIPT_DIR && poetry install${NC}"
    fi
else
    echo -e "  ${RED}poetry not found${NC}"
fi
echo ""

# ── 3. Claude Desktop config ─────────────────────────────────────────────────
sep
echo -e "${YELLOW}[3] Claude Desktop config${NC}"
DESKTOP_CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$DESKTOP_CFG" ]; then
    echo -e "  File: $DESKTOP_CFG"
    ENTRY=$(python3 -c "
import json, sys
with open('$DESKTOP_CFG') as f:
    cfg = json.load(f)
entry = cfg.get('mcpServers', {}).get('discord-alert')
if entry:
    print('  command :', entry.get('command','MISSING'))
    print('  args    :', entry.get('args', []))
    env = entry.get('env', {})
    print('  PYTHONPATH:', env.get('PYTHONPATH','(not set)'))
else:
    print('  discord-alert: NOT REGISTERED')
" 2>/dev/null || echo "  Could not parse JSON")
    echo "$ENTRY"
    CMD=$(python3 -c "
import json
with open('$DESKTOP_CFG') as f:
    cfg = json.load(f)
e = cfg.get('mcpServers', {}).get('discord-alert', {})
print(e.get('command',''))
" 2>/dev/null)
    if [ -n "$CMD" ] && [ -f "$CMD" ]; then
        echo -e "  command exists : ${GREEN}YES ✅${NC}"
        $CMD -c "import mcp" 2>/dev/null \
            && echo -e "  mcp importable : ${GREEN}YES ✅${NC}" \
            || echo -e "  mcp importable : ${RED}NO ❌  ← root cause of 'Connection closed'${NC}"
    elif [ -n "$CMD" ]; then
        echo -e "  command exists : ${RED}NO ❌  '$CMD' not found${NC}"
    fi
else
    echo -e "  ${RED}Config file not found: $DESKTOP_CFG${NC}"
fi
echo ""

# ── 4. Claude Code CLI config (~/.claude.json) ───────────────────────────────
sep
echo -e "${YELLOW}[4] Claude Code CLI config (~/.claude.json)${NC}"
CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ]; then
    ENTRY=$(python3 -c "
import json
with open('$CLAUDE_JSON') as f:
    cfg = json.load(f)
servers = cfg.get('mcpServers', {})
entry = servers.get('discord-alert')
if entry:
    print('  command :', entry.get('command','MISSING'))
    print('  args    :', entry.get('args', []))
    env = entry.get('env', {})
    print('  PYTHONPATH:', env.get('PYTHONPATH','(not set)'))
else:
    print('  discord-alert: NOT REGISTERED in ~/.claude.json')
    all_keys = list(servers.keys())
    print('  registered servers:', all_keys)
" 2>/dev/null || echo "  Could not parse ~/.claude.json")
    echo "$ENTRY"
else
    echo -e "  ${YELLOW}~/.claude.json not found (Claude Code not installed or not configured)${NC}"
fi
echo ""

# ── 5. VS Code extension config ──────────────────────────────────────────────
sep
echo -e "${YELLOW}[5] VS Code extension config${NC}"
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    python3 -c "
import json, re
with open('$VSCODE_SETTINGS') as f:
    raw = f.read()
# Strip JS-style comments (basic)
raw = re.sub(r'//[^\n]*', '', raw)
try:
    cfg = json.loads(raw)
    servers = cfg.get('mcp', {}).get('servers', {})
    if not servers:
        servers = cfg.get('claude.mcpServers', {})
    entry = servers.get('discord-alert')
    if entry:
        print('  discord-alert found in VS Code settings ✅')
        print('  command:', entry.get('command','MISSING'))
        print('  args   :', entry.get('args', []))
    else:
        print('  discord-alert: NOT REGISTERED in VS Code settings')
        print('  (all mcp servers:', list(servers.keys()), ')')
except Exception as e:
    print('  Could not parse settings.json:', e)
" 2>/dev/null || echo "  Could not read VS Code settings"
else
    echo -e "  ${YELLOW}VS Code settings.json not found${NC}"
fi
# Also check workspace .vscode/mcp.json
if [ -f "$SCRIPT_DIR/.vscode/mcp.json" ]; then
    echo -e "  .vscode/mcp.json: found"
    cat "$SCRIPT_DIR/.vscode/mcp.json"
fi
echo ""

# ── 6. pyc cache check ────────────────────────────────────────────────────────
sep
echo -e "${YELLOW}[6] __pycache__ state${NC}"
find "$SCRIPT_DIR/src" -name "*.pyc" | while read f; do
    echo "  $f"
done
echo ""

sep
echo -e "${CYAN}Diagnostics complete. Share this output to debug further.${NC}"
