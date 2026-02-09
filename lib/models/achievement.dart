import 'package:hive/hive.dart';

part 'achievement.g.dart';

/// 업적 유형
@HiveType(typeId: 11)
enum AchievementType {
  // 완료 마일스톤
  @HiveField(0)
  firstTodo, // 첫 할일 완료

  @HiveField(1)
  complete10, // 10개 완료

  @HiveField(2)
  complete50, // 50개 완료

  @HiveField(3)
  complete100, // 100개 완료

  @HiveField(4)
  complete500, // 500개 완료

  // 스트릭
  @HiveField(5)
  streak3, // 3일 연속

  @HiveField(6)
  streak7, // 7일 연속

  @HiveField(7)
  streak30, // 30일 연속

  // 숲 성장
  @HiveField(8)
  plantGrown, // 첫 식물 성장

  @HiveField(9)
  forest10, // 숲에 식물 10개

  // 집중 모드
  @HiveField(10)
  focusHour, // 총 1시간 집중

  @HiveField(11)
  focusDay, // 하루 4시간 집중

  // 특별
  @HiveField(12)
  earlyBird, // 오전 6시 전 완료

  @HiveField(13)
  nightOwl, // 자정 이후 완료

  @HiveField(14)
  perfectDay, // 오늘 할일 100% 완료
}

/// 업적 모델
@HiveType(typeId: 10)
class Achievement extends HiveObject {
  Achievement({
    required this.id,
    required this.type,
    this.unlockedAt,
    this.currentProgress = 0,
    this.targetProgress = 1,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late AchievementType type;

  @HiveField(2)
  DateTime? unlockedAt; // null이면 잠금 상태

  @HiveField(3)
  int currentProgress;

  @HiveField(4)
  int targetProgress;

  bool get isUnlocked => unlockedAt != null;

  double get progressRatio =>
      targetProgress > 0 ? (currentProgress / targetProgress).clamp(0.0, 1.0) : 0.0;
}

/// 업적 메타데이터 (UI 표시용)
class AchievementMeta {
  const AchievementMeta({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.target,
  });

  final AchievementType type;
  final String name;
  final String description;
  final String icon;
  final int target;

  static const Map<AchievementType, AchievementMeta> all = {
    // 완료 마일스톤
    AchievementType.firstTodo: AchievementMeta(
      type: AchievementType.firstTodo,
      name: '첫 발걸음',
      description: '첫 번째 할일을 완료했습니다',
      icon: '🎯',
      target: 1,
    ),
    AchievementType.complete10: AchievementMeta(
      type: AchievementType.complete10,
      name: '열정의 시작',
      description: '총 10개의 할일을 완료했습니다',
      icon: '⭐',
      target: 10,
    ),
    AchievementType.complete50: AchievementMeta(
      type: AchievementType.complete50,
      name: '꾸준한 실천가',
      description: '총 50개의 할일을 완료했습니다',
      icon: '🌟',
      target: 50,
    ),
    AchievementType.complete100: AchievementMeta(
      type: AchievementType.complete100,
      name: '백전백승',
      description: '총 100개의 할일을 완료했습니다',
      icon: '💫',
      target: 100,
    ),
    AchievementType.complete500: AchievementMeta(
      type: AchievementType.complete500,
      name: '생산성 마스터',
      description: '총 500개의 할일을 완료했습니다',
      icon: '🎖️',
      target: 500,
    ),

    // 스트릭
    AchievementType.streak3: AchievementMeta(
      type: AchievementType.streak3,
      name: '3일 연속',
      description: '3일 연속 할일을 완료했습니다',
      icon: '🔥',
      target: 3,
    ),
    AchievementType.streak7: AchievementMeta(
      type: AchievementType.streak7,
      name: '일주일 챔피언',
      description: '7일 연속 할일을 완료했습니다',
      icon: '🏆',
      target: 7,
    ),
    AchievementType.streak30: AchievementMeta(
      type: AchievementType.streak30,
      name: '한 달의 습관',
      description: '30일 연속 할일을 완료했습니다',
      icon: '👑',
      target: 30,
    ),

    // 숲 성장
    AchievementType.plantGrown: AchievementMeta(
      type: AchievementType.plantGrown,
      name: '첫 수확',
      description: '첫 번째 식물을 다 키웠습니다',
      icon: '🌱',
      target: 1,
    ),
    AchievementType.forest10: AchievementMeta(
      type: AchievementType.forest10,
      name: '작은 숲',
      description: '숲에 10개의 식물을 키웠습니다',
      icon: '🌳',
      target: 10,
    ),

    // 집중 모드
    AchievementType.focusHour: AchievementMeta(
      type: AchievementType.focusHour,
      name: '집중력 훈련',
      description: '총 1시간 집중했습니다',
      icon: '⏱️',
      target: 60,
    ),
    AchievementType.focusDay: AchievementMeta(
      type: AchievementType.focusDay,
      name: '몰입의 하루',
      description: '하루에 4시간 집중했습니다',
      icon: '🧘',
      target: 240,
    ),

    // 특별
    AchievementType.earlyBird: AchievementMeta(
      type: AchievementType.earlyBird,
      name: '얼리버드',
      description: '오전 6시 전에 할일을 완료했습니다',
      icon: '🌅',
      target: 1,
    ),
    AchievementType.nightOwl: AchievementMeta(
      type: AchievementType.nightOwl,
      name: '밤의 전사',
      description: '자정 이후에 할일을 완료했습니다',
      icon: '🦉',
      target: 1,
    ),
    AchievementType.perfectDay: AchievementMeta(
      type: AchievementType.perfectDay,
      name: '완벽한 하루',
      description: '오늘의 모든 할일을 완료했습니다',
      icon: '✨',
      target: 1,
    ),
  };

  static AchievementMeta getMeta(AchievementType type) =>
      all[type] ?? all[AchievementType.firstTodo]!;
}
