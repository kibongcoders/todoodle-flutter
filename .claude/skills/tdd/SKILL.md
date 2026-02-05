---
name: tdd
description: 테스트 주도 개발 (RED-GREEN-REFACTOR)
argument-hint: [feature_description]
---

# Test-Driven Development

테스트 주도 개발 방식으로 기능을 구현합니다.

## Instructions

1. **요구사항 분석**
   - $ARGUMENTS에서 기능 설명 확인
   - 테스트 케이스 도출

2. **RED - 실패하는 테스트 작성**
   ```dart
   // test/feature_test.dart
   void main() {
     group('Feature', () {
       test('should do something', () {
         // Arrange
         // Act
         // Assert
         expect(result, expected);
       });
     });
   }
   ```

3. **GREEN - 최소한의 구현**
   - 테스트를 통과하는 최소한의 코드 작성
   - 과도한 구현 금지

4. **REFACTOR - 리팩토링**
   - 중복 제거
   - 코드 품질 개선
   - 테스트는 계속 통과해야 함

5. **검증**
   ```bash
   flutter test $TEST_FILE
   ```

## TDD Cycle

```
┌─────────┐
│   RED   │ ← 실패하는 테스트 작성
└────┬────┘
     ▼
┌─────────┐
│  GREEN  │ ← 테스트 통과하는 최소 구현
└────┬────┘
     ▼
┌─────────┐
│REFACTOR │ ← 코드 개선 (테스트 유지)
└────┬────┘
     │
     └──────→ 반복
```

## Test Patterns

| Pattern | 사용 시점 |
|---------|----------|
| Unit Test | 단일 함수/클래스 테스트 |
| Widget Test | UI 컴포넌트 테스트 |
| Integration Test | 여러 컴포넌트 통합 테스트 |

## Arguments

$ARGUMENTS

구현할 기능 설명 (예: "할일 완료 토글 기능")
