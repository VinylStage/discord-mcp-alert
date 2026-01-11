# 설정 및 등록 가이드 (Configuration Guide)

MCP 서버를 Claude Desktop이나 Claude Code(CLI)와 연동하기 위한 상세 설정 방법입니다.

## 1. 자동 설정 (권장)

프로젝트에 포함된 스크립트를 사용하면 가장 쉽게 설정할 수 있습니다.

```bash
poetry run python scripts/register_mcp.py
```

이 스크립트는 다음 작업을 수행합니다:
- **Claude Desktop**: 설정 파일(`claude_desktop_config.json`)을 자동으로 찾아 서버를 등록합니다.
- **Claude Code**: 터미널에 입력해야 할 등록 명령어를 출력합니다.

## 2. 수동 설정

### Claude Desktop

설정 파일(`claude_desktop_config.json`)을 직접 수정해야 할 경우 아래 내용을 참고하세요.

**파일 위치:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

**JSON 설정 예시:**

```json
{
  "mcpServers": {
    "discord-alert": {
      "command": "poetry", // 또는 python의 절대 경로
      "args": [
        "--directory",
        "/path/to/discord_mcp_alert", // 프로젝트 절대 경로
        "run",
        "python",
        "/path/to/discord_mcp_alert/src/server.py" // 서버 파일 절대 경로
      ],
      "cwd": "/path/to/discord_mcp_alert",
      "env": {
        "DISCORD_WEBHOOK_URL": "YOUR_WEBHOOK_URL_HERE" // .env 파일 대신 직접 입력 가능
      }
    }
  }
}
```

### Claude Code (CLI)

터미널에서 MCP 도구를 사용하려면 다음 명령어로 등록합니다.

```bash
claude mcp add discord-alert "poetry --directory /absolute/path/to/project run python /absolute/path/to/project/src/server.py"
```

## 3. 환경 변수

| 변수명 | 필수 여부 | 설명 |
|--------|-----------|------|
| `DISCORD_WEBHOOK_URL` | **Yes** | Discord 채널의 웹훅 URL입니다. |
