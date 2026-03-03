# Discord MCP Alert 🔔

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)

> **Discord MCP Alert**는 LLM(Claude 등)이 직접 Discord 채널로 알림을 보낼 수 있게 해주는 [MCP(Model Context Protocol)](https://modelcontextprotocol.io) 서버입니다.

간단한 설정만으로 AI 에이전트가 작업 완료, 에러 발생, 요약 정보 등을 개발자에게 즉시 전달할 수 있습니다.

## ✨ 주요 기능

- **즉시 알림**: 텍스트 메시지를 Discord 웹훅으로 전송.
- **간편한 연동**: Claude Desktop 및 Claude Code(CLI) 완벽 지원.
- **크로스플랫폼**: Windows, Mac, Linux 모두 지원.
- **오픈소스**: 누구나 기여하고 확장할 수 있는 구조.

## 🚀 퀵 스타트 (Quick Start)

Python 3.10+이 설치되어 있다면 **OS에 관계없이** 동일한 명령어로 설치합니다:

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
python install.py
```

`install.py`가 자동으로 수행하는 작업:
- ✅ OS 자동 감지 (Windows / macOS / Linux)
- ✅ 패키지 매니저 자동 감지 (Poetry 또는 pip + venv)
- ✅ 의존성 설치 및 Discord Webhook URL 설정
- ✅ 테스트 알림 전송으로 설정 검증
- ✅ Claude Desktop 및 Claude Code CLI 자동 등록

> **패키지 매니저**: Poetry를 권장합니다. Poetry가 없으면 pip + venv를 자동으로 사용합니다 (pip는 반드시 editable install `-e .` 방식이어야 합니다).

### 플랫폼별 스크립트 (Poetry 전용 대안)

**Mac/Linux:**
```bash
./setup.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

### Claude Code CLI 전역 등록 (수동)

**한 번 등록하면 모든 프로젝트에서 사용 가능합니다!**

```bash
claude mcp add --scope user discord-alert -- poetry --directory "/path/to/discord-mcp-alert" run python -m discord_mcp_alert.server
```

**중요**: `--scope user` 옵션으로 전역 등록하면 어느 프로젝트에서든 Discord 알림을 보낼 수 있습니다.

## 📚 문서 (Documentation)

더 자세한 내용은 다음 문서를 참고하세요:

- [📥 설치 가이드 (Installation)](docs/installation.md)
- [⚙️ 설정 및 등록 가이드 (Configuration)](docs/configuration.md)
- [🤝 기여 가이드 (Contributing)](CONTRIBUTING.md)

## 🛠️ 개발 및 테스트

**Mac/Linux:**
```bash
# MCP 서버 실행
./run_server.sh
```

**Windows:**
```powershell
# MCP 서버 실행
.\run_server.ps1
```

**공통 (Poetry):**
```bash
# 단순 알림 테스트
poetry run python -m discord_mcp_alert.main

# MCP 서버 연동 검증
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

## 🌍 포터블 배포 (Portable Deployment)

이 프로젝트는 **어떤 환경에서든 즉시 작동**하도록 설계되었습니다:

- ✅ **절대 경로 자동 감지**: 스크립트가 자동으로 프로젝트 위치를 찾습니다
- ✅ **환경 검증**: 필수 요구사항을 실행 전에 자동으로 확인합니다
- ✅ **보안**: `.env` 파일은 Git에서 제외되어 안전하게 관리됩니다
- ✅ **원클릭 설정**: `python install.py` 하나로 모든 OS에서 설정 완료

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
