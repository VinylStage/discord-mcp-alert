# Developer Guide — Discord MCP Alert

개발자용 수동 설정 가이드입니다. 자동 설치(`install.sh`)로 해결이 안 될 때 참조하세요.

---

## 구조 개요

```
discord-mcp-alert/
├── install.sh                        # 대화형 설치 (권장)
├── diagnose.sh                       # 등록 상태 진단
├── run_server.sh                     # MCP 서버 수동 실행
├── .env                              # DISCORD_WEBHOOK_URL (git 제외)
├── .claude/
│   └── hooks/
│       └── discord-notify.sh        # Claude Code 자동 알림 훅
├── src/discord_mcp_alert/
│   ├── server.py                    # MCP 서버 진입점 (FastMCP)
│   ├── notifier.py                  # Discord Embed 전송 로직
│   ├── config.py                    # 환경변수 로더
│   └── main.py                      # 단순 테스트 스크립트
├── scripts/
│   └── register_mcp.py             # Claude Desktop config 작성기
└── tests/
    ├── verify_mcp.py               # MCP 서버 연결 검증
    └── test_notify_tool.py         # 도구 호출 통합 테스트
```

---

## Config 파일 위치

| 앱 | Config 경로 |
|-----|-------------|
| Claude Desktop | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Claude Code CLI | `~/.claude.json` |
| VS Code Extension | `~/Library/Application Support/Code/User/settings.json` |
| Claude Code Hooks | `~/.claude/discord-webhook.conf` (webhook URL) |
| Hook 스크립트 (글로벌) | `~/.claude/hooks/discord-notify.sh` |
| Webhook URL | `.env` (프로젝트 루트) |

---

## 수동 설치

### 1. 의존성 설치

```bash
cd discord-mcp-alert
poetry install
```

의존성 확인:
```bash
poetry run python -c "import mcp, requests, dotenv; print('OK')"
```

### 2. Webhook URL 설정

```bash
echo "DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/..." > .env
```

### 3. 각 클라이언트 수동 등록

#### A. Claude Desktop

`~/Library/Application Support/Claude/claude_desktop_config.json`에 아래 추가:

```json
{
  "mcpServers": {
    "discord-alert": {
      "command": "/path/to/venv/bin/python",
      "args": ["-m", "discord_mcp_alert.server"],
      "cwd": "/path/to/discord-mcp-alert",
      "env": {
        "PYTHONPATH": "/path/to/discord-mcp-alert/src"
      }
    }
  }
}
```

venv Python 경로 확인:
```bash
poetry env info --executable
```

또는 스크립트로 자동 작성:
```bash
poetry run python scripts/register_mcp.py
```

#### B. Claude Code CLI

```bash
VENV_PYTHON=$(poetry env info --executable)
SRC_DIR="$(pwd)/src"

claude mcp add --scope user discord-alert \
    -e "PYTHONPATH=$SRC_DIR" \
    -- "$VENV_PYTHON" -m discord_mcp_alert.server
```

등록 확인:
```bash
claude mcp list
```

#### C. VS Code Extension

`~/Library/Application Support/Code/User/settings.json`에 추가:

```json
{
  "mcp": {
    "servers": {
      "discord-alert": {
        "type": "stdio",
        "command": "/path/to/venv/bin/python",
        "args": ["-m", "discord_mcp_alert.server"],
        "env": {
          "PYTHONPATH": "/path/to/discord-mcp-alert/src"
        }
      }
    }
  }
}
```

#### D. Claude Code Hooks

Webhook URL 저장:
```bash
echo "https://discord.com/api/webhooks/..." > ~/.claude/discord-webhook.conf
```

Hook 스크립트 설치:
```bash
mkdir -p ~/.claude/hooks
cp .claude/hooks/discord-notify.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/discord-notify.sh
```

Hook 등록 (Claude Code CLI):
```bash
claude hooks add Stop \
    --command 'bash ~/.claude/hooks/discord-notify.sh' \
    --scope user

claude hooks add Notification \
    --command 'bash ~/.claude/hooks/discord-notify.sh' \
    --scope user
```

---

## 테스트

```bash
# 1. 단순 전송 테스트 (MCP 서버 없이)
PYTHONPATH=src poetry run python -m discord_mcp_alert.main

# 2. MCP 서버 연결 검증
PYTHONPATH=src poetry run python tests/verify_mcp.py

# 3. 도구 호출 통합 테스트
PYTHONPATH=src poetry run python tests/test_notify_tool.py

# 4. 전체 상태 진단
./diagnose.sh
```

---

## 주요 버그 레퍼런스

### "No module named 'mcp'" (Claude Desktop)

**원인**: `poetry run python`을 Command로 쓰면 Claude Desktop 실행 시 pyenv가 PATH에 없어 Poetry가 Python 버전을 잘못 감지하고 빈 venv 생성.

**해결**: `command`에 venv Python 절대경로 직접 사용.

```json
"command": "/Users/vinyl/Library/Caches/pypoetry/virtualenvs/discord-mcp-alert-vbgdxUVT-py3.13/bin/python"
```

### "unknown option '-m'" (claude mcp add)

**원인**: `claude mcp add`의 옵션 파싱 순서 문제. `-m`을 claude 자체 옵션으로 해석.

**해결**: 서버 명령 앞에 `--` 구분자 추가.

```bash
claude mcp add --scope user discord-alert \
    -e "PYTHONPATH=$SRC_DIR" \
    -- "$VENV_PYTHON" -m discord_mcp_alert.server
```

### "Invalid environment variable format"

**원인**: `claude mcp add`에서 서버 이름이 `-e` 플래그 뒤에 위치하면 env var로 파싱됨.

**해결**: 서버 이름을 `-e` 앞에 위치.

```bash
# 잘못된 순서
claude mcp add --scope user -e "KEY=val" discord-alert -- ...

# 올바른 순서
claude mcp add --scope user discord-alert -e "KEY=val" -- ...
```

---

## notifier.py 파라미터

```python
send_discord_notification(
    message: str,            # 본문 (필수)
    title: str = "",         # 제목 (없으면 event_type으로 자동 생성)
    event_type: str = "default",   # success/error/warning/info/start/complete/default
    source: str = "",        # claude_code / claude_desktop / claude_app / claude_cowork / claude_vscode
    fields: list | None = None,    # [{"name": str, "value": str, "inline": bool}]
) -> int                     # HTTP status code
```

### event_type → Discord Embed 색상 매핑

| event_type | hex | decimal |
|---|---|---|
| success | `#57F287` | 5763719 |
| error | `#ED4245` | 15548997 |
| warning | `#FEE75C` | 16705372 |
| info | `#5865F2` | 5793266 |
| start | `#3498DB` | 3447003 |
| complete | `#2ECC71` | 3066993 |
| default | `#95A5A6` | 9807270 |

---

## Claude Code Hook 이벤트

`.claude/hooks/discord-notify.sh`가 처리하는 이벤트:

| hook_event_name | 트리거 시점 | Embed 색상 |
|---|---|---|
| `Stop` | 응답 완료 | 🟢 초록 |
| `Notification` | 사용자 입력 대기 | 🟡 노랑 |
| `PreToolUse` | 도구 사용 직전 | 🔵 하늘 |

Hook은 stdin에서 JSON을 받습니다:
```json
{
  "hook_event_name": "Stop",
  "session_id": "abc12345-...",
  "cwd": "/Users/vinyl/project"
}
```
