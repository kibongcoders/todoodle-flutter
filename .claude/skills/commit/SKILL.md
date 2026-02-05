---
name: commit
description: Conventional Commits 표준으로 변경사항을 커밋합니다
argument-hint: [--push]
---

# Git Commit

Conventional Commits + Gitmoji 표준에 따라 변경사항을 커밋합니다.

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
   - 형식: `<emoji> <type>(<scope>): <description>`
   - 한국어 description 사용
   - Claude 서명이나 Co-Authored-By 없이 깔끔하게 작성

4. **커밋 실행** (Claude 서명 없이)

5. **`--push` 옵션이 있으면 푸시 실행**

## Commit Types with Gitmoji

| Emoji | Type | 사용 시점 |
|:-----:|------|----------|
| ✨ | `feat` | 새 기능 추가 |
| 🐛 | `fix` | 버그 수정 |
| 📝 | `docs` | 문서 변경 |
| 🎨 | `style` | 코드 포맷팅, 세미콜론 누락 등 |
| ♻️ | `refactor` | 코드 리팩토링 |
| ⚡️ | `perf` | 성능 개선 |
| ✅ | `test` | 테스트 추가/수정 |
| 📦 | `build` | 빌드/의존성 변경 |
| 👷 | `ci` | CI 설정 변경 |
| 🔧 | `chore` | 기타 설정 변경 |

### 추가 이모지

| Emoji | 사용 시점 |
|:-----:|----------|
| 🔥 | 코드/파일 삭제 |
| 🚑 | 긴급 핫픽스 |
| 💄 | UI/스타일 변경 |
| 🎉 | 프로젝트 시작 |
| 🔒 | 보안 이슈 수정 |
| 🚀 | 배포 관련 |
| 💚 | CI 빌드 수정 |
| ⬇️ | 의존성 다운그레이드 |
| ⬆️ | 의존성 업그레이드 |
| 🔀 | 브랜치 머지 |
| 🏷️ | 타입 정의 추가/수정 |
| 🗃️ | DB 관련 변경 |
| 🌐 | 다국어/i18n |
| 💬 | 텍스트/문구 수정 |
| 🍱 | 에셋 추가/업데이트 |

## 예시

```
✨ feat(todo): 할일 반복 기능 추가
🐛 fix(calendar): 날짜 선택 오류 수정
♻️ refactor(focus): 포모도로 로직 개선
📝 docs: README 업데이트
⚡️ perf(db): Hive 쿼리 최적화
🔧 chore(agent): 스킬 설정 변경
```

## Scopes

`todo`, `focus`, `calendar`, `habits`, `template`, `forest`, `ui`, `db`, `config`, `agent`

## Arguments

$ARGUMENTS

- `--push`: 커밋 후 원격에 푸시
- `-m "message"`: 직접 메시지 지정
