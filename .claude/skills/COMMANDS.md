# Todoodle CLI Skills Reference

Claude Code에서 사용 가능한 모든 슬래시 커맨드 목록입니다.

## Quick Reference

| Command | Description | Arguments |
|---------|-------------|-----------|
| `/run` | Flutter 앱 실행 | `[platform]` |
| `/build` | Flutter 앱 빌드 | `[platform]` |
| `/test` | 테스트 실행 | `[path]` |
| `/analyze` | 코드 분석 및 린트 검사 | - |
| `/clean` | 프로젝트 클린 및 재빌드 | - |
| `/gen` | Hive 어댑터 코드 생성 | - |
| `/commit` | Conventional Commits 커밋 | `[--push]` |
| `/push` | Git push to remote | `[branch]` |
| `/pr-create` | GitHub PR 자동 생성 | `[base_branch]` |
| `/check` | 코드 품질 검사 | - |
| `/dev` | 개발 완료 워크플로우 | `[--push]` |
| `/submit` | PR 제출 워크플로우 | `<branch-name>` |
| `/review` | 코드 리뷰 수행 | `[file_path]` |
| `/refactor` | SOLID 기반 리팩토링 | `[file_path]` |
| `/refactor-cycle` | 안전한 리팩토링 사이클 | `[file_path]` |
| `/doc` | 코드 문서화 | `[file_path]` |
| `/fix` | 버그 분석 및 수정 | `[error_description]` |
| `/fix-error` | 빌드/런타임 에러 수정 | `[error_message]` |
| `/tdd` | 테스트 주도 개발 | `[feature_description]` |
| `/plan` | 기능 설계 및 구현 계획 | `[feature_name]` |
| `/spec` | 요구사항 및 설계 문서 생성 | `[feature_name]` |
| `/deps` | 의존성 업데이트 확인 | `[--upgrade]` |

---

## Workflows (워크플로우)

### `/check`
코드 품질을 빠르게 확인하는 워크플로우

**Pipeline:** `analyze → test`

```bash
/check
```

### `/dev`
개발 완료 후 코드 품질 확인 및 커밋까지 자동화

**Pipeline:** `analyze → test → commit [→ push]`

```bash
/dev           # 기본 워크플로우
/dev --push    # 푸시까지 포함
```

| Option | Description |
|--------|-------------|
| `--push` | 커밋 후 원격에 푸시 |
| `--skip-test` | 테스트 건너뛰기 |
| `--skip-analyze` | 분석 건너뛰기 |

### `/submit`
기능 개발 완료 후 PR 제출까지 자동화

**Pipeline:** `analyze → test → commit → push → pr-create`

```bash
/submit                        # 현재 브랜치에서 PR 제출
/submit feature/new-filter     # 새 브랜치 생성 후 PR
/submit --draft                # Draft PR로 생성
```

### `/refactor-cycle`
테스트로 보호된 안전한 리팩토링 워크플로우

**Pipeline:** `test (기준선) → analyze → refactor → test (검증) → commit`

```bash
/refactor-cycle                              # 최근 변경 파일
/refactor-cycle lib/providers/todo_provider.dart  # 특정 파일
/refactor-cycle --no-commit                  # 커밋 없이 리팩토링만
```

---

## Flutter Commands (Flutter 명령어)

### `/run`
Flutter 앱 실행

```bash
/run          # macOS (기본)
/run ios      # iOS 시뮬레이터
/run android  # Android 에뮬레이터
/run chrome   # 웹 브라우저
```

### `/build`
Flutter 앱 빌드

```bash
/build             # macOS 빌드 (기본)
/build ios         # iOS 빌드
/build android     # Android APK 빌드
/build appbundle   # Android App Bundle
```

### `/test`
테스트 실행

```bash
/test                         # 전체 테스트
/test test/unit/              # 유닛 테스트만
/test test/widget/            # 위젯 테스트만
/test test/specific_test.dart # 특정 파일
```

### `/analyze`
코드 분석 및 린트 검사

```bash
/analyze
```

### `/clean`
프로젝트 클린 및 의존성 재설치

```bash
/clean
```

