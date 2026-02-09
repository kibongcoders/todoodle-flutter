# Feature: 뱃지 & 업적 시스템 (Phase 4.1)

## Overview

사용자의 지속적인 동기 부여를 위한 뱃지/업적 시스템을 구현합니다.
할일 완료, 연속 달성(스트릭), 마일스톤 달성 시 뱃지를 획득하고 축하 애니메이션을 표시합니다.

## Data Model

### Achievement (TypeId: 10)

```dart
@HiveType(typeId: 10)
class Achievement extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late AchievementType type;

  @HiveField(2)
  late DateTime? unlockedAt;  // null이면 잠금 상태

  @HiveField(3)
  late int currentProgress;   // 현재 진행도

  @HiveField(4)
  late int targetProgress;    // 목표 진행도
}
```

### AchievementType (TypeId: 11)

```dart
@HiveType(typeId: 11)
enum AchievementType {
  @HiveField(0)
  firstTodo,          // 첫 할일 완료

  @HiveField(1)
  streak3,            // 3일 연속

  @HiveField(2)
  streak7,            // 7일 연속

  @HiveField(3)
  streak30,           // 30일 연속

  @HiveField(4)
  complete10,         // 10개 완료

  @HiveField(5)
  complete50,         // 50개 완료

  @HiveField(6)
  complete100,        // 100개 완료

  @HiveField(7)
  complete500,        // 500개 완료

  @HiveField(8)
  plantGrown,         // 첫 식물 성장

  @HiveField(9)
  forest10,           // 숲에 식물 10개

  @HiveField(10)
  focusHour,          // 집중 1시간

  @HiveField(11)
  focusDay,           // 하루 4시간 집중

  @HiveField(12)
  earlyBird,          // 오전 6시 전 할일 완료

  @HiveField(13)
  nightOwl,           // 자정 이후 할일 완료

  @HiveField(14)
  perfectDay,         // 하루 할일 100% 완료
}
```

## Achievement Metadata

| Type | 이름 | 설명 | 아이콘 | 조건 |
|------|------|------|--------|------|
| firstTodo | 첫 발걸음 | 첫 번째 할일을 완료했습니다 | 🎯 | 1개 완료 |
| streak3 | 3일 연속 | 3일 연속 할일을 완료했습니다 | 🔥 | 3일 스트릭 |
| streak7 | 일주일 챔피언 | 7일 연속 할일을 완료했습니다 | 🏆 | 7일 스트릭 |
| streak30 | 한 달의 습관 | 30일 연속 할일을 완료했습니다 | 👑 | 30일 스트릭 |
| complete10 | 열정의 시작 | 총 10개의 할일을 완료했습니다 | ⭐ | 10개 완료 |
| complete50 | 꾸준한 실천가 | 총 50개의 할일을 완료했습니다 | 🌟 | 50개 완료 |
| complete100 | 백전백승 | 총 100개의 할일을 완료했습니다 | 💫 | 100개 완료 |
| complete500 | 생산성 마스터 | 총 500개의 할일을 완료했습니다 | 🎖️ | 500개 완료 |
| plantGrown | 첫 수확 | 첫 번째 식물을 다 키웠습니다 | 🌱 | 식물 1개 성장 |
| forest10 | 작은 숲 | 숲에 10개의 식물을 키웠습니다 | 🌳 | 식물 10개 |
| focusHour | 집중력 훈련 | 총 1시간 집중했습니다 | ⏱️ | 60분 집중 |
| focusDay | 몰입의 하루 | 하루에 4시간 집중했습니다 | 🧘 | 하루 240분 |
| earlyBird | 얼리버드 | 오전 6시 전에 할일을 완료했습니다 | 🌅 | 06시 전 완료 |
| nightOwl | 밤의 전사 | 자정 이후에 할일을 완료했습니다 | 🦉 | 00시 이후 완료 |
| perfectDay | 완벽한 하루 | 오늘의 모든 할일을 완료했습니다 | ✨ | 오늘 100% |

## Implementation Steps

### Step 1: 모델 생성
- [ ] `lib/models/achievement.dart` 생성
- [ ] `AchievementType` enum 정의
- [ ] `Achievement` HiveObject 정의
- [ ] `dart run build_runner build` 실행

### Step 2: AchievementProvider 구현
- [ ] `lib/providers/achievement_provider.dart` 생성
- [ ] 초기 뱃지 목록 생성 로직
- [ ] 업적 달성 체크 로직
- [ ] 새 업적 획득 시 콜백/이벤트

### Step 3: Provider 연동
- [ ] `TodoProvider`에서 완료 시 업적 체크 호출
- [ ] `ForestProvider`에서 식물 성장 시 업적 체크 호출
- [ ] `FocusProvider`에서 집중 완료 시 업적 체크 호출
- [ ] `main.dart`에 AchievementProvider 등록

### Step 4: 업적 목록 UI
- [ ] `lib/screens/achievements_screen.dart` 생성
- [ ] 획득/미획득 뱃지 그리드 표시
- [ ] 진행률 표시 (예: 45/100)
- [ ] 설정 화면에서 접근 가능하게 연결

### Step 5: 업적 획득 알림 UI
- [ ] `lib/widgets/achievement_popup.dart` 생성
- [ ] 축하 애니메이션 (confetti 효과)
- [ ] 뱃지 아이콘 + 이름 + 설명 표시
- [ ] 자동 닫힘 또는 탭하여 닫기

### Step 6: 스트릭 시각화 개선
- [ ] 홈 화면 또는 프로필에 현재 스트릭 표시
- [ ] 불꽃 아이콘 + 연속 일수
- [ ] 스트릭 히스토리 (최근 7일 시각화)

## File Changes

### Create
- `lib/models/achievement.dart`
- `lib/models/achievement.g.dart` (generated)
- `lib/providers/achievement_provider.dart`
- `lib/screens/achievements_screen.dart`
- `lib/widgets/achievement_popup.dart`

### Modify
- `lib/main.dart` - AchievementProvider 등록, Hive 어댑터 등록
- `lib/providers/todo_provider.dart` - 완료 시 업적 체크 연동
- `lib/providers/forest_provider.dart` - 식물 성장 시 업적 체크 연동
- `lib/providers/focus_provider.dart` - 집중 완료 시 업적 체크 연동
- `lib/screens/settings_screen.dart` - 업적 화면 링크 추가
- `lib/screens/home_screen.dart` - 스트릭 표시 위젯 추가

## Dependencies

기존 패키지로 충분:
- `hive` / `hive_flutter` - 데이터 저장
- `provider` - 상태 관리
- `flutter` 기본 애니메이션 - 팝업 효과

선택적 추가:
- `confetti` 패키지 - 축하 효과 (선택)

## Notes

- TypeId 10, 11 사용 (CLAUDE.md 규칙에 따라 10부터 시작)
- 기존 `ForestProvider.currentStreak` 활용
- 업적 체크는 비동기로 처리하여 메인 플로우 차단하지 않음
