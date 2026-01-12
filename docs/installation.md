# 설치 가이드 (Installation Guide)

이 프로젝트는 Python 기반의 MCP 서버입니다. **Mac과 Linux 환경**에서 바로 사용 가능하도록 설계되었습니다.

## 사전 요구 사항

- **운영체제**: Mac 또는 Linux (Windows는 현재 미지원)
- **Python**: 3.10 버전 이상이 필요합니다.
- **Git**: 소스 코드를 다운로드하기 위해 필요합니다.
- **Poetry**: 의존성 관리를 위해 필수입니다.
  ```bash
  curl -sSL https://install.python-poetry.org | python3 -
  ```

## 원클릭 설치 (권장)

가장 간단하고 빠른 설치 방법입니다. 모든 환경 설정을 자동으로 처리합니다.

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
./setup.sh
```

### setup.sh가 자동으로 수행하는 작업:

1. ✅ Poetry 및 Python 환경 검증
2. ✅ 의존성 자동 설치 (`poetry install`)
3. ✅ Discord Webhook URL 대화형 입력
4. ✅ `.env` 파일 자동 생성
5. ✅ 테스트 알림 전송으로 설정 검증
6. ✅ Claude Desktop MCP 자동 등록
7. ✅ Claude Code CLI 등록 명령어 제공

설치가 완료되면 Discord 채널에 테스트 알림이 전송됩니다!

## 수동 설치

세부 설정을 직접 제어하고 싶은 경우 이 방법을 사용하세요.

### 1. 저장소 클론

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
```

### 2. 의존성 설치

```bash
poetry install
```

### 3. 환경 변수 설정

`.env` 파일을 프로젝트 루트에 생성합니다:

```bash
cp .env.example .env
```

`.env` 파일을 편집하여 Discord Webhook URL을 입력:

```env
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your-webhook-id/your-webhook-token
```

**Discord Webhook URL 얻는 방법:**
1. Discord 서버 설정 → 연동 → 웹훅
2. "새 웹훅" 생성
3. URL 복사

### 4. 테스트

```bash
# 기본 알림 테스트
poetry run python -m discord_mcp_alert.main

# MCP 서버 연결 테스트
poetry run python tests/verify_mcp.py

# MCP 도구 테스트
poetry run python tests/test_notify_tool.py
```

### 5. MCP 등록

**Claude Desktop:**
```bash
poetry run python scripts/register_mcp.py
```

**Claude Code CLI (전역 등록):**
```bash
./register_claude_cli.sh
```

또는 수동으로:
```bash
claude mcp add --scope user discord-alert -- bash -c "cd $(pwd) && poetry run python -m discord_mcp_alert.server"
```

**중요**: `--scope user` 옵션으로 전역 등록하면 어느 프로젝트에서든 사용 가능합니다.

## 포터블 설치

프로젝트를 다른 머신으로 이동하거나 복사할 때:

```bash
# 1. 프로젝트 디렉토리를 복사
cp -r discord-mcp-alert /new/location/

# 2. 새 위치로 이동
cd /new/location/discord-mcp-alert

# 3. setup.sh 실행
./setup.sh
```

스크립트가 자동으로 새 위치를 감지하고 설정을 완료합니다. 절대 경로는 자동으로 업데이트됩니다.

## 설치 확인

설치가 제대로 되었는지 확인:

```bash
# MCP 서버 상태 확인
claude mcp list

# 결과 예시:
# discord-alert: bash -c cd "/home/user/discord-mcp-alert" && poetry run python -m discord_mcp_alert.server - ✓ Connected
```

## 문제 해결

### Poetry를 찾을 수 없음
```bash
curl -sSL https://install.python-poetry.org | python3 -
export PATH="$HOME/.local/bin:$PATH"
```

### .env 파일 없음 오류
```bash
cp .env.example .env
# .env 파일을 편집하여 DISCORD_WEBHOOK_URL 입력
```

### MCP 연결 실패
```bash
# MCP 서버 재등록 (전역)
./register_claude_cli.sh

# 또는 수동으로 전역 재등록
claude mcp remove discord-alert
claude mcp add --scope user discord-alert -- bash -c "cd $(pwd) && poetry run python -m discord_mcp_alert.server"
```

## PyPI 설치 (향후 지원 예정)

*현재 준비 중입니다.* 추후 `pip install discord-mcp-alert` 명령어를 지원할 예정입니다.
