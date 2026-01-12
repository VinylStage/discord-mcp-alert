# 기여 가이드 (Contributing Guide)

이 프로젝트에 기여해주셔서 감사합니다! 프로젝트의 유지보수와 확장을 위한 가이드라인입니다.

## 개발 환경 설정

### 빠른 시작

원클릭 설정 스크립트로 모든 환경을 자동 구성합니다:

```bash
git clone https://github.com/VinylStage/discord-mcp-alert.git
cd discord-mcp-alert
./setup.sh
```

### 수동 설정

1. **저장소 포크 및 클론**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/discord-mcp-alert.git
   cd discord-mcp-alert
   ```

2. **의존성 설치**:
   ```bash
   poetry install
   ```

3. **환경 변수 설정**:
   ```bash
   cp .env.example .env
   # .env 파일을 편집하여 DISCORD_WEBHOOK_URL 입력
   ```

4. **개발 환경 검증**:
   ```bash
   # 기본 알림 테스트
   poetry run python -m discord_mcp_alert.main

   # MCP 서버 연결 테스트
   poetry run python tests/verify_mcp.py

   # MCP 도구 테스트
   poetry run python tests/test_notify_tool.py
   ```

5. **MCP 서버 전역 등록** (선택사항):
   ```bash
   ./register_claude_cli.sh
   ```

   이렇게 하면 모든 프로젝트에서 Discord 알림을 사용할 수 있습니다.

## 코드 스타일 및 규칙

### 일반 규칙

- **언어**: 모든 소스 코드와 주석은 영어로 작성합니다.
- **Docstrings**: 함수와 클래스에는 Google 스타일의 Docstrings를 사용합니다.
- **타입 힌트**: 가능한 모든 함수에 타입 힌트를 추가합니다.
- **PEP 8**: Python 표준 스타일 가이드를 준수합니다.

### 프로젝트 구조

```
discord-mcp-alert/
├── src/
│   └── discord_mcp_alert/
│       ├── __init__.py
│       ├── server.py          # MCP 서버 진입점
│       ├── config.py          # 환경 설정 로드
│       ├── notifier.py        # Discord 알림 로직
│       └── main.py            # 테스트용 진입점
├── tests/
│   ├── verify_mcp.py          # MCP 서버 연결 테스트
│   └── test_notify_tool.py    # MCP 도구 테스트
├── scripts/
│   └── register_mcp.py        # Claude Desktop 등록
├── docs/                      # 문서
├── setup.sh                   # 원클릭 설정 스크립트
├── register_claude_cli.sh     # Claude Code CLI 등록
└── run_server.sh              # MCP 서버 실행
```

### MCP 도구 추가 방법

새로운 MCP 도구를 추가하려면:

1. **로직 구현** (`src/discord_mcp_alert/notifier.py`):
   ```python
   def your_new_function(param: str) -> str:
       """
       Your function description.

       Args:
           param: Parameter description.

       Returns:
           Return value description.
       """
       # Implementation
       pass
   ```

2. **MCP 도구 등록** (`src/discord_mcp_alert/server.py`):
   ```python
   @mcp.tool()
   def your_tool_name(param: str) -> str:
       """
       Tool description for LLM.

       Args:
           param: Parameter description.

       Returns:
           Result description.
       """
       try:
           return your_new_function(param)
       except Exception as e:
           return f"Error: {str(e)}"
   ```

3. **테스트 작성** (`tests/test_your_tool.py`):
   ```python
   import asyncio
   from mcp import ClientSession, StdioServerParameters
   from mcp.client.stdio import stdio_client

   async def test_your_tool():
       # Test implementation
       pass

   if __name__ == "__main__":
       asyncio.run(test_your_tool())
   ```

## 개발 워크플로우

### 1. 브랜치 생성

기능별로 브랜치를 생성합니다:

```bash
git checkout -b feature/your-feature-name
# 또는
git checkout -b fix/bug-description
```

### 2. 코드 수정

코드를 수정하고 로컬에서 테스트합니다:

```bash
# 단위 테스트
poetry run python -m discord_mcp_alert.main

# MCP 서버 테스트
poetry run python tests/verify_mcp.py
poetry run python tests/test_notify_tool.py

