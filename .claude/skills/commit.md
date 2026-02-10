---
name: commit
description: Conventional Commits 표준으로 변경사항을 커밋합니다. /commit 또는 /commit --push로 실행
---

# Git Commit Skill

`/commit` 명령어로 Conventional Commits 표준에 따라 자동 커밋합니다.

## Instructions

이 스킬이 실행되면 다음을 수행하세요:

1. **변경사항 확인**
   ```bash
   git status
   git diff --stat
   ```

2. **변경사항 스테이징**
   ```bash
   git add -A
   ```

3. **변경 파일 분석 후 적절한 커밋 메시지 생성**
   - Conventional Commits 형식 사용
   - 한국어 description 권장

4. **커밋 실행**
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <description>

   <body>
   )"
   ```

5. **`--push` 옵션이 있으면 푸시**
   ```bash
   git push origin <current-branch>
   ```

## Commit Types

| Type | 사용 시점 |
|------|----------|
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `style` | 포맷팅 (코드 의미 변경 없음) |
| `refactor` | 리팩토링 |
| `perf` | 성능 개선 |
| `test` | 테스트 추가/수정 |
| `build` | 빌드/의존성 변경 |
| `ci` | CI 설정 변경 |
| `chore` | 기타 변경 |

## Project Scopes

| Scope | 영역 |
|-------|------|
| `todo` | 할일 기능 |
| `focus` | 포모도로/집중 모드 |
| `calendar` | 캘린더 |
| `habits` | 습관 트래커 |
| `template` | 템플릿 |
| `forest` | 숲 꾸미기 |
| `ui` | UI 컴포넌트 |
| `db` | Hive 데이터베이스 |
| `config` | 설정/구성 |
| `agent` | Claude 에이전트/스킬 |

## Type 선택 가이드

변경된 파일을 분석해서 type을 결정:

| 변경 내용 | Type |
|----------|------|
| 새 기능/화면 추가 | `feat` |
| 버그 수정 | `fix` |
| README, CLAUDE.md 등 | `docs` |
| .claude/ 폴더 변경 | `chore(agent)` |
| pubspec.yaml 변경 | `build` |
| 테스트 파일 | `test` |
| 코드 정리 (기능 변경 없음) | `refactor` |

## 커밋 메시지 예시

### 기능 추가
```
feat(todo): 할일 우선순위 정렬 기능 추가

- 높음/중간/낮음 순으로 정렬
- 설정에 정렬 상태 저장
```

### 버그 수정
```
fix(calendar): 월말 날짜 계산 오류 수정

윤년 처리 로직 추가
```

### 문서/설정
```
docs: CLAUDE.md에 Clean Architecture 가이드 추가
```

### 에이전트/스킬
```
chore(agent): git-committer 에이전트 및 commit 스킬 추가

- Conventional Commits 표준 적용
- /commit 명령어로 자동 커밋
```

## 옵션

| 명령어 | 동작 |
|--------|------|
| `/commit` | 변경사항 커밋 |
| `/commit --push` | 커밋 + 푸시 |
| `/commit -m "msg"` | 지정 메시지로 커밋 |
