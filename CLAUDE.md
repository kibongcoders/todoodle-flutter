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

## Security Guidelines (Public Repository)

⚠️ **이 프로젝트는 GitHub Public 저장소로 관리됩니다.**

### 커밋 전 보안 체크리스트
- [ ] API 키, 시크릿이 코드에 하드코딩되어 있지 않은가?
- [ ] `.env` 파일이 커밋 대상에 포함되어 있지 않은가?
- [ ] `google-services.json`, `GoogleService-Info.plist`가 포함되어 있지 않은가?
- [ ] keystore, 서명 키 파일이 포함되어 있지 않은가?
- [ ] 개인정보나 테스트 데이터가 포함되어 있지 않은가?

### 민감한 정보 관리 방법

| 정보 유형 | 권장 방법 |
|----------|----------|
| API 키 | `.env` 파일 + `flutter_dotenv` 패키지 |
| Firebase 설정 | `.gitignore`에 자동 제외됨 |
| 앱 서명 키 | `android/key.properties` (자동 제외) |
| 서버 URL | 환경 변수 또는 빌드 flavor 사용 |

### .gitignore에서 자동 제외되는 파일
```
*.env, *.env.*           # 환경 변수
*.jks, *.keystore        # 서명 키
*.pem, *.p12, *.key      # 인증서/키
google-services.json     # Firebase Android
GoogleService-Info.plist # Firebase iOS
key.properties           # Android 서명 설정
android/local.properties # 로컬 SDK 경로
```

### 실수로 민감한 정보를 커밋한 경우
```bash
# 1. 해당 파일을 .gitignore에 추가
# 2. Git 히스토리에서 제거
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch <파일경로>" \
  --prune-empty --tag-name-filter cat -- --all

# 3. 강제 푸시 (주의: 협업 시 팀원과 조율 필요)
git push origin --force --all
```