# MCP 서버 직접 실행
./run_server.sh
```

### 3. 변경 사항 커밋

커밋 메시지 규칙을 따릅니다:

```bash
git add .
git commit -m "feat: add new feature description"
```

### 4. Pull Request 생성

1. 변경 사항을 포크한 저장소에 푸시:
   ```bash
   git push origin feature/your-feature-name
   ```

2. GitHub에서 Pull Request 생성

3. PR 설명에 다음 내용 포함:
   - 변경 사항 요약
   - 관련 이슈 번호 (있는 경우)
   - 테스트 결과
   - 스크린샷 (UI 변경인 경우)

## 커밋 메시지 규칙

[Conventional Commits](https://www.conventionalcommits.org/) 형식을 따릅니다:

### 타입

- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서만 수정
- `style`: 코드 스타일 변경 (포맷팅, 세미콜론 등)
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `test`: 테스트 추가 또는 수정
- `chore`: 빌드 프로세스, 도구 설정 등

### 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 예시

```bash
# 간단한 커밋
git commit -m "feat: add support for embedded messages"

# 상세한 커밋
git commit -m "fix: resolve .env loading issue

- Add automatic project root detection in config.py
- Update MCP registration to use bash -c wrapper
- Fix working directory issue in MCP server startup

Closes #123"
```

## 테스트 가이드

### 수동 테스트

```bash
# 1. 기본 알림 테스트
poetry run python -m discord_mcp_alert.main

# 2. MCP 서버 연결 확인
poetry run python tests/verify_mcp.py

# 3. MCP 도구 호출 테스트
poetry run python tests/test_notify_tool.py

# 4. Claude Code CLI에서 테스트
claude mcp list  # 연결 확인
# Claude Code CLI에서 notify_discord 도구 사용
```

### 자동 테스트 (향후 추가 예정)

```bash
poetry run pytest
poetry run pytest --cov=src
```

## 포터블 테스트

프로젝트의 포터블 기능을 테스트하려면:

```bash
# 1. 프로젝트를 다른 위치로 복사
cp -r discord-mcp-alert /tmp/test-location

# 2. 새 위치에서 설정
cd /tmp/test-location/discord-mcp-alert
./setup.sh

# 3. 모든 기능 테스트
poetry run python tests/verify_mcp.py
claude mcp list

# 4. 정리
rm -rf /tmp/test-location
```

## 문서 업데이트

코드 변경 시 관련 문서도 함께 업데이트해야 합니다:

- `README.md`: 주요 기능 변경
- `docs/installation.md`: 설치 방법 변경
- `docs/configuration.md`: 설정 방법 변경
- `CHANGELOG.md`: 변경 사항 기록 (자동 생성)

## 코드 리뷰 체크리스트

PR을 제출하기 전에 확인:

- [ ] 코드가 PEP 8 스타일 가이드를 따르는가?
- [ ] 모든 함수에 타입 힌트와 docstring이 있는가?
- [ ] 테스트를 작성하고 통과했는가?
- [ ] 관련 문서를 업데이트했는가?
- [ ] 커밋 메시지가 규칙을 따르는가?
- [ ] `.env` 파일이나 비밀 정보가 포함되지 않았는가?
- [ ] 변경 사항이 Mac과 Linux 모두에서 작동하는가?

## 이슈 보고

버그를 발견했거나 기능을 제안하고 싶다면:

1. [GitHub Issues](https://github.com/VinylStage/discord-mcp-alert/issues)에서 기존 이슈 검색
2. 중복이 없다면 새 이슈 생성
3. 이슈 템플릿을 따라 작성

### 버그 리포트 포함 사항

- 환경 정보 (OS, Python 버전, Poetry 버전)
- 재현 방법
- 예상 동작 vs 실제 동작
- 에러 메시지 (있는 경우)
- 관련 로그

### 기능 제안 포함 사항

- 기능 설명
- 사용 사례
- 예상 동작
- 대안 (고려한 다른 방법)

## 라이선스

기여하는 모든 코드는 프로젝트의 MIT 라이선스 하에 배포됩니다.

## 문의 사항

질문이나 도움이 필요하면:
- GitHub Issues에 질문 이슈 생성
- 프로젝트 메인테이너에게 연락

감사합니다! 🙏
