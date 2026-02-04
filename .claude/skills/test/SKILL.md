---
name: test
description: Flutter 테스트 실행
disable-model-invocation: true
argument-hint: [path]
---

# Flutter Test

테스트를 실행합니다.

## Instructions

1. **테스트 실행**
   ```bash
   flutter test $ARGUMENTS
   ```

2. **결과 분석**
   - 실패한 테스트 확인
   - 에러 메시지 분석

## Arguments

$ARGUMENTS

- 빈 값: 전체 테스트 실행
- `test/unit/`: 유닛 테스트만
- `test/widget/`: 위젯 테스트만
- `test/specific_test.dart`: 특정 테스트 파일
