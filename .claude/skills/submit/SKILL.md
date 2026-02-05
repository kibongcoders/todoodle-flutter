---
name: submit
description: PR 제출 워크플로우 (check → commit → push → pr-create)
argument-hint: <branch-name>
---

# Submit Workflow

기능 개발 완료 후 PR 제출까지 자동화된 워크플로우입니다.

## Pipeline

```
analyze → test → commit → push → pr-create
```

## Steps

### 1. 코드 품질 검사
```bash
flutter analyze
flutter test
```

### 2. 변경사항 커밋
- Gitmoji + Conventional Commits 형식
- 모든 변경사항 스테이징 및 커밋

### 3. 원격에 푸시
```bash
git push -u origin <current-branch>
```

### 4. PR 생성
```bash
gh pr create --title "..." --body "..."
```
- 커밋 메시지 기반 PR 제목 생성
- 변경사항 요약 본문 자동 생성

## 중단 조건

| 단계 | 중단 조건 |
|------|----------|
| analyze | 에러 발견 시 |
| test | 테스트 실패 시 |
| commit | 변경사항 없을 시 |
| push | 원격 충돌 시 |
| pr-create | PR 이미 존재 시 |

## Arguments

$ARGUMENTS

- `<branch-name>`: 새 브랜치 생성 후 작업 (선택)
- `--draft`: Draft PR로 생성
- `--skip-test`: 테스트 건너뛰기

## 예시

```bash
# 현재 브랜치에서 PR 제출
/submit

# 새 브랜치 생성 후 PR 제출
/submit feature/new-todo-filter

# Draft PR로 제출
/submit --draft
```
