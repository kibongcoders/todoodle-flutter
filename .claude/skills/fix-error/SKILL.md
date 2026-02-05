---
name: fix-error
description: 빌드/런타임 에러 분석 및 수정
argument-hint: [error_message]
---

# Error Fix

빌드 또는 런타임 에러를 분석하고 자동으로 수정합니다.

## Instructions

1. **에러 수집**
   - $ARGUMENTS에서 에러 메시지 확인
   - 또는 빌드 실행하여 에러 수집
   ```bash
   flutter build macos 2>&1 | head -100
   ```

2. **에러 분석**
   - 에러 타입 식별
   - 관련 파일 및 라인 확인
   - 근본 원인 파악

3. **수정 적용**
   - 최소한의 변경으로 수정
   - 연관 에러 함께 처리

4. **검증**
   ```bash
   flutter analyze
   flutter build macos
   ```

## Common Errors & Solutions

### Build Errors

| Error | Solution |
|-------|----------|
| `Undefined name` | import 추가 또는 오타 수정 |
| `The argument type X can't be assigned to Y` | 타입 캐스팅 또는 변환 |
| `Missing concrete implementation` | 추상 메서드 구현 |
| `The method X isn't defined` | 메서드 추가 또는 import 확인 |

### Runtime Errors

| Error | Solution |
|-------|----------|
| `Null check operator used on null` | null 체크 또는 기본값 |
| `setState() called after dispose()` | mounted 체크 추가 |
| `RenderFlex overflowed` | Expanded/Flexible 또는 SingleChildScrollView |
| `Could not find Provider` | MultiProvider 등록 확인 |

### Hive Errors

| Error | Solution |
|-------|----------|
| `HiveError: TypeAdapter exists` | TypeId 충돌 해결 (CLAUDE.md 참조) |
| `Box not found` | Hive.openBox 호출 확인 |
| `HiveError: Cannot write` | Box가 열려있는지 확인 |

## Arguments

$ARGUMENTS

에러 메시지 또는 에러 설명 (빈 값이면 빌드하여 에러 수집)
