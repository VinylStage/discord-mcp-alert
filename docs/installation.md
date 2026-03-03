# 설치 가이드 (Installation Guide)

이 프로젝트는 Python 기반의 MCP 서버입니다. **Windows, Mac, Linux** 환경을 모두 지원합니다.

## 사전 요구 사항

- **Python 3.10+**: 필수. 설치 후 `python --version`으로 확인하세요.
- **Git**: 소스 코드를 클론하기 위해 필요합니다.
- **Poetry** (권장): 의존성 관리에 Poetry를 권장합니다. pip + venv로도 동작하지만, Poetry가 더 안정적입니다.

---

## 빠른 설치 (모든 OS 공통)

Python이 설치되어 있다면 OS에 관계없이 다음 명령어 하나로 설치할 수 있습니다:

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
python install.py
```

`install.py`가 자동으로 수행하는 작업:

1. ✅ OS 자동 감지 (Windows / macOS / Linux)
2. ✅ 패키지 매니저 자동 감지 (Poetry 또는 pip + venv)
3. ✅ 의존성 자동 설치
4. ✅ Discord Webhook URL 대화형 입력 및 `.env` 생성
5. ✅ 테스트 알림 전송으로 설정 검증
6. ✅ Claude Desktop MCP 자동 등록
7. ✅ Claude Code CLI 전역 자동 등록

> **Note**: Python 또는 Poetry가 PATH에 없거나 설치되지 않은 경우, 스크립트는 오류 메시지를 출력하고 종료합니다. 환경 설정은 직접 해주세요.

---

## 플랫폼별 스크립트 (Poetry 전용 대안)

Poetry를 이미 사용하는 경우 플랫폼별 스크립트를 직접 실행할 수 있습니다.

### Mac / Linux

```bash
./setup.sh
```

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

---

## 패키지 매니저 옵션

### Poetry (권장)

Poetry는 의존성 격리와 버전 관리가 더 안정적입니다.

```bash
# Poetry 설치 (아직 없는 경우)
# Mac/Linux:
curl -sSL https://install.python-poetry.org | python3 -

# Windows (PowerShell):
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -
```

Poetry가 설치된 상태에서 `python install.py`를 실행하면 자동으로 Poetry를 사용합니다.

**MCP 등록 명령 (Poetry)**:
```bash
claude mcp add --scope user discord-alert -- poetry --directory "/path/to/discord-mcp-alert" run python -m discord_mcp_alert.server
```

### pip + venv (대안)

Poetry가 없어도 pip와 Python 기본 venv로 설치할 수 있습니다.

> **중요**: `pip install -e .` (editable install) 방식만 지원됩니다. 일반 `pip install .`은 `.env` 경로 감지 문제로 동작하지 않습니다.

```bash
python -m venv .venv

# Mac/Linux:
.venv/bin/pip install -e .

# Windows:
.venv\Scripts\pip install -e .
```

pip 모드에서 `python install.py`를 실행하면 자동으로 위 과정을 수행합니다.

**MCP 등록 명령 (pip/venv)**:

Mac/Linux:
```bash
claude mcp add --scope user discord-alert -- /path/to/discord-mcp-alert/.venv/bin/python -m discord_mcp_alert.server
```

Windows:
```powershell
claude mcp add --scope user discord-alert -- C:\path\to\discord-mcp-alert\.venv\Scripts\python.exe -m discord_mcp_alert.server
```

---

## Claude Code CLI 전역 등록

**한 번 등록하면 모든 프로젝트에서 사용 가능합니다.**

`python install.py`가 자동으로 등록하지만, 수동으로 하려면:

**Mac/Linux (Poetry)**:
```bash
./register_claude_cli.sh
```

**Windows (Poetry)**:
```powershell
powershell -ExecutionPolicy Bypass -File register_claude_cli.ps1
```

**직접 명령 (모든 OS, Poetry)**:
```bash
claude mcp add --scope user discord-alert -- poetry --directory "/path/to/discord-mcp-alert" run python -m discord_mcp_alert.server
```

---

## Discord 훅 설정 (자동 알림)

Claude Code 작업 완료 시 자동으로 Discord 알림을 받으려면 훅을 설정합니다.

### webhook URL 파일 저장

**Mac/Linux:**
```bash
echo "https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN" > ~/.claude/discord-webhook.conf
```

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.claude"
"https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN" | Set-Content "$HOME\.claude\discord-webhook.conf" -Encoding UTF8
```

