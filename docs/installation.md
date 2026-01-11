# 설치 가이드 (Installation Guide)

이 프로젝트는 Python 기반의 MCP 서버입니다. 다양한 방법으로 설치하여 사용할 수 있습니다.

## 사전 요구 사항

- **Python**: 3.10 버전 이상이 필요합니다.
- **Git**: 소스 코드를 다운로드하기 위해 필요합니다.
- **Poetry** (권장): 의존성 관리를 위해 Poetry 사용을 권장합니다.

## 소스 코드 설치 (개발자용)

소스 코드를 직접 받아 실행하거나 기여하고 싶은 경우 이 방법을 사용하세요.

1. **저장소 클론**:
   ```bash
   git clone https://github.com/vinyl/discord_mcp_alert.git
   cd discord_mcp_alert
   ```

2. **의존성 설치 (Poetry)**:
   ```bash
   poetry install
   ```

3. **환경 변수 설정**:
   `.env` 파일을 프로젝트 루트에 생성합니다. (`.env.example` 참고 가능)
   ```env
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your-webhook-url
   ```

## PyPI 설치 (사용자용)

*현재 준비 중입니다.* 추후 `pip install discord-mcp-alert` 명령어를 지원할 예정입니다.
