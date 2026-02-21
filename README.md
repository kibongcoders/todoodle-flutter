# Todoodle 🎨

> **"개인 낙서장처럼 편안하고, 스케치북이 채워지듯 즐거운 할일 관리"**

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20Android-lightgrey)]()

Todoodle은 **생산성 앱이 아닌 성장 일기**입니다.
할일을 완료하면 귀여운 낙서가 한 획씩 그려지고, 손그림 뱃지가 쌓이며, 나만의 스케치북이 완성됩니다.

서버 없이 동작하는 순수 로컬 앱 — 로그인 불필요, 구독 불필요, 광고 없음.

---

## 주요 기능

### 할일 관리
- 할일 생성, 수정, 삭제 (스와이프 액션)
- 우선순위 5단계 (포스트잇 색상 연동)
- 카테고리 분류 (이모지 태그 20종)
- 계층적 할일 (부모-자식 서브태스크)
- 태그 기능
- 자연어 입력 ("내일 3시 회의 #업무" → 자동 파싱)
- 음성 입력 (speech_to_text)
- 드래그 정렬

### 캘린더 & 반복
- 월간 캘린더 뷰
- 날짜별 할일 확인
- 반복 할일 (매일/매주/매월/특정요일)
- 마감일 알림 (사전 알림: 10분/30분/1시간/1일 전)

### 포모도로 타이머
- 집중 모드 (25분 기본)
- 휴식 모드 (5분/15분)
- 세션 기록 및 통계
- 예상/실제 시간 트래킹

### 스케치북 & 게이미피케이션
- **낙서 완성**: 할일 완료 → 낙서에 획 추가 → 낙서 완성 (12종)
- **레벨 시스템**: 할일 완료 → XP 획득 → 레벨업 (1~50)
- **업적 뱃지**: 15종 업적 (첫 할일, 스트릭, 집중, 특별)
- **희귀 낙서**: 레벨 10/20/30에 특별 낙서 해금
- **낙서 도감**: 컬렉션 화면 (해금/미해금 표시)
- **스케치북 테마**: 도화지/격자 노트/크래프트지/흑판
- **크레파스 색칠**: 완성된 낙서에 색연필 색칠
- **SNS 공유**: 스케치북 페이지 이미지 공유
- **사운드 효과**: 체크/레벨업/뱃지/낙서 완성 효과음

### 습관 트래커
- 반복 할일 히트맵 시각화 (GitHub 잔디 스타일)
- 연속 달성 스트릭

### Doodle 디자인 시스템
- **손그림 아이콘**: CustomPainter 기반 DoodleIcon 26종 (Material Icons 완전 대체)
- **손그림 체크박스**: DoodleCheckbox (wobble 패턴)
- **포스트잇 카드**: 우선순위별 색상 할일 카드
- **크레파스 색상 팔레트**: 50+ 색상
- **크림색 종이 배경**: 연필/하이라이터 질감

### 기타
- 템플릿 (자주 쓰는 할일 세트 저장)
- 아카이브 & 휴지통
- 실시간 검색 & 날짜 필터

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| **Framework** | Flutter 3.41 / Dart 3.10 |
| **상태 관리** | Provider (ChangeNotifier) |
| **로컬 DB** | Hive + hive_flutter |
| **알림** | flutter_local_notifications |
| **음성 입력** | speech_to_text |
| **캘린더** | table_calendar |
| **차트** | fl_chart |
| **사운드** | audioplayers |
| **공유** | share_plus |
| **폰트** | google_fonts |
| **아이콘** | CustomPainter (DoodleIcon) |

---

## 아키텍처

Hybrid MVVM + Feature-First 구조를 사용합니다.

```
lib/
├── main.dart                 # 앱 진입점, MultiProvider 설정
├── core/                     # 공통 모듈
│   ├── constants/            #   색상(DoodleColors), 타이포그래피
│   └── utils/                #   유틸리티
├── features/                 # Feature-First 구조 (확장 중)
│   └── statistics/           #   통계 기능
├── models/                   # Hive 데이터 모델 (TypeId 0~9)
├── providers/                # 상태 관리 (ChangeNotifier)
├── screens/                  # UI 화면 (15개)
├── services/                 # 비즈니스 로직
├── shared/                   # 공유 컴포넌트
│   ├── painters/             #   DoodleIconPainter
│   ├── themes/               #   테마 정의
│   └── widgets/              #   DoodleIcon, DoodleCheckbox
└── widgets/                  # 재사용 위젯
    ├── painters/             #   SimpleShapes, DoodlePainter
    └── sketchbook/           #   스케치북 관련 위젯
```

### 상태 관리 흐름

```
UI (Screen/Widget)
    ↕ Consumer / context.watch
Provider (ChangeNotifier)
    ↕ notifyListeners()
Service (비즈니스 로직)
    ↕
Hive (로컬 저장소)
```

---

## 시작하기

### 요구사항

- Flutter 3.10.4 이상
- Dart 3.0 이상

### 설치 & 실행

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

---

## 지원 플랫폼

| 플랫폼 | 최소 버전 | 상태 |
|--------|----------|------|
| macOS | 11.0+ | ✅ |
| iOS | 12.0+ | ✅ |
| Android | SDK 21+ | ✅ |

---

## 로드맵

- [x] **Phase 1**: 기본 할일 CRUD
- [x] **Phase 2**: 캘린더, 반복, 알림
- [x] **Phase 3**: 포모도로, 자연어, 템플릿
- [x] **Phase 4**: 게이미피케이션 (스트릭, 레벨, 스케치북, 사운드)
- [ ] **Phase 5**: Doodle 디자인 시스템 (아이콘 ✅ → 애니메이션 → 다크모드)
- [ ] **Phase 6**: 위젯 & 플랫폼 확장
- [ ] **Phase 7**: 통계 & 인사이트
- [ ] **Phase 8**: 폴리싱 & 품질

자세한 로드맵은 [ROADMAP.md](ROADMAP.md)를 참조하세요.

---

## 경쟁 앱 대비 차별점

| 앱 | 강점 | Todoodle 차별점 |
|----|------|----------------|
| **Todoist** | 강력한 기능, 자연어 입력 | 감성적 연결 (낙서가 완성되는 즐거움) |
| **Things 3** | 아름다운 디자인 | 손그림 Doodle 느낌 (차별화된 미학) |
| **TickTick** | 올인원 생산성 | 개인 낙서장 친밀함 (기업용 X) |
| **Forest** | 게이미피케이션 | 더 다양한 보상 & 레벨 시스템 |
| **Notion** | 유연성, 템플릿 | 가벼운 노트북 (Notion의 복잡함 X) |

---

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 기여하기

버그 리포트, 기능 제안, PR 모두 환영합니다!

1. Fork
2. Feature 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 커밋 (`git commit -m 'feat: Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Pull Request 생성
