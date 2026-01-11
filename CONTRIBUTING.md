# 기여 가이드 (Contributing Guide)

이 프로젝트에 기여해주셔서 감사합니다! 프로젝트의 유지보수와 확장을 위한 가이드라인입니다.

## 개발 환경 설정

1. 프로젝트 의존성 설치:
   ```bash
   poetry install
   ```
2. Git Hook 또는 린트 도구는 향후 추가될 예정입니다. 기본적으로 PEP 8 스타일 가이드를 준수합니다.

## 코드 스타일 및 규칙

- **언어**: 모든 소스 코드는 영어로 작성합니다.
- **Docstrings**: 함수와 클래스에는 Google 스타일의 Docstrings를 사용합니다.
- **MCP 도구 추가**:
  - 새로운 기능은 `src/notifier.py`에 로직을 구현합니다.
  - `src/server.py`에서 `@mcp.tool()` 데코레이터를 사용하여 LLM이 사용할 수 있도록 등록합니다.

## 수정 및 기능 추가 절차

1. 새로운 브랜치를 생성합니다 (`feature/your-feature-name`).
2. 코드를 수정하고 테스트를 진행합니다 (`src/main.py` 활용).
3. 변경 사항을 커밋합니다. 커밋 메시지는 아래의 규칙을 따릅니다.

## 커밋 메시지 규칙

커밋 메시지는 다음과 같은 형식을 권장합니다:
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `refactor`: 코드 리팩토링
- `chore`: 빌드 업무, 패키지 매니저 설정 등

예시: `feat: add support for embedded messages in discord notification`

## 문의 사항

수정이 필요하거나 질문이 있다면 이슈를 생성해 주세요.
