#!/bin/bash
# Discord MCP Alert — Interactive Installer
# Registers discord-alert MCP server to one or more Claude clients.
#
# Supported targets:
#   [1] Claude Desktop
#   [2] Claude Code (CLI / global)
#   [3] VS Code Extension
#   [4] Claude Code Hooks (auto-notify on task complete)

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
HOOK_SRC="$SCRIPT_DIR/.claude/hooks/discord-notify.sh"
cd "$SCRIPT_DIR"

# ── Colors ───────────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m'
B='\033[0;34m' C='\033[0;36m' W='\033[1;37m' N='\033[0m'

sep()    { echo -e "${B}──────────────────────────────────────────────────${N}"; }
header() { echo -e "${C}$1${N}"; }
ok()     { echo -e "  ${G}✅ $1${N}"; }
warn()   { echo -e "  ${Y}⚠️  $1${N}"; }
err()    { echo -e "  ${R}❌ $1${N}"; }
info()   { echo -e "  ${B}ℹ️  $1${N}"; }

# ── Banner ────────────────────────────────────────────────────────────────────
clear
echo -e "${C}"
echo "  ██████╗ ██╗███████╗ ██████╗ ██████╗ ██████╗ ██████╗     ███╗   ███╗ ██████╗██████╗ "
echo "  ██╔══██╗██║██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗    ████╗ ████║██╔════╝██╔══██╗"
echo "  ██║  ██║██║███████╗██║     ██║   ██║██████╔╝██║  ██║    ██╔████╔██║██║     ██████╔╝"
echo "  ██║  ██║██║╚════██║██║     ██║   ██║██╔══██╗██║  ██║    ██║╚██╔╝██║██║     ██╔═══╝ "
echo "  ██████╔╝██║███████║╚██████╗╚██████╔╝██║  ██║██████╔╝    ██║ ╚═╝ ██║╚██████╗██║     "
echo "  ╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚═╝     ╚═╝ ╚═════╝╚═╝     "
echo -e "${N}"
echo -e "${W}  Discord MCP Alert — Interactive Installer${N}"
echo -e "${B}  Claude 작업 알림을 Discord로 받도록 설정합니다.${N}"
echo ""

# ── PHASE 1: Python 환경 준비 ────────────────────────────────────────────────
sep
header "[Phase 1/4]  Python 환경 준비"
echo ""

VENV_PYTHON=""

if command -v poetry &>/dev/null; then
    echo -e "  Poetry 감지됨 — poetry install 실행 중..."
    poetry install --quiet 2>/dev/null || poetry install
    VENV_PYTHON=$(poetry env info --executable 2>/dev/null || true)
    if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
        VENV_PATH=$(poetry env info --path 2>/dev/null || true)
        VENV_PYTHON="$VENV_PATH/bin/python"
    fi
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    if command -v uv &>/dev/null; then
        echo -e "  uv 감지됨 — uv sync 실행 중..."
        uv sync --quiet 2>/dev/null || uv sync
        VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"
    fi
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    SYS_PY=$(command -v python3 || command -v python || true)
    if [ -n "$SYS_PY" ]; then
        warn "Poetry/uv 없음 — 시스템 Python 사용: $SYS_PY"
        "$SYS_PY" -m pip install --quiet mcp requests python-dotenv 2>/dev/null \
            || "$SYS_PY" -m pip install mcp requests python-dotenv
        VENV_PYTHON="$SYS_PY"
    fi
fi

if [ -z "$VENV_PYTHON" ] || [ ! -f "$VENV_PYTHON" ]; then
    err "Python을 찾을 수 없습니다. Poetry, uv, 또는 Python3을 설치해주세요."
    exit 1
fi

ok "Python: $VENV_PYTHON"
ok "버전: $($VENV_PYTHON --version)"
$VENV_PYTHON -c "import mcp" 2>/dev/null && ok "mcp 모듈: 설치됨" || { err "mcp 모듈 없음 — poetry install 실행 후 재시도"; exit 1; }

# Stale bytecode 제거
find "$SRC_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
ok "bytecode 캐시 초기화"
echo ""

# ── PHASE 2: Webhook URL 확인 ─────────────────────────────────────────────────
sep
header "[Phase 2/4]  Discord Webhook URL 설정"
echo ""

