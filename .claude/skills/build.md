---
name: build
description: Flutter 앱 빌드 및 실행
---

# Build Skill

프로젝트를 빌드하고 실행합니다.

## Commands

### Quick Run (macOS)
```bash
flutter run -d macos
```

### Full Rebuild
```bash
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter run -d macos
```

### Release Build
```bash
flutter build macos --release
```

## Usage
`/build` - macOS 앱 실행
`/build release` - 릴리즈 빌드
`/build clean` - 클린 후 재빌드
