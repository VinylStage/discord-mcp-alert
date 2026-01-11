# Discord MCP Alert 🔔

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)

> **Discord MCP Alert**는 LLM(Claude 등)이 직접 Discord 채널로 알림을 보낼 수 있게 해주는 [MCP(Model Context Protocol)](https://modelcontextprotocol.io) 서버입니다.

간단한 설정만으로 AI 에이전트가 작업 완료, 에러 발생, 요약 정보 등을 개발자에게 즉시 전달할 수 있습니다.

## ✨ 주요 기능

- **즉시 알림**: 텍스트 메시지를 Discord 웹훅으로 전송.
- **간편한 연동**: Claude Desktop 및 Claude Code(CLI) 완벽 지원.
- **오픈소스**: 누구나 기여하고 확장할 수 있는 구조.

## 🚀 퀵 스타트 (Quick Start)

1. **설치 및 의존성 구성**:
   ```bash
   git clone https://github.com/VinylStage/discord-mcp-alert.git
   cd discord-mcp-alert
   poetry install
   ```

2. **설정**:
   `.env` 파일을 생성하고 Webhook URL을 입력합니다.
   ```bash
   echo "DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/..." > .env
   ```

3. **자동 등록**:
   ```bash
   poetry run python scripts/register_mcp.py
   ```
   이 스크립트는 Claude Desktop에 설정을 추가하고, CLI용 등록 명령어를 알려줍니다.

## 📚 문서 (Documentation)

더 자세한 내용은 다음 문서를 참고하세요:

- [📥 설치 가이드 (Installation)](docs/installation.md)
- [⚙️ 설정 및 등록 가이드 (Configuration)](docs/configuration.md)
- [🤝 기여 가이드 (Contributing)](CONTRIBUTING.md)

## 🛠️ 개발 및 테스트

```bash
# 단순 알림 테스트
poetry run python -m discord_mcp_alert.main

# MCP 서버 연동 검증
poetry run python tests/verify_mcp.py
```

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
