# Discord MCP Alert

Discord 웹훅을 통해 알림을 전송하는 MCP(Model Context Protocol) 서버입니다. LLM(Claude Desktop, Claude Code 등)이 이 서버를 통해 직접 Discord 채널로 메시지를 보낼 수 있습니다.

## 주요 기능

- **notify_discord**: 지정된 Discord 웹훅으로 텍스트 메시지를 전송합니다.
- **FastMCP 기반**: 빠르고 간결한 MCP 서버 구현.
- **Poetry 환경**: 현대적인 Python 의존성 관리.

## 시작하기

### 요구 사항

- Python 3.10 이상
- [Poetry](https://python-poetry.org/)

### 설치

1. 저장소를 클론하고 디렉토리로 이동합니다.
2. 의존성을 설치합니다:
   ```bash
   poetry install
   ```
3. `.env` 파일을 생성하고 Discord 웹훅 URL을 설정합니다:
   ```env
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
   ```

### 🛠️ 설정 및 등록 (자동)

제공된 스크립트를 사용하여 Claude Desktop에 설정을 자동으로 추가하고, Claude Code용 등록 명령어를 확인할 수 있습니다.

```bash
poetry run python scripts/register_mcp.py
```

실행 시:
1. **Claude Desktop**: 설정 파일(`claude_desktop_config.json`)을 찾아 자동으로 서버를 등록합니다.
2. **Claude Code**: 터미널에 입력해야 할 `claude mcp add ...` 명령어를 출력해 줍니다.

---

### 📝 설정 및 등록 (수동)

자동 스크립트를 사용하지 않고 직접 설정하려면 아래 내용을 참고하세요.

#### 1. Claude Desktop

설정 파일을 열고 `mcpServers` 섹션에 아래 내용을 추가합니다.

**설정 파일 위치:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

**추가할 내용 (JSON):**
`/Users/vinyl/vinylstudio/discord_mcp_alert` 부분은 실제 프로젝트 경로로 변경하세요.

```json
{
  "mcpServers": {
    "discord-alert": {
      "command": "poetry",
      "args": [
        "--directory",
        "/Users/vinyl/vinylstudio/discord_mcp_alert",
        "run",
        "python",
        "/Users/vinyl/vinylstudio/discord_mcp_alert/src/server.py"
      ],
      "cwd": "/Users/vinyl/vinylstudio/discord_mcp_alert"
    }
  }
}
```

#### 2. Claude Code (CLI)

터미널에서 다음 명령어를 실행하여 글로벌 MCP 도구로 등록합니다. (경로는 실제 경로로 수정)

```bash
claude mcp add discord-alert "poetry --directory /Users/vinyl/vinylstudio/discord_mcp_alert run python src/server.py"
```

## 사용 방법

연동 후 Claude에게 다음과 같이 요청할 수 있습니다:

- "Discord로 '배포가 완료되었습니다'라고 알림 보내줘."
- "이 내용을 요약해서 디스코드 채널에 공유해줘."

## 프로젝트 구조

- `src/server.py`: MCP 서버 진입점 및 도구 정의.
- `src/notifier.py`: Discord 알림 전송 핵심 로직.
- `src/config.py`: 환경 변수 및 설정 관리.
- `scripts/register_mcp.py`: 설정 자동화 스크립트.