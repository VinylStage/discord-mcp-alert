# 설정 및 등록 가이드 (Configuration Guide)

MCP 서버를 Claude Desktop이나 Claude Code(CLI)와 연동하기 위한 상세 설정 방법입니다.

## 1. 자동 설정 (권장)

### setup.sh를 사용한 완전 자동 설정

가장 간단한 방법입니다. 모든 설정을 자동으로 처리합니다:

```bash
./setup.sh
```

이 스크립트는 다음을 수행합니다:
- ✅ 환경 검증 (Poetry, Python)
- ✅ 의존성 설치
- ✅ Discord Webhook URL 설정
- ✅ `.env` 파일 생성
- ✅ 테스트 알림 전송
- ✅ Claude Desktop 자동 등록
- ✅ Claude Code CLI 등록 명령어 제공

### Claude Desktop만 등록

```bash
poetry run python scripts/register_mcp.py
```

### Claude Code CLI만 등록

```bash
./register_claude_cli.sh
```

## 2. 수동 설정

### Claude Desktop

설정 파일(`claude_desktop_config.json`)을 직접 수정해야 할 경우 아래 내용을 참고하세요.

**파일 위치:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`
- **Windows**: 현재 미지원

**JSON 설정 예시:**

```json
{
  "mcpServers": {
    "discord-alert": {
      "command": "poetry",
      "args": [
        "--directory",
        "/absolute/path/to/discord-mcp-alert",
        "run",
        "python",
        "/absolute/path/to/discord-mcp-alert/src/discord_mcp_alert/server.py"
      ],
      "cwd": "/absolute/path/to/discord-mcp-alert",
      "env": {}
    }
  }
}
```

**중요**:
- `.env` 파일은 프로젝트 루트에 존재해야 합니다
- `config.py`가 자동으로 프로젝트 루트에서 `.env`를 로드합니다
- 환경 변수를 JSON에 직접 입력할 필요 없습니다

### Claude Code (CLI)

터미널에서 MCP 도구를 사용하려면 다음 명령어로 등록합니다.

**자동 스크립트 사용 (권장):**
```bash
./register_claude_cli.sh
```

**수동 등록:**
```bash
claude mcp add discord-alert -- bash -c "cd /absolute/path/to/discord-mcp-alert && poetry run python -m discord_mcp_alert.server"
```

**중요 사항:**
- `bash -c` 래퍼를 사용하여 작업 디렉토리를 프로젝트 루트로 변경합니다
- 이렇게 하면 `.env` 파일을 올바르게 로드할 수 있습니다
- 절대 경로를 사용해야 어느 디렉토리에서든 작동합니다

**등록 확인:**
```bash
claude mcp list

# 성공 예시:
# discord-alert: bash -c cd "/path/to/discord-mcp-alert" && poetry run python -m discord_mcp_alert.server - ✓ Connected
```

## 3. 환경 변수

### 필수 환경 변수

| 변수명 | 필수 여부 | 설명 |
|--------|-----------|------|
| `DISCORD_WEBHOOK_URL` | **Yes** | Discord 채널의 웹훅 URL |

### .env 파일 설정

프로젝트 루트에 `.env` 파일을 생성합니다:

```bash
cp .env.example .env
```

`.env` 파일 내용:
```env
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your-webhook-id/your-webhook-token
```

### Discord Webhook URL 얻는 방법

1. Discord 서버 설정 열기
2. "연동" (Integrations) 메뉴로 이동
3. "웹훅" (Webhooks) 클릭
4. "새 웹훅" 버튼 클릭
5. 웹훅 이름 설정 및 채널 선택
6. "웹훅 URL 복사" 클릭
7. `.env` 파일에 붙여넣기

## 4. 환경 자동 감지 기능

프로젝트는 다음과 같은 자동 감지 기능을 제공합니다:

### 프로젝트 루트 자동 감지

`config.py`가 자동으로 프로젝트 루트를 찾아 `.env` 파일을 로드합니다:

```python
# src/discord_mcp_alert/config.py
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
dotenv_path = PROJECT_ROOT / ".env"
load_dotenv(dotenv_path=dotenv_path)
```

이렇게 하면:
- 작업 디렉토리와 무관하게 `.env` 파일을 찾습니다
- 프로젝트를 다른 위치로 이동해도 정상 작동합니다
- 추가 설정 없이 바로 사용 가능합니다

### 스크립트 디렉토리 자동 감지

모든 쉘 스크립트가 자동으로 프로젝트 위치를 감지합니다:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
```

## 5. 문제 해결

### MCP 연결 실패

**증상:** `claude mcp list`에서 "Failed to connect" 표시

**해결 방법:**

1. **MCP 서버 재등록:**
   ```bash
   ./register_claude_cli.sh
   ```

2. **수동 재등록:**
   ```bash
   claude mcp remove discord-alert
   claude mcp add discord-alert -- bash -c "cd $(pwd) && poetry run python -m discord_mcp_alert.server"
   ```

3. **`.env` 파일 확인:**
   ```bash
   cat .env
   # DISCORD_WEBHOOK_URL이 올바른지 확인
   ```

4. **직접 테스트:**
   ```bash
   poetry run python -m discord_mcp_alert.main
   ```

### .env 파일을 찾을 수 없음

**증상:** "DISCORD_WEBHOOK_URL is not set in the .env file" 오류

**해결 방법:**

1. `.env` 파일이 프로젝트 루트에 있는지 확인:
   ```bash
   ls -la .env
   ```

2. `.env` 파일이 없으면 생성:
   ```bash
   cp .env.example .env
   # .env 파일을 편집하여 DISCORD_WEBHOOK_URL 입력
   ```

3. 권한 확인:
   ```bash
   chmod 644 .env
   ```

### Poetry를 찾을 수 없음

**증상:** "poetry: command not found"

**해결 방법:**

1. Poetry 설치:
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. PATH에 추가:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. 쉘 재시작 또는:
   ```bash
   source ~/.bashrc  # 또는 ~/.zshrc
   ```

## 6. 고급 설정

### 프로젝트를 다른 위치로 이동

프로젝트를 새 위치로 이동한 후:

```bash
cd /new/location/discord-mcp-alert
./setup.sh  # 자동으로 새 위치 감지 및 재등록
```

### 여러 환경에서 사용

같은 프로젝트를 여러 머신에서 사용:

1. 각 머신에서 프로젝트 클론
2. `./setup.sh` 실행
3. 각 머신의 Discord Webhook URL 설정

### 테스트 환경 설정

개발/테스트용 별도 환경:

```bash
# .env.test 파일 생성
cp .env .env.test
# 테스트용 Webhook URL 입력

# 테스트 환경으로 실행
cp .env.test .env
poetry run python -m discord_mcp_alert.main
```
