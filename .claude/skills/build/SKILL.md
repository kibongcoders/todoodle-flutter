---
name: build
description: Flutter 앱 빌드 (macOS, iOS, Android)
argument-hint: [platform]
---

# Flutter Build

Flutter 앱을 빌드합니다.

## Instructions

1. **의존성 설치**
   ```bash
   flutter pub get
   ```

2. **Hive 어댑터 생성**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **빌드 실행**
   - platform 인자에 따라 빌드

## 지원 플랫폼

| Platform | Command |
|----------|---------|
| `macos` (기본) | `flutter build macos --release` |
| `ios` | `flutter build ios --release` |
| `android` | `flutter build apk --release --split-per-abi` |
| `appbundle` | `flutter build appbundle --release` |

## Arguments

$ARGUMENTS

- 빈 값 또는 `macos`: macOS 빌드
- `ios`: iOS 빌드
- `android`: Android APK 빌드
- `appbundle`: Android App Bundle 빌드
