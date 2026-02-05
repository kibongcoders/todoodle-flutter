---
name: refactor-cycle
description: 안전한 리팩토링 사이클 (test → refactor → test → commit)
argument-hint: [file_path]
---

# Safe Refactoring Cycle

테스트로 보호된 안전한 리팩토링 워크플로우입니다.

## Pipeline

```
test (기준선) → analyze → refactor → test (검증) → commit
```

## Philosophy

> "리팩토링 전후로 테스트가 통과해야 한다"

리팩토링은 **외부 동작을 변경하지 않으면서** 내부 구조를 개선하는 것입니다.

## Steps

### 1. 기준선 테스트 (Baseline)
```bash
flutter test
```
- 현재 모든 테스트가 통과하는지 확인
- ❌ 실패 시: 리팩토링 전에 먼저 버그 수정 필요

### 2. 정적 분석
```bash
flutter analyze
```
- 현재 코드 상태 파악
- 린트 경고 확인

### 3. 리팩토링 수행
- SOLID 원칙 기반 개선
- **한 번에 하나의 변경만**
- 작은 단위로 점진적 개선

### 4. 검증 테스트
```bash
flutter test
```
- 리팩토링 후 동일한 동작 확인
- ❌ 실패 시: 변경 롤백 또는 수정

### 5. 커밋
- `♻️ refactor(<scope>): <description>` 형식
- 각 리팩토링 단위별로 커밋

## Refactoring Checklist

| 단계 | 확인 |
|------|------|
| 테스트 커버리지 충분? | ☐ |
| 기준선 테스트 통과? | ☐ |
| 한 번에 하나만 변경? | ☐ |
| 검증 테스트 통과? | ☐ |
| 동작 변경 없음? | ☐ |

## Common Refactorings

### 구조 개선
| Before | After | 기법 |
|--------|-------|------|
| 긴 메서드 | 작은 메서드들 | Extract Method |
| 큰 클래스 | 작은 클래스들 | Extract Class |
| 중복 코드 | 공통 메서드 | Extract & Reuse |

### Flutter 특화
| Before | After | 기법 |
|--------|-------|------|
| 거대 Widget | 작은 Widget들 | Extract Widget |
| 복잡한 build() | 분리된 메서드들 | Extract Method |
| 인라인 스타일 | Theme 사용 | Extract Style |

## Arguments

$ARGUMENTS

- 빈 값: 최근 변경 파일 리팩토링
- `lib/path/to/file.dart`: 특정 파일 리팩토링
- `--no-commit`: 커밋 없이 리팩토링만

## 예시

```bash
# 최근 변경 파일 리팩토링
/refactor-cycle

# 특정 파일 리팩토링
/refactor-cycle lib/providers/todo_provider.dart

# 커밋 없이 리팩토링만
/refactor-cycle --no-commit
```

## 주의사항

⚠️ **테스트 없이 리팩토링하지 마세요**
- 테스트가 없는 코드는 먼저 테스트 작성
- `/tdd` 스킬로 테스트 추가 후 리팩토링

⚠️ **큰 변경은 여러 커밋으로**
- 각 리팩토링 단계별로 커밋
- 문제 발생 시 롤백 용이
