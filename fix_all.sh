#!/bin/bash
# Discord MCP Alert — Fix ALL registrations
# Covers: Claude Desktop  |  Claude Code CLI  |  VS Code extension

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

sep() { echo -e "${BLUE}─────────────────────────────────────────────${NC}"; }

echo -e "${CYAN}╔═════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Discord MCP Alert — Fix All               ║${NC}"
echo -e "${CYAN}╚═════════════════════════════════════════════╝${NC}"
echo ""

# ── STEP 1: Resolve Python executable ────────────────────────────────────────
sep
echo -e "${YELLOW}[1/5] Resolving Python + installing dependencies...${NC}"

VENV_PYTHON=""

if command -v poetry &>/dev/null; then
    echo -e "   Poetry found — running poetry install..."
    poetry install --quiet 2>/dev/null || poetry install
    VENV_PYTHON=$(poetry env info --executable 2>/dev/null || true)
    if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
        VENV_PATH=$(poetry env info --path 2>/dev/null || true)
        VENV_PYTHON="$VENV_PATH/bin/python"
    fi
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    if command -v uv &>/dev/null; then
        echo -e "   uv found — running uv sync..."
        uv sync --quiet 2>/dev/null || uv sync
        VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"
    fi
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    SYS_PY=$(command -v python3 || command -v python || true)
    if [ -n "$SYS_PY" ]; then
        $SYS_PY -m pip install --quiet mcp requests python-dotenv 2>/dev/null \
            || $SYS_PY -m pip install mcp requests python-dotenv
        VENV_PYTHON="$SYS_PY"
    fi
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    echo -e "${RED}❌ No usable Python found. Install Poetry, uv, or pip.${NC}"
    exit 1
fi

echo -e "   ${GREEN}✅ Python: $VENV_PYTHON${NC}"
echo -e "   Version: $($VENV_PYTHON --version)"
$VENV_PYTHON -c "import mcp; print('   mcp: ✅')"
echo ""

# ── STEP 2: Clear stale bytecode cache ───────────────────────────────────────
sep
echo -e "${YELLOW}[2/5] Clearing __pycache__ (stale bytecode)...${NC}"
find "$SRC_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$SRC_DIR" -name "*.pyc" -delete 2>/dev/null || true
echo -e "   ${GREEN}✅ Cache cleared${NC}"
echo ""

# ── STEP 3: Fix Claude Desktop ────────────────────────────────────────────────
sep
echo -e "${YELLOW}[3/5] Fixing Claude Desktop config...${NC}"
DESKTOP_CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
DESKTOP_DIR="$(dirname "$DESKTOP_CFG")"

mkdir -p "$DESKTOP_DIR"

python3 - <<PYEOF
import json, sys, shutil
from pathlib import Path

cfg_path = Path("$DESKTOP_CFG")
src_dir  = "$SRC_DIR"
venv_py  = "$VENV_PYTHON"
proj     = "$SCRIPT_DIR"

cfg = {}
if cfg_path.exists():
    try:
        cfg = json.loads(cfg_path.read_text())
    except Exception:
        shutil.copy(cfg_path, str(cfg_path) + ".bak")

cfg.setdefault("mcpServers", {})["discord-alert"] = {
    "command": venv_py,
    "args":    ["-m", "discord_mcp_alert.server"],
    "cwd":     proj,
    "env":     {"PYTHONPATH": src_dir},
}

cfg_path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False))
print(f"   Written: {cfg_path}")
print(f"   command: {venv_py}")
PYEOF
echo -e "   ${GREEN}✅ Claude Desktop config updated${NC}"
echo -e "   ${YELLOW}⚠️  Claude Desktop 앱을 완전히 종료 후 재시작하세요${NC}"
echo ""

# ── STEP 4: Fix Claude Code CLI ───────────────────────────────────────────────
sep
echo -e "${YELLOW}[4/5] Fixing Claude Code CLI (~/.claude.json)...${NC}"
if command -v claude &>/dev/null; then
    claude mcp remove discord-alert 2>/dev/null || true
    claude mcp add --scope user discord-alert \
        -e "PYTHONPATH=$SRC_DIR" \
        -- "$VENV_PYTHON" -m discord_mcp_alert.server
    echo -e "   ${GREEN}✅ Claude Code registered (scope: user/global)${NC}"
    echo -e "   Verify with: ${CYAN}claude mcp list${NC}"
else
    echo -e "   ${YELLOW}⚠️  'claude' command not found — skipping CLI registration${NC}"
    echo -e "   Install Claude Code or add manually to ~/.claude.json"
fi
echo ""

# ── STEP 5: Fix VS Code extension ─────────────────────────────────────────────
sep
echo -e "${YELLOW}[5/5] Fixing VS Code extension config...${NC}"
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"

python3 - <<PYEOF
import json, sys, re
from pathlib import Path

settings_path = Path("$VSCODE_SETTINGS")
venv_py  = "$VENV_PYTHON"
src_dir  = "$SRC_DIR"
proj     = "$SCRIPT_DIR"

if not settings_path.parent.exists():
    print("   VS Code settings dir not found — skipping")
    sys.exit(0)

cfg = {}
if settings_path.exists():
    try:
        raw = settings_path.read_text()
        # Strip single-line JS comments
        raw = re.sub(r'//[^\n]*', '', raw)
        cfg = json.loads(raw)
    except Exception as e:
        print(f"   Could not parse settings.json: {e}")
        sys.exit(0)

# VS Code Claude extension uses "mcp.servers" key
cfg.setdefault("mcp", {}).setdefault("servers", {})["discord-alert"] = {
    "type":    "stdio",
    "command": venv_py,
    "args":    ["-m", "discord_mcp_alert.server"],
    "env":     {"PYTHONPATH": src_dir},
}

settings_path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False))
print(f"   Written: {settings_path}")
print(f"   command: {venv_py}")
PYEOF
echo -e "   ${GREEN}✅ VS Code settings updated${NC}"
echo -e "   ${YELLOW}⚠️  VS Code를 재시작하거나 'Developer: Reload Window' 실행하세요${NC}"
echo ""

# ── Note: Claude Cowork ───────────────────────────────────────────────────────
sep
echo -e "${YELLOW}[ℹ️ ] Claude Cowork${NC}"
echo -e "   Cowork은 이 MCP 서버가 이미 연결돼 있습니다."
echo -e "   source 값으로 ${CYAN}\"claude_cowork\"${NC} 를 사용하세요."
echo -e "   별도 등록 불필요."
echo ""

# ── Done ──────────────────────────────────────────────────────────────────────
sep
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Done! 다음 단계:                               ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  1. ${YELLOW}Claude Desktop${NC} → 완전 종료(Cmd+Q) 후 재시작"
echo -e "  2. ${YELLOW}VS Code${NC}        → Cmd+Shift+P → 'Developer: Reload Window'"
echo -e "  3. ${YELLOW}Claude Code${NC}    → 새 터미널 세션에서 바로 사용 가능"
echo -e "  4. ${GREEN}Claude Cowork${NC}  → 이미 동작 중 ✅"
echo ""
echo -e "  테스트:"
echo -e "  ${CYAN}PYTHONPATH=src $VENV_PYTHON -m discord_mcp_alert.main${NC}"
echo ""
