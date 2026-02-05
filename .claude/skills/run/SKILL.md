---
name: run
description: Flutter 앱 실행
argument-hint: [platform]
---

# Flutter Run

Flutter 앱을 실행합니다.

## Instructions

1. **의존성 확인**
   ```bash
   flutter pub get
   ```

2. **앱 실행**
   - platform 인자에 따라 실행

## 지원 플랫폼

| Platform | Command |
|----------|---------|
| `macos` (기본) | `flutter run -d macos` |
| `ios` | `flutter run -d ios` |
| `android` | `flutter run -d android` |
| `chrome` | `flutter run -d chrome` |

## Arguments

$ARGUMENTS

- 빈 값 또는 `macos`: macOS에서 실행
- `ios`: iOS 시뮬레이터에서 실행
- `android`: Android 에뮬레이터에서 실행
- `chrome`: 웹 브라우저에서 실행
