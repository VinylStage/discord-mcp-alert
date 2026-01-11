# Discord MCP Alert

Discord 웹훅을 통해 알림을 전송하는 MCP(Model Context Protocol) 서버입니다. LLM(Claude 등)이 이 서버를 통해 직접 Discord 채널로 메시지를 보낼 수 있습니다.

## 주요 기능

- **notify_discord**: 지정된 Discord 웹훅으로 텍스트 메시지를 전송합니다.
- **FastMCP 기반**: 빠르고 간결한 MCP 서버 구현.
- **Poetry 환경**: 현대적인 Python 의존성 관리.

## 시작하기

### 요구 사항

- Python 3.10 이상
- [Poetry](https://python-poetry.org/)

### 설치

1. 저장소를 클론합니다.
2. 의존성을 설치합니다:
   ```bash
   poetry install
   ```
3. `.env` 파일을 생성하고 Discord 웹훅 URL을 설정합니다:
   ```env
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
   ```

### 실행 및 테스트

- **테스트 스크립트 실행**:
  ```bash
  poetry run python -m src.main
  ```
- **MCP 서버 실행 (stdio)**:
  ```bash
  poetry run python src/server.py
  ```

## MCP 클라이언트 설정 (Claude Desktop)

Claude Desktop에서 이 도구를 사용하려면 설정 파일(`~/Library/Application Support/Claude/claude_desktop_config.json`)에 다음과 같이 추가하세요:

```json
{
  "mcpServers": {
    "discord-alert": {
      "command": "poetry",
      "args": ["--directory", "/Users/vinyl/vinylstudio/discord_mcp_alert", "run", "python", "src/server.py"],
      "cwd": "/Users/vinyl/vinylstudio/discord_mcp_alert"
    }
  }
}
```

## 프로젝트 구조

- `src/server.py`: MCP 서버 진입점 및 도구 정의.
- `src/notifier.py`: Discord 알림 전송 핵심 로직.
- `src/config.py`: 환경 변수 및 설정 관리.
- `src/main.py`: 간단한 동작 테스트용 스크립트.
