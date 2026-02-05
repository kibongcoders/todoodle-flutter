---
name: gen
description: Hive 어댑터 및 코드 생성 (build_runner)
---

# Code Generation

build_runner를 사용해 코드를 생성합니다.

## Instructions

1. **코드 생성 실행**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **생성된 파일 확인**
   - `.g.dart` 파일들이 정상 생성되었는지 확인

## 생성되는 파일

- `*.g.dart` - Hive TypeAdapter
- `*.freezed.dart` - Freezed 모델 (사용 시)
- `*.gr.dart` - AutoRoute (사용 시)
