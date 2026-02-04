---
name: review
description: 코드 리뷰 수행
disable-model-invocation: true
argument-hint: [file_path]
---

# Code Review

Flutter 코드 리뷰를 수행합니다.

## Instructions

1. **파일 읽기**
   - $ARGUMENTS로 지정된 파일 또는 최근 변경 파일 읽기

2. **리뷰 체크리스트**
   - [ ] `const` 생성자 사용 여부
   - [ ] Null safety 처리
   - [ ] Widget 트리 최적화
   - [ ] Provider 패턴 준수
   - [ ] Hive TypeId 고유성
   - [ ] 메모리 누수 (dispose)

3. **리뷰 결과 출력**
   - Issues Found (Critical/Warning/Info)
   - Good Practices
   - Recommendations

## Arguments

$ARGUMENTS

- 빈 값: 최근 변경 파일 리뷰
- `lib/path/to/file.dart`: 특정 파일 리뷰
