# Discord MCP Alert 🔔

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)

> Claude의 모든 작업을 Discord로 알림받는 MCP 서버.
> Claude Desktop / Claude Code / VS Code / Cowork 전체 지원.

---

## ✨ 주요 기능

- **Rich Embed 알림** — 색상·이모지·필드를 갖춘 Discord Embed 박스 포맷
- **다중 클라이언트 지원** — Claude Desktop, Claude Code CLI, VS Code Extension, Claude Cowork
- **자동 Hooks** — Claude Code 작업 완료 시 자동 알림 (별도 요청 없이)
- **이벤트 타입** — success · error · warning · info · start · complete · default

---

## 🚀 설치 (30초)

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
./install.sh
```

`install.sh`가 대화형으로 진행됩니다:
1. Python 환경 자동 준비 (Poetry → uv → pip 순으로 탐색)
2. Discord Webhook URL 입력
3. 등록할 클라이언트 선택 (Claude Desktop / Claude Code / VS Code / Hooks)
4. 자동 설정 및 테스트 알림 전송

---

## 📋 등록 대상

| 번호 | 대상 | 설명 |
|------|------|------|
| 1 | **Claude Desktop** | 앱에서 `notify_discord` 도구 사용 |
| 2 | **Claude Code CLI** | 터미널에서 전역 사용 가능 |
| 3 | **VS Code Extension** | VS Code 내 Claude 채팅에서 사용 |
| 4 | **Claude Code Hooks** | 작업 완료 시 자동 알림 (요청 없이) |
| A | **전체** | 위 모두 선택 |

> Claude Cowork는 별도 설치 없이 자동 지원됩니다.

---

## 💬 사용법

Claude 채팅에서 자연어로 요청합니다:

```
"배포 완료됐다고 Discord에 알려줘"
"에러 발생했다고 Discord error 타입으로 보내줘"
"작업 시작한다고 Discord에 알림 보내줘"
```

또는 도구를 직접 지정:

```
notify_discord 써서 "테스트 완료" success 타입으로 보내줘
```

### event_type 목록

| 값 | 색상 | 이모지 | 사용 상황 |
|----|------|--------|-----------|
| `success` | 🟢 초록 | ✅ | 작업 성공 |
| `error` | 🔴 빨강 | ❌ | 오류 발생 |
| `warning` | 🟡 노랑 | ⚠️ | 주의 필요 |
| `info` | 🔵 파랑 | ℹ️ | 일반 정보 |
| `start` | 🔵 하늘 | 🚀 | 작업 시작 |
| `complete` | 🟢 밝은 초록 | 🎉 | 워크플로우 완료 |
| `default` | ⚫ 회색 | 🔔 | 기타 |

### source 목록

| 값 | 표시명 |
|----|--------|
| `claude_code` | Claude Code (CLI) |
| `claude_desktop` | Claude Desktop |
| `claude_app` | Claude App |
| `claude_cowork` | Claude Cowork |
| `claude_vscode` | Claude (VS Code) |

---

## 🔧 관리 스크립트

| 스크립트 | 설명 |
|----------|------|
| `./install.sh` | 대화형 설치 및 재설치 |
| `./diagnose.sh` | 현재 등록 상태 진단 |
| `./run_server.sh` | MCP 서버 수동 실행 |

---

## 📄 상세 문서

개발자용 수동 설정 및 구조 설명은 [docs/DEVELOPER.md](docs/DEVELOPER.md)를 참조하세요.

---

## 📄 라이선스

MIT License
