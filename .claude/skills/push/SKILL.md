---
name: push
description: Git push to remote
argument-hint: [branch]
---

# Git Push

원격 저장소에 푸시합니다.

## Instructions

1. **현재 브랜치 확인**
   ```bash
   git branch --show-current
   ```

2. **푸시 실행**
   ```bash
   git push origin $ARGUMENTS
   ```
   - $ARGUMENTS가 없으면 현재 브랜치로 푸시

## Arguments

$ARGUMENTS

- 빈 값: 현재 브랜치
- `main`: main 브랜치
- `feature/xxx`: 특정 브랜치
