---
name: commit
description: Conventional Commits 표준으로 변경사항을 커밋합니다
argument-hint: [--push]
---

# Git Commit

Conventional Commits 표준에 따라 변경사항을 커밋합니다.

## Instructions

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
   - Conventional Commits 형식: `<type>(<scope>): <description>`
   - 한국어 description 사용

4. **커밋 실행**

5. **`--push` 옵션이 있으면 푸시 실행**

## Commit Types

| Type | 사용 시점 |
|------|----------|
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `style` | 포맷팅 |
| `refactor` | 리팩토링 |
| `perf` | 성능 개선 |
| `test` | 테스트 |
| `build` | 빌드/의존성 |
| `ci` | CI 설정 |
| `chore` | 기타 |

## Scopes

`todo`, `focus`, `calendar`, `habits`, `template`, `forest`, `ui`, `db`, `config`, `agent`

## Arguments

$ARGUMENTS

- `--push`: 커밋 후 원격에 푸시
- `-m "message"`: 직접 메시지 지정