WEBHOOK_URL=""

# .env에서 읽기
if [ -f "$SCRIPT_DIR/.env" ]; then
    WEBHOOK_URL=$(grep -E '^DISCORD_WEBHOOK_URL=' "$SCRIPT_DIR/.env" | cut -d= -f2- | tr -d '"' | tr -d "'")
fi

if [ -n "$WEBHOOK_URL" ]; then
    MASKED="${WEBHOOK_URL:0:40}...${WEBHOOK_URL: -6}"
    ok "기존 Webhook URL 발견: $MASKED"
    echo ""
    read -rp "  이 URL을 그대로 사용하시겠습니까? [Y/n]: " USE_EXISTING
    USE_EXISTING="${USE_EXISTING:-Y}"
    if [[ "$USE_EXISTING" =~ ^[Nn]$ ]]; then
        WEBHOOK_URL=""
    fi
fi

if [ -z "$WEBHOOK_URL" ]; then
    echo -e "  ${B}Discord Webhook URL을 입력하세요.${N}"
    echo -e "  ${B}(Discord 서버 → 채널 설정 → 연동 → 웹후크에서 생성)${N}"
    echo ""
    while true; do
        read -rp "  Webhook URL: " WEBHOOK_URL
        if [[ "$WEBHOOK_URL" =~ ^https://discord\.com/api/webhooks/ ]]; then
            break
        fi
        err "올바른 Discord Webhook URL 형식이 아닙니다. (https://discord.com/api/webhooks/... 로 시작해야 합니다)"
    done
    echo "DISCORD_WEBHOOK_URL=$WEBHOOK_URL" > "$SCRIPT_DIR/.env"
    ok ".env 파일 저장 완료"
fi

# Claude Code Hooks용 별도 저장
HOOK_CONF="$HOME/.claude/discord-webhook.conf"
mkdir -p "$(dirname "$HOOK_CONF")"
echo "$WEBHOOK_URL" > "$HOOK_CONF"
ok "Claude Code Hook 설정 저장: $HOOK_CONF"
echo ""

# ── PHASE 3: 등록 대상 선택 ──────────────────────────────────────────────────
sep
header "[Phase 3/4]  등록 대상 선택"
echo ""
echo -e "  어떤 Claude 클라이언트에 등록할까요?"
echo ""
echo -e "  ${W}[1]${N} Claude Desktop App"
echo -e "  ${W}[2]${N} Claude Code (CLI / 터미널)"
echo -e "  ${W}[3]${N} VS Code Extension (Claude)"
echo -e "  ${W}[4]${N} Claude Code Hooks (작업 완료 시 자동 알림)"
echo -e "  ${W}[A]${N} 전체 선택"
echo ""
echo -e "  ${B}예시: 1        → Claude Desktop만${N}"
echo -e "  ${B}      1 2      → Claude Desktop + Claude Code${N}"
echo -e "  ${B}      1 2 3 4  → 전체 (A와 동일)${N}"
echo ""
read -rp "  선택: " SELECTION
SELECTION="${SELECTION:-A}"

DO_DESKTOP=false
DO_CLI=false
DO_VSCODE=false
DO_HOOKS=false

if [[ "${SELECTION^^}" == *"A"* ]]; then
    DO_DESKTOP=true; DO_CLI=true; DO_VSCODE=true; DO_HOOKS=true
else
    [[ "$SELECTION" == *"1"* ]] && DO_DESKTOP=true
    [[ "$SELECTION" == *"2"* ]] && DO_CLI=true
    [[ "$SELECTION" == *"3"* ]] && DO_VSCODE=true
    [[ "$SELECTION" == *"4"* ]] && DO_HOOKS=true
fi

echo ""
echo -e "  선택된 대상:"
$DO_DESKTOP && echo -e "    ${G}✔${N} Claude Desktop App"
$DO_CLI     && echo -e "    ${G}✔${N} Claude Code (CLI)"
$DO_VSCODE  && echo -e "    ${G}✔${N} VS Code Extension"
$DO_HOOKS   && echo -e "    ${G}✔${N} Claude Code Hooks"
echo ""

# ── PHASE 4: 앱 종료 요청 후 등록 ────────────────────────────────────────────
sep
header "[Phase 4/4]  앱 종료 및 등록"
echo ""

REGISTERED=()

# ── [1] Claude Desktop ────────────────────────────────────────────────────────
if $DO_DESKTOP; then
    echo -e "  ${W}━ Claude Desktop App${N}"
    echo ""
    warn "Claude Desktop을 완전히 종료해주세요 (Cmd+Q)."
    echo -e "  종료 후 엔터를 누르세요..."
    read -r
    echo ""

    DESKTOP_CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    mkdir -p "$(dirname "$DESKTOP_CFG")"

    "$VENV_PYTHON" - <<PYEOF
import json, shutil
from pathlib import Path

cfg_path = Path("$DESKTOP_CFG")
cfg = {}
if cfg_path.exists():
    try:
        cfg = json.loads(cfg_path.read_text())
    except Exception:
        shutil.copy(cfg_path, str(cfg_path) + ".bak")

cfg.setdefault("mcpServers", {})["discord-alert"] = {
    "command": "$VENV_PYTHON",
    "args":    ["-m", "discord_mcp_alert.server"],
    "cwd":     "$SCRIPT_DIR",
    "env":     {"PYTHONPATH": "$SRC_DIR"},
}
cfg_path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False))
print("  written: " + str(cfg_path))
PYEOF

    ok "Claude Desktop 등록 완료"
    info "Claude Desktop을 다시 실행하세요."
    REGISTERED+=("claude_desktop")
    echo ""