### `~/.claude/settings.json`에 훅 등록

**Mac/Linux** (`.claude/hooks/discord-notify.sh` 사용):
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/discord-mcp-alert/.claude/hooks/discord-notify.sh"
          }
        ]
      }
    ]
  }
}
```

**Windows / 크로스플랫폼** (`.claude/hooks/discord-notify.py` 사용):
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python C:\\path\\to\\discord-mcp-alert\\.claude\\hooks\\discord-notify.py"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python C:\\path\\to\\discord-mcp-alert\\.claude\\hooks\\discord-notify.py"
          }
        ]
      }
    ]
  }
}
```

---

## 수동 설치 (세부 제어)

세부 설정을 직접 제어하고 싶은 경우:

### 1. 저장소 클론

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
```

### 2. 의존성 설치

**Poetry (권장)**:
```bash
poetry install
```

**pip + venv (대안)**:
```bash
python -m venv .venv
# Mac/Linux:
.venv/bin/pip install -e .
# Windows:
.venv\Scripts\pip install -e .
```

### 3. 환경 변수 설정

`.env` 파일을 프로젝트 루트에 생성합니다:

```bash
cp .env.example .env
```

`.env` 파일을 편집하여 Discord Webhook URL 입력:

```env
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your-webhook-id/your-webhook-token
```

**Discord Webhook URL 얻는 방법:**
1. Discord 서버 설정 → 연동 → 웹훅
2. "새 웹훅" 생성
3. URL 복사

### 4. 테스트

**Poetry:**
```bash
poetry run python -m discord_mcp_alert.main
poetry run python tests/verify_mcp.py
```

**pip/venv (Mac/Linux):**
```bash
.venv/bin/python -m discord_mcp_alert.main
```

**pip/venv (Windows):**
```powershell
.venv\Scripts\python -m discord_mcp_alert.main
```

### 5. MCP 등록

**Claude Desktop:**
```bash
# Poetry:
poetry run python scripts/register_mcp.py

# pip/venv (Mac/Linux):
.venv/bin/python scripts/register_mcp.py
```

**Claude Code CLI:**
```bash
# Poetry:
claude mcp add --scope user discord-alert -- poetry --directory "/path/to/discord-mcp-alert" run python -m discord_mcp_alert.server
```

---

## 포터블 설치

프로젝트를 다른 위치로 이동하거나 새 머신에 복사할 때, `python install.py`를 다시 실행하면 새 위치로 자동 등록됩니다. 절대 경로는 자동으로 업데이트됩니다.

---

## 설치 확인

```bash
claude mcp list
# 출력 예시:
# discord-alert: poetry --directory "/home/user/discord-mcp-alert" ... - Connected
```

---

## 문제 해결

### Poetry를 찾을 수 없음

Poetry가 설치되어 있어도 PATH에 없으면 스크립트가 실패합니다. 설치 후 새 터미널 세션을 열거나 PATH를 직접 설정하세요.

```bash
# Mac/Linux: ~/.local/bin 을 PATH에 추가
export PATH="$HOME/.local/bin:$PATH"
```

### .env 파일 없음 오류

```bash
cp .env.example .env
# .env 파일을 편집하여 DISCORD_WEBHOOK_URL 입력
```

### MCP 연결 실패

```bash
claude mcp remove discord-alert
claude mcp add --scope user discord-alert -- poetry --directory "/path/to/discord-mcp-alert" run python -m discord_mcp_alert.server
```

### pip install 후 .env를 찾지 못함

`pip install -e .` (editable install)이 아닌 일반 `pip install .`을 사용한 경우입니다.
반드시 `-e` 플래그를 포함해야 합니다. `python install.py`를 사용하면 자동으로 처리됩니다.
