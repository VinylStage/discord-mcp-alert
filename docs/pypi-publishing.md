# PyPI 배포 가이드 (Trusted Publishing)

이 문서는 GitHub Actions를 통해 PyPI에 패키지를 자동 배포하기 위한 설정 방법을 설명합니다.

## 개요

**Trusted Publishing**은 PyPI에서 제공하는 보안 배포 방식으로, API 토큰 없이 GitHub Actions에서 직접 패키지를 배포할 수 있습니다. OpenID Connect (OIDC)를 사용하여 GitHub와 PyPI 간 신뢰 관계를 설정합니다.

### 장점
- API 토큰을 GitHub Secrets에 저장할 필요 없음
- 더 안전한 인증 방식
- 토큰 만료/갱신 관리 불필요

---

## 사전 준비

- PyPI 계정 ([https://pypi.org](https://pypi.org))
- GitHub 저장소 관리자 권한
- 이미 생성된 `.github/workflows/publish.yml` 워크플로우

---

## 1단계: PyPI Pending Publisher 등록

### 1.1 PyPI 로그인
1. [https://pypi.org](https://pypi.org) 접속
2. 우측 상단 **Log in** 클릭
3. 계정으로 로그인 (없으면 **Register** 클릭하여 생성)

### 1.2 Pending Publisher 추가
1. 로그인 후 우측 상단 계정명 클릭 → **Publishing** 선택
   - 또는 직접 접속: [https://pypi.org/manage/account/publishing/](https://pypi.org/manage/account/publishing/)

2. 페이지 하단의 **"Add a new pending publisher"** 섹션 찾기

3. 다음 정보 입력:

   | 필드 | 값 | 설명 |
   |------|-----|------|
   | **PyPI Project Name** | `discord-mcp-alert` | 배포될 패키지 이름 (pyproject.toml의 name과 동일) |
   | **Owner** | `VinylStage` | GitHub 저장소 소유자 (organization 또는 username) |
   | **Repository name** | `discord-mcp-alert` | GitHub 저장소 이름 |
   | **Workflow name** | `publish.yml` | 배포 워크플로우 파일명 (.github/workflows/ 내) |
   | **Environment name** | `pypi` | GitHub Environment 이름 (선택사항이지만 권장) |

4. **Add** 버튼 클릭

### 1.3 확인
- 등록 후 **"Pending publishers"** 목록에 표시됨
- 첫 배포가 완료되면 자동으로 **"Trusted publishers"** 목록으로 이동

---

## 2단계: GitHub Environment 생성

Environment를 사용하면 배포 전 승인 절차를 추가하거나, 특정 브랜치에서만 배포를 허용할 수 있습니다.

### 2.1 Environment 생성
1. GitHub 저장소로 이동: `https://github.com/VinylStage/discord-mcp-alert`
2. **Settings** 탭 클릭
3. 좌측 메뉴에서 **Environments** 클릭
4. **New environment** 버튼 클릭
5. Name에 `pypi` 입력 (PyPI에서 설정한 Environment name과 정확히 일치해야 함)
6. **Configure environment** 클릭

### 2.2 Environment 보호 규칙 (선택사항)

필요에 따라 다음 보호 규칙을 설정할 수 있습니다:

#### 배포 승인 요구
- **Required reviewers** 활성화
- 승인자 추가 (본인 또는 팀원)
- 배포 전 수동 승인 필요

#### 브랜치 제한
- **Deployment branches** → **Selected branches**
- `main` 또는 `v*` 태그만 허용

#### 대기 시간
- **Wait timer**: 배포 전 대기 시간 설정 (분 단위)

### 2.3 저장
- 설정 완료 후 페이지 상단의 **Save protection rules** 클릭

---

## 3단계: 워크플로우 확인

현재 `.github/workflows/publish.yml` 파일이 올바르게 설정되어 있는지 확인합니다.

```yaml
name: Publish to PyPI

on:
  release:
    types: [published]

permissions:
  contents: read
  id-token: write  # OIDC 토큰 발급에 필요

jobs:
  publish:
    runs-on: ubuntu-latest
    environment:
      name: pypi  # PyPI와 GitHub에서 설정한 이름과 일치
      url: https://pypi.org/p/discord-mcp-alert
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.10"

      - name: Install Poetry
        uses: snok/install-poetry@v1
        with:
          version: latest
          virtualenvs-create: true
          virtualenvs-in-project: true

      - name: Build package
        run: poetry build

      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
```

### 핵심 설정 포인트

| 설정 | 설명 |
|------|------|
| `permissions.id-token: write` | OIDC 토큰 생성 권한 (Trusted Publishing 필수) |
| `environment.name: pypi` | PyPI pending publisher에 등록한 environment name |
| `pypa/gh-action-pypi-publish@release/v1` | PyPI 공식 배포 액션 |

---

## 4단계: 배포 테스트

### 4.1 새 릴리스로 테스트

설정이 완료되면 새 릴리스를 생성하여 테스트합니다.

#### 방법 A: release-please 자동 릴리스
1. Conventional Commit 형식으로 커밋 (`feat:`, `fix:` 등)
2. main 브랜치에 푸시
3. release-please가 자동으로 Release PR 생성
4. PR 머지 시 릴리스 자동 생성 → publish 워크플로우 트리거

#### 방법 B: 수동 릴리스 생성
```bash
# 버전 태그 생성
git tag v0.1.1
git push origin v0.1.1

# GitHub에서 릴리스 생성
gh release create v0.1.1 --generate-notes
```

### 4.2 워크플로우 실행 확인
```bash
# 최근 워크플로우 실행 확인
gh run list --workflow=publish.yml

# 특정 실행 로그 확인
gh run view <run-id> --log
```

### 4.3 PyPI 확인
- 배포 성공 시: [https://pypi.org/project/discord-mcp-alert/](https://pypi.org/project/discord-mcp-alert/)
- 패키지 설치 테스트: `pip install discord-mcp-alert`

---

## 5단계: 기존 v0.1.0 릴리스 재배포 (선택)

현재 v0.1.0 릴리스가 이미 존재하지만 publish 워크플로우가 실행되지 않았습니다.
설정 완료 후 기존 릴리스를 재배포하려면:

### 방법 A: 릴리스 삭제 후 재생성
```bash
# 기존 릴리스 삭제
gh release delete v0.1.0 --yes

# 태그는 유지하고 릴리스만 재생성
gh release create v0.1.0 --generate-notes
```

### 방법 B: 패치 버전으로 새 릴리스
```bash
# pyproject.toml 버전 업데이트 후
git add pyproject.toml
git commit -m "chore: bump version to 0.1.1"
git push origin main

# release-please가 새 릴리스 PR 생성
```

---

## 문제 해결

### "Trusted publisher not found" 오류
- PyPI의 pending publisher 설정 확인
- Owner, Repository name, Workflow name, Environment name이 정확히 일치하는지 확인
- 대소문자 구분에 주의

### "Invalid token" 오류
- `permissions.id-token: write` 설정 확인
- GitHub Actions 워크플로우 권한 설정 확인

### 워크플로우가 트리거되지 않음
- `on: release: types: [published]` 설정 확인
- 릴리스가 draft가 아닌 published 상태인지 확인

### Environment 관련 오류
- GitHub Environment 이름이 PyPI 설정과 일치하는지 확인
- Environment protection rules로 인해 대기 중인지 확인

---

## 참고 자료

- [PyPI Trusted Publishing 공식 문서](https://docs.pypi.org/trusted-publishers/)
- [GitHub OIDC 토큰 문서](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [pypa/gh-action-pypi-publish 저장소](https://github.com/pypa/gh-action-pypi-publish)

---

## 체크리스트

배포 설정 완료 확인용 체크리스트:

- [ ] PyPI 계정 생성/로그인
- [ ] PyPI Pending Publisher 등록
  - [ ] Project Name: `discord-mcp-alert`
  - [ ] Owner: `VinylStage`
  - [ ] Repository: `discord-mcp-alert`
  - [ ] Workflow: `publish.yml`
  - [ ] Environment: `pypi`
- [ ] GitHub Environment `pypi` 생성
- [ ] 테스트 릴리스로 배포 확인
- [ ] PyPI에서 패키지 확인
