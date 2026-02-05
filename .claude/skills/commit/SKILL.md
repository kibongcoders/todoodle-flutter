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
   git diff  # 상세 변경 내용 확인
   ```

2. **변경사항 스테이징**
   ```bash
   git add -A
   ```

3. **변경 파일 분석 후 커밋 메시지 생성**
   - Subject + Body 형식으로 작성
   - 한국어 사용
   - Claude 서명이나 Co-Authored-By 없이 깔끔하게 작성

4. **커밋 실행** (HEREDOC 사용)
   ```bash
   git commit -m "$(cat <<'EOF'
   <subject>

   <body>
   EOF
   )"
   ```

5. **`--push` 옵션이 있으면 푸시 실행**

## Commit Message Format

### Subject Line (제목)
```
<emoji> <type>(<scope>): <description>
```
- 50자 이내 권장
- 명령형으로 작성 (예: "추가", "수정", "개선")
- 마침표 없이

### Body (본문)
- 빈 줄로 제목과 구분
- **무엇을** 변경했는지 요약
- **왜** 변경했는지 이유 설명
- 변경된 파일/기능 목록 (bullet points)

### Body 작성 가이드

| 섹션 | 내용 |
|------|------|
| 변경 사항 | 주요 변경 내용 나열 |
| 변경 이유 | 왜 이 변경이 필요했는지 |
| 영향 범위 | 어떤 기능/파일에 영향을 주는지 |

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

### 간단한 변경 (1-2개 파일)
```
🐛 fix(calendar): 날짜 선택 시 오프셋 오류 수정

selectedDate가 UTC로 저장되어 로컬 시간과 불일치하는 문제 해결
- DateTime.now().toLocal() 사용하도록 변경
```

### 기능 추가
```
✨ feat(todo): 할일 반복 기능 추가

일간/주간/월간 반복 할일 생성 기능 구현

주요 변경:
- Recurrence 모델 추가 (typeId: 2)
- TodoProvider에 반복 로직 추가
- 반복 설정 UI 다이얼로그 구현

관련 파일:
- lib/models/todo.dart
- lib/providers/todo_provider.dart
- lib/widgets/recurrence_dialog.dart
```

### 리팩토링
```
♻️ refactor(focus): 포모도로 타이머 로직 분리

FocusProvider의 단일 책임 원칙 위반 해결

변경 사항:
- TimerService 클래스 추출
- FocusProvider는 상태 관리만 담당
- 타이머 로직은 TimerService로 위임

영향 범위:
- lib/providers/focus_provider.dart
- lib/services/timer_service.dart (신규)
```

### Subject만 (아주 사소한 변경)
```
🎨 style: 코드 포맷팅
```

## Scopes

`todo`, `focus`, `calendar`, `habits`, `template`, `forest`, `ui`, `db`, `config`, `agent`

## Arguments

$ARGUMENTS

- `--push`: 커밋 후 원격에 푸시
- `-m "message"`: 직접 메시지 지정
