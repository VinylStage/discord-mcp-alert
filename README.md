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

> **Mac과 Linux 환경에서 바로 사용 가능합니다!**

### 원클릭 설치 (권장)

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
./setup.sh
```

`setup.sh` 스크립트가 자동으로:
- ✅ Poetry 및 Python 환경 검증
- ✅ 의존성 설치
- ✅ Discord Webhook URL 설정
- ✅ 테스트 알림 전송
- ✅ Claude Desktop 자동 등록
- ✅ Claude Code CLI 등록 명령어 제공

### Claude Code CLI 전역 등록

**한 번 등록하면 모든 프로젝트에서 사용 가능합니다!**

```bash
./register_claude_cli.sh
```

또는 수동으로:

```bash
claude mcp add --scope user discord-alert -- bash -c "cd $(pwd) && poetry run python -m discord_mcp_alert.server"
```

**중요**: `--scope user` 옵션으로 전역 등록하면 어느 프로젝트에서든 Discord 알림을 보낼 수 있습니다.

### 수동 설치 (옵션)

1. **의존성 설치**:
   ```bash
   poetry install
   ```

2. **환경 변수 설정**:
   ```bash
   cp .env.example .env
   # .env 파일을 열어 Discord Webhook URL 입력
   ```

3. **MCP 등록**:
   ```bash
   poetry run python scripts/register_mcp.py
   ```

## 📚 문서 (Documentation)

더 자세한 내용은 다음 문서를 참고하세요:

- [📥 설치 가이드 (Installation)](docs/installation.md)
- [⚙️ 설정 및 등록 가이드 (Configuration)](docs/configuration.md)
- [🤝 기여 가이드 (Contributing)](CONTRIBUTING.md)

## 🛠️ 개발 및 테스트

```bash
# MCP 서버 실행
./run_server.sh

# 단순 알림 테스트
poetry run python -m discord_mcp_alert.main

# MCP 서버 연동 검증
poetry run python tests/verify_mcp.py

# MCP 도구 테스트
poetry run python tests/test_notify_tool.py
```

## 🌍 포터블 배포 (Portable Deployment)

이 프로젝트는 **어떤 Mac/Linux 환경에서든 즉시 작동**하도록 설계되었습니다:

- ✅ **절대 경로 자동 감지**: 스크립트가 자동으로 프로젝트 위치를 찾습니다
- ✅ **환경 검증**: 필수 요구사항을 실행 전에 자동으로 확인합니다
- ✅ **보안**: `.env` 파일은 Git에서 제외되어 안전하게 관리됩니다
- ✅ **원클릭 설정**: `setup.sh` 하나로 모든 설정 완료

### 다른 머신으로 이동하는 방법

```bash
# 1. 프로젝트 복사 (Git 또는 직접 복사)
git clone https://github.com/VinylStage/discord-mcp-alert.git

# 2. 설치 스크립트 실행
cd discord-mcp-alert
./setup.sh

# 끝! 바로 사용 가능합니다.
```

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
