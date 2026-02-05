---
name: pr-create
description: GitHub PR 자동 생성
argument-hint: [base_branch]
---

# Pull Request Creation

GitHub Pull Request를 자동으로 생성합니다.

## Instructions

1. **현재 상태 확인**
   ```bash
   git status
   git log origin/main..HEAD --oneline
   git diff origin/main --stat
   ```

2. **변경사항 분석**
   - 커밋 히스토리 분석
   - 변경된 파일 목록 확인
   - 변경 유형 파악 (feat/fix/refactor 등)

3. **PR 정보 생성**
   - 제목: 변경 유형 + 요약 (70자 이내)
   - 본문: Summary, Changes, Test Plan

4. **PR 생성**
   ```bash
   gh pr create --title "제목" --body "본문" --base $BASE_BRANCH
   ```

## PR Template

```markdown
## Summary
<!-- 변경 사항 요약 (1-3 문장) -->

## Changes
<!-- 주요 변경 내용 -->
- 변경 1
- 변경 2

## Test Plan
<!-- 테스트 방법 -->
- [ ] 테스트 1
- [ ] 테스트 2

## Screenshots
<!-- UI 변경 시 스크린샷 첨부 -->
```

## PR Title Format

```
<type>(<scope>): <description>

예시:
feat(todo): 할일 우선순위 기능 추가
fix(calendar): 날짜 선택 버그 수정
refactor(provider): TodoProvider 최적화
```

## Arguments

$ARGUMENTS

- 빈 값: `main` 브랜치로 PR 생성
- `develop`: develop 브랜치로 PR 생성
