# Todoodle - Flutter Todo App

## Project Overview
Todoodle은 Flutter로 개발된 할일 관리 앱입니다. 습관 트래커, 포모도로 타이머, 숲 꾸미기 게이미피케이션 기능을 포함합니다.

## Tech Stack
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Database**: Hive
- **Notifications**: flutter_local_notifications
- **Speech Recognition**: speech_to_text
- **Calendar**: table_calendar

## Project Structure

### Current Structure (MVVM-like)
```
lib/
├── main.dart                 # 앱 진입점, Provider 설정
├── models/                   # Hive 데이터 모델
│   ├── todo.dart            # 할일 모델 (typeId: 0-2)
│   ├── category.dart        # 카테고리 모델 (typeId: 3)
│   ├── plant.dart           # 식물 모델 (typeId: 4-5)
│   ├── focus_session.dart   # 집중 세션 (typeId: 6-7)
│   └── template.dart        # 템플릿 모델 (typeId: 8-9)
├── providers/               # 상태 관리
├── screens/                 # UI 화면
├── services/                # 비즈니스 로직
└── widgets/                 # 재사용 위젯
```

### Target Structure (Clean Architecture + Feature-First)
```
lib/
├── core/                           # 공통 모듈
│   ├── constants/                  # 상수
│   ├── errors/                     # 에러 클래스
│   ├── utils/                      # 유틸리티
│   └── di/                         # 의존성 주입 (get_it)
│
├── features/                       # Feature-First 구조
│   ├── todo/
│   │   ├── data/                   # 데이터 레이어
│   │   │   ├── datasources/        # Hive, API 접근
│   │   │   ├── models/             # Hive 모델
│   │   │   └── repositories/       # Repository 구현
│   │   ├── domain/                 # 도메인 레이어 (선택)
│   │   │   ├── entities/           # 비즈니스 객체
│   │   │   ├── repositories/       # Repository 인터페이스
│   │   │   └── usecases/           # 비즈니스 로직
│   │   └── presentation/           # 프레젠테이션 레이어
│   │       ├── providers/          # ChangeNotifier
│   │       ├── pages/              # 화면
│   │       └── widgets/            # 컴포넌트
│   │
│   ├── focus/                      # 포모도로 기능
│   ├── habits/                     # 습관 트래커
│   └── templates/                  # 템플릿 기능
│
├── shared/                         # 공유 컴포넌트
│   ├── widgets/
│   ├── themes/
│   └── extensions/
│
└── main.dart
```

### Layer Responsibilities
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  - Pages (UI)                                                │
│  - Providers (UI State)                                      │
│  - Widgets (Components)                                      │
├─────────────────────────────────────────────────────────────┤
│                      Domain Layer (선택)                     │
│  - Entities (비즈니스 객체)                                  │
│  - UseCases (비즈니스 로직)                                  │
│  - Repository Interfaces                                     │
├─────────────────────────────────────────────────────────────┤
│                       Data Layer                             │
│  - Models (Hive/API)                                         │
│  - DataSources (Hive Box, API Client)                        │
│  - Repository Implementations                                │
└─────────────────────────────────────────────────────────────┘
```

### When to Add Domain Layer
| 조건 | Domain Layer 필요? |
|------|-------------------|
| 간단한 CRUD | ❌ No |
| 복잡한 비즈니스 로직 | ✅ Yes |
| 여러 Provider에서 로직 재사용 | ✅ Yes |
| 단위 테스트 분리 필요 | ✅ Yes |

## Coding Conventions

### Dart/Flutter Style
- 한국어 주석 사용
- `const` 생성자 적극 활용
- Provider로 상태 관리 (ChangeNotifier)
- Hive TypeAdapter는 build_runner로 자동 생성

### Hive TypeId Registry
| TypeId | Model |
|--------|-------|
| 0 | Todo |
| 1 | Priority |
| 2 | Recurrence |
| 3 | TodoCategoryModel |
| 4 | PlantType |
| 5 | Plant |
| 6 | FocusSessionType |
| 7 | FocusSession |
| 8 | TodoTemplate |
| 9 | TemplateItem |

**새 모델 추가 시 typeId 10부터 사용**

### Import Order
1. dart:* (core libraries)
2. package:flutter/*
3. package:* (third-party)
4. Relative imports (../*)

### Naming Conventions
- Files: snake_case (e.g., `todo_provider.dart`)
- Classes: PascalCase (e.g., `TodoProvider`)
- Variables/Functions: camelCase (e.g., `addTodo`)
- Constants: camelCase or SCREAMING_SNAKE_CASE

## Common Commands

### Development
```bash
# 의존성 설치
flutter pub get

# Hive 어댑터 생성
dart run build_runner build --delete-conflicting-outputs

# macOS 앱 실행
flutter run -d macos

# 빌드
flutter build macos --release

# 분석
flutter analyze
```

### Git
```bash
# 커밋 메시지 형식
git commit -m "feat: 기능 설명"
git commit -m "fix: 버그 수정"
git commit -m "refactor: 리팩토링"
```

## Platform Requirements
- macOS: 11.0+ (Podfile, project.pbxproj)
- iOS: 12.0+
- Android: minSdkVersion 21

## Known Issues & Solutions

### flutter_local_notifications Priority 충돌
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Priority;
```

### speech_to_text deprecated 파라미터
```dart
await _speech.listen(
  listenOptions: SpeechListenOptions(
    listenMode: ListenMode.dictation,
    cancelOnError: true,
    partialResults: true,
  ),
);
```

## Features Roadmap
- [x] Phase 1: 기본 할일 CRUD
- [x] Phase 2: 캘린더, 반복, 알림
- [x] Phase 3: 포모도로, 자연어, 템플릿
- [ ] Phase 4: 클라우드 동기화
- [ ] Phase 5: AI 추천, 위젯