**수행 작업:**
1. `flutter clean`
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`

### `/gen`
build_runner로 코드 생성 (Hive TypeAdapter 등)

```bash
/gen
```

**생성 파일:**
- `*.g.dart` - Hive TypeAdapter
- `*.freezed.dart` - Freezed 모델
- `*.gr.dart` - AutoRoute

---

## Git Commands (Git 명령어)

### `/commit`
Conventional Commits + Gitmoji 표준 커밋

```bash
/commit              # 변경사항 커밋
/commit --push       # 커밋 후 푸시
/commit -m "메시지"   # 직접 메시지 지정
```

**Commit Types:**

| Emoji | Type | 사용 시점 |
|:-----:|------|----------|
| ✨ | `feat` | 새 기능 추가 |
| 🐛 | `fix` | 버그 수정 |
| 📝 | `docs` | 문서 변경 |
| 🎨 | `style` | 코드 포맷팅 |
| ♻️ | `refactor` | 코드 리팩토링 |
| ⚡️ | `perf` | 성능 개선 |
| ✅ | `test` | 테스트 추가/수정 |
| 📦 | `build` | 빌드/의존성 변경 |
| 👷 | `ci` | CI 설정 변경 |
| 🔧 | `chore` | 기타 설정 변경 |

**Scopes:** `todo`, `focus`, `calendar`, `habits`, `template`, `forest`, `ui`, `db`, `config`, `agent`

### `/push`
원격 저장소에 푸시

```bash
/push              # 현재 브랜치
/push main         # main 브랜치
/push feature/xxx  # 특정 브랜치
```

### `/pr-create`
GitHub Pull Request 자동 생성

```bash
/pr-create          # main 브랜치로 PR
/pr-create develop  # develop 브랜치로 PR
```

---

## Code Quality (코드 품질)

### `/review`
Flutter 코드 리뷰 수행

```bash
/review                              # 최근 변경 파일
/review lib/providers/todo_provider.dart  # 특정 파일
```

**체크리스트:**
- `const` 생성자 사용 여부
- Null safety 처리
- Widget 트리 최적화
- Provider 패턴 준수
- Hive TypeId 고유성
- 메모리 누수 (dispose)

### `/refactor`
SOLID 원칙에 따라 코드 리팩토링

```bash
/refactor                              # 최근 변경 파일
/refactor lib/providers/todo_provider.dart  # 특정 파일
```

**SOLID Checklist:**

| 원칙 | 확인 사항 |
|------|----------|
| **S**RP | 클래스가 하나의 책임만 가지는가? |
| **O**CP | 확장에 열려있고 수정에 닫혀있는가? |
| **L**SP | 하위 타입이 상위 타입을 대체할 수 있는가? |
| **I**SP | 인터페이스가 필요한 것만 노출하는가? |
| **D**IP | 추상화에 의존하는가? |

### `/doc`
Dart/Flutter 코드에 dartdoc 주석 추가

```bash
/doc                              # 최근 변경 파일
/doc lib/providers/todo_provider.dart  # 특정 파일
```

---

## Problem Solving (문제 해결)

### `/fix`
버그 분석 및 수정

```bash
/fix "Null check operator used on null"
/fix "setState 호출 시 에러 발생"
```

### `/fix-error`
빌드/런타임 에러 분석 및 자동 수정

```bash
/fix-error                    # 빌드하여 에러 수집
/fix-error "에러 메시지"        # 특정 에러 수정
```

**Common Errors:**

| Error | Solution |
|-------|----------|
| `Undefined name` | import 추가 또는 오타 수정 |
| `HiveError: TypeAdapter exists` | TypeId 충돌 해결 |
| `Null check operator` | null 체크 또는 기본값 |
| `setState after dispose` | mounted 체크 추가 |

---

## Development Methods (개발 방법론)

### `/tdd`
테스트 주도 개발 (RED-GREEN-REFACTOR)

```bash
/tdd "할일 완료 토글 기능"
```

**TDD Cycle:**
```
RED → GREEN → REFACTOR → (반복)
```

1. **RED** - 실패하는 테스트 작성
2. **GREEN** - 테스트 통과하는 최소 구현
3. **REFACTOR** - 코드 개선 (테스트 유지)

---

## Planning (기획/설계)

### `/plan`
새 기능의 설계 및 구현 계획 작성

```bash
/plan cloud-sync
/plan ai-recommendation
```

### `/spec`
기능 명세서 단계별 작성

```bash
/spec cloud-sync
/spec push-notification
```

**Output Files:**
| Phase | Output |
|-------|--------|
| 1 | `docs/[feature]/requirements.md` |
| 2 | `docs/[feature]/design.md` |
| 3 | `docs/[feature]/tasks.md` |

---

## Utilities (유틸리티)

### `/deps`
프로젝트 의존성 확인 및 관리

```bash
/deps            # 의존성 상태 확인
/deps --upgrade  # 의존성 업그레이드
```

---

## Recommended Workflows

### 일반 개발 흐름
```bash
# 1. 코드 작성
# 2. 품질 검사
/check

# 3. 커밋 및 푸시
/dev --push
```

### 새 기능 개발
```bash
# 1. 설계
/plan feature-name

# 2. TDD로 구현
/tdd "기능 설명"

# 3. 코드 리뷰
/review

# 4. PR 제출
/submit feature/feature-name
```

### 리팩토링
```bash
# 안전한 리팩토링 사이클
/refactor-cycle lib/path/to/file.dart
```

### 에러 해결
```bash
# 빌드 에러 자동 수정
/fix-error

# 특정 버그 수정
/fix "에러 설명"
```