fi

# ── [2] Claude Code CLI ───────────────────────────────────────────────────────
if $DO_CLI; then
    echo -e "  ${W}━ Claude Code (CLI)${N}"
    echo ""

    if command -v claude &>/dev/null; then
        warn "진행 중인 Claude Code 세션이 있다면 종료해주세요."
        echo -e "  종료 후 엔터를 누르세요..."
        read -r
        echo ""

        claude mcp remove discord-alert 2>/dev/null || true
        claude mcp add --scope user discord-alert \
            -e "PYTHONPATH=$SRC_DIR" \
            -- "$VENV_PYTHON" -m discord_mcp_alert.server
        ok "Claude Code CLI 등록 완료 (scope: user/global)"
        info "새 터미널 세션에서 바로 사용 가능합니다."
    else
        warn "'claude' 명령어 없음 — Claude Code CLI 미설치 상태로 건너뜁니다."
        info "설치: https://claude.ai/download"
    fi
    REGISTERED+=("claude_code")
    echo ""
fi

# ── [3] VS Code Extension ─────────────────────────────────────────────────────
if $DO_VSCODE; then
    echo -e "  ${W}━ VS Code Extension${N}"
    echo ""
    warn "VS Code를 완전히 종료해주세요."
    echo -e "  종료 후 엔터를 누르세요..."
    read -r
    echo ""

    VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"

    "$VENV_PYTHON" - <<PYEOF
import json, re, sys
from pathlib import Path

settings_path = Path("$VSCODE_SETTINGS")
if not settings_path.parent.exists():
    print("  VS Code 설정 디렉토리 없음 — 건너뜁니다.")
    sys.exit(0)

cfg = {}
if settings_path.exists():
    try:
        raw = re.sub(r'//[^\n]*', '', settings_path.read_text())
        cfg = json.loads(raw)
    except Exception as e:
        print(f"  settings.json 파싱 오류: {e}")
        sys.exit(0)

cfg.setdefault("mcp", {}).setdefault("servers", {})["discord-alert"] = {
    "type":    "stdio",
    "command": "$VENV_PYTHON",
    "args":    ["-m", "discord_mcp_alert.server"],
    "env":     {"PYTHONPATH": "$SRC_DIR"},
}
settings_path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False))
print("  written: " + str(settings_path))
PYEOF

    ok "VS Code Extension 등록 완료"
    info "VS Code 재시작 후: Cmd+Shift+P → 'Developer: Reload Window'"
    REGISTERED+=("claude_vscode")
    echo ""
fi

