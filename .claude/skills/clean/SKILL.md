---
name: clean
description: Flutter 프로젝트 클린 및 재빌드
---

# Flutter Clean

프로젝트를 클린하고 의존성을 다시 설치합니다.

## Instructions

1. **클린 실행**
   ```bash
   flutter clean
   ```

2. **의존성 재설치**
   ```bash
   flutter pub get
   ```

3. **Hive 어댑터 재생성**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **완료 메시지**
   - 클린 완료 알림
