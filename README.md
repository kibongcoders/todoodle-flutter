# Todoodle 🌿

할일 관리 + 습관 트래커 + 포모도로 타이머가 결합된 Flutter 앱입니다.
할일을 완료하면 나만의 숲이 자라나는 게이미피케이션 요소가 포함되어 있습니다.

## ✨ 주요 기능

### 📝 할일 관리
- 할일 생성, 수정, 삭제
- 우선순위 설정 (5단계)
- 카테고리 분류 (20개 기본 제공)
- 하위 할일 (서브태스크)
- 태그 기능
- 자연어 입력 지원 ("내일 3시 회의 #업무")

### 📅 캘린더 & 반복
- 월간 캘린더 뷰
- 날짜별 할일 확인
- 반복 할일 (매일/매주/매월)
- 마감일 알림

### 🍅 포모도로 타이머
- 집중 모드 (25분 기본)
- 휴식 모드 (5분/15분)
- 세션 기록 및 통계

### 🌳 숲 꾸미기
- 할일 완료 시 식물 성장
- 풀 → 꽃 → 나무 3종류
- 시간대별 배경 변화 (낮/밤/노을)
- 반짝이는 별, 구름 애니메이션

### 📋 템플릿
- 자주 사용하는 할일 세트 저장
- 원클릭 할일 생성

### 🔄 습관 트래커
- 반복 할일 히트맵 시각화
- 연속 달성 스트릭

## 🛠 기술 스택

| 구분 | 기술 |
|------|------|
| Framework | Flutter 3.x |
| State Management | Provider |
| Local Database | Hive |
| Notifications | flutter_local_notifications |
| Speech Input | speech_to_text |
| Calendar | table_calendar |

## 📱 지원 플랫폼

- ✅ macOS (11.0+)
- ✅ iOS (12.0+)
- ✅ Android (SDK 21+)

## 🚀 시작하기

### 요구사항
- Flutter 3.10.4 이상
- Dart 3.0 이상

### 설치

```bash
# 저장소 클론
git clone https://github.com/kibongcoders/todoodle-flutter.git
cd todoodle-flutter

# 의존성 설치
flutter pub get

# Hive 어댑터 생성
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

### 빌드

```bash
# macOS
flutter build macos --release

# iOS
flutter build ios --release

# Android
flutter build apk --release
```

## 📁 프로젝트 구조

```
lib/
├── main.dart           # 앱 진입점
├── models/             # Hive 데이터 모델
├── providers/          # 상태 관리 (ChangeNotifier)
├── screens/            # UI 화면
├── services/           # 비즈니스 로직
└── widgets/            # 재사용 위젯
```

## 🗺 로드맵

- [x] Phase 1: 기본 할일 CRUD
- [x] Phase 2: 캘린더, 반복, 알림
- [x] Phase 3: 포모도로, 자연어, 템플릿
- [ ] Phase 4: 클라우드 동기화
- [ ] Phase 5: AI 추천, 위젯

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🤝 기여하기

버그 리포트, 기능 제안, PR 모두 환영합니다!

1. Fork
2. Feature 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 커밋 (`git commit -m 'feat: Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Pull Request 생성