# ── [4] Claude Code Hooks ────────────────────────────────────────────────────
if $DO_HOOKS; then
    echo -e "  ${W}━ Claude Code Hooks (자동 알림)${N}"
    echo ""

    # Global hooks dir
    GLOBAL_HOOKS_DIR="$HOME/.claude/hooks"
    mkdir -p "$GLOBAL_HOOKS_DIR"

    # Copy hook script
    cp "$HOOK_SRC" "$GLOBAL_HOOKS_DIR/discord-notify.sh"
    chmod +x "$GLOBAL_HOOKS_DIR/discord-notify.sh"

    # Register hooks in ~/.claude.json via claude CLI (if available)
    if command -v claude &>/dev/null; then
        HOOK_EVENTS=("Stop" "Notification")
        for EVENT in "${HOOK_EVENTS[@]}"; do
            claude hooks add "$EVENT" \
                --command "bash \"$GLOBAL_HOOKS_DIR/discord-notify.sh\"" \
                --scope user 2>/dev/null \
            || warn "$EVENT hook 자동 등록 실패 — 아래 수동 안내를 확인하세요"
        done
        ok "Claude Code Hooks 등록 완료 (Stop, Notification)"
    else
        warn "'claude' CLI 없음 — Hook 파일은 복사됐지만 자동 등록은 불가합니다."
        info "수동 등록: claude hooks add Stop --command 'bash $GLOBAL_HOOKS_DIR/discord-notify.sh' --scope user"
    fi

    ok "Hook 파일: $GLOBAL_HOOKS_DIR/discord-notify.sh"
    info "Webhook URL: $HOOK_CONF"
    REGISTERED+=("hooks")
    echo ""
fi

# ── 테스트 알림 전송 ──────────────────────────────────────────────────────────
sep
header "  테스트 알림 전송"
echo ""

echo -e "  설정이 완료됐습니다. Discord로 테스트 알림을 보냅니다..."
echo ""

PYTHONPATH="$SRC_DIR" "$VENV_PYTHON" - <<PYEOF
import sys
sys.path.insert(0, "$SRC_DIR")
from discord_mcp_alert.notifier import send_discord_notification

targets = "${REGISTERED[*]}"

send_discord_notification(
    message="Discord MCP Alert 설치가 완료됐습니다.\n\n등록된 클라이언트: " + (targets if targets else "unknown"),
    title="설치 완료",
    event_type="complete",
    source="claude_code",
)
print("  Discord 전송 성공 ✅")
PYEOF

echo ""

# ── 완료 요약 ─────────────────────────────────────────────────────────────────
sep
echo ""
echo -e "${C}╔══════════════════════════════════════════════════╗${N}"
echo -e "${C}║           설치 완료!                             ║${N}"
echo -e "${C}╚══════════════════════════════════════════════════╝${N}"
echo ""

if $DO_DESKTOP; then
    echo -e "  ${W}Claude Desktop${N}"
    echo -e "    → Claude Desktop 앱을 실행하고 채팅에서 테스트해보세요."
    echo -e "      ${C}\"테스트 알림 Discord로 보내줘\"${N}"
    echo ""
fi
if $DO_CLI; then
    echo -e "  ${W}Claude Code (CLI)${N}"
    echo -e "    → 새 터미널에서 Claude Code 실행 후:"
    echo -e "      ${C}claude mcp list${N}  — discord-alert 확인"
    echo -e "      ${C}\"Discord에 테스트 알림 보내줘\"${N}"
    echo ""
fi
if $DO_VSCODE; then
    echo -e "  ${W}VS Code Extension${N}"
    echo -e "    → VS Code 재시작 후 Cmd+Shift+P → ${C}Developer: Reload Window${N}"
    echo -e "      Claude 채팅에서: ${C}\"Discord에 알림 보내줘\"${N}"
    echo ""
fi
if $DO_HOOKS; then
    echo -e "  ${W}Claude Code Hooks${N}"
    echo -e "    → 이제 Claude Code 작업이 완료될 때마다 자동으로 Discord 알림이 옵니다."
    echo ""
fi

echo -e "  ${B}사용 가능한 event_type:${N}"
echo -e "    success · error · warning · info · start · complete · default"
echo ""
echo -e "  ${B}문서:${N} docs/DEVELOPER.md"
echo -e "  ${B}진단:${N} ./diagnose.sh"
echo ""
