import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/achievement.dart';

/// 업적 달성 시 콜백
typedef OnAchievementUnlocked = void Function(Achievement achievement);

class AchievementProvider extends ChangeNotifier {
  AchievementProvider();

  static const _boxName = 'achievements';

  late Box<Achievement> _box;
  bool _initialized = false;

  /// 새 업적 획득 시 호출되는 콜백
  OnAchievementUnlocked? onAchievementUnlocked;

  // Getters
  bool get initialized => _initialized;

  List<Achievement> get achievements => _box.values.toList();

  List<Achievement> get unlockedAchievements =>
      _box.values.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements =>
      _box.values.where((a) => !a.isUnlocked).toList();

  int get unlockedCount => unlockedAchievements.length;
  int get totalCount => AchievementType.values.length;

  /// 초기화
  Future<void> init() async {
    _box = await Hive.openBox<Achievement>(_boxName);

    // 모든 업적 유형에 대해 Achievement 엔트리 생성
    await _ensureAllAchievementsExist();

    _initialized = true;
    notifyListeners();
  }

  /// 모든 업적 유형에 대해 엔트리 생성
  Future<void> _ensureAllAchievementsExist() async {
    for (final type in AchievementType.values) {
      final id = type.name;
      if (!_box.containsKey(id)) {
        final meta = AchievementMeta.getMeta(type);
        final achievement = Achievement(
          id: id,
          type: type,
          targetProgress: meta.target,
        );
        await _box.put(id, achievement);
      }
    }
  }

  /// 특정 업적 가져오기
  Achievement? getAchievement(AchievementType type) {
    return _box.get(type.name);
  }

  // ========================================
  // 업적 체크 메서드들
  // ========================================

  /// 할일 완료 시 호출
  Future<void> onTodoCompleted({
    required int totalCompleted,
    required int currentStreak,
    required DateTime completedAt,
    required bool isTodayAllCompleted,
  }) async {
    // 완료 마일스톤 체크
    await _checkCompletionMilestones(totalCompleted);

    // 스트릭 체크
    await _checkStreakMilestones(currentStreak);

    // 시간대 업적 체크
    await _checkTimeBasedAchievements(completedAt);

    // 완벽한 하루 체크
    if (isTodayAllCompleted) {
      await _unlockAchievement(AchievementType.perfectDay);
    }
  }

  /// 낙서 완성 시 호출
  Future<void> onDoodleCompleted({required int totalDoodlesCompleted}) async {
    // 첫 낙서
    if (totalDoodlesCompleted >= 1) {
      await _unlockAchievement(AchievementType.plantGrown);
    }

    // 10개 낙서
    if (totalDoodlesCompleted >= 10) {
      await _unlockAchievement(AchievementType.forest10);
    }
  }

  /// 집중 세션 완료 시 호출
  Future<void> onFocusSessionCompleted({
    required int totalFocusMinutes,
    required int todayFocusMinutes,
  }) async {
    // 총 1시간 집중
    await _updateProgress(AchievementType.focusHour, totalFocusMinutes);
    if (totalFocusMinutes >= 60) {
      await _unlockAchievement(AchievementType.focusHour);
    }

    // 하루 4시간 집중
    if (todayFocusMinutes >= 240) {
      await _unlockAchievement(AchievementType.focusDay);
    }
  }

  // ========================================
  // 내부 헬퍼 메서드
  // ========================================

  Future<void> _checkCompletionMilestones(int totalCompleted) async {
    // 진행도 업데이트
    await _updateProgress(AchievementType.firstTodo, totalCompleted);
    await _updateProgress(AchievementType.complete10, totalCompleted);
    await _updateProgress(AchievementType.complete50, totalCompleted);
    await _updateProgress(AchievementType.complete100, totalCompleted);
    await _updateProgress(AchievementType.complete500, totalCompleted);

    // 업적 달성 체크
    if (totalCompleted >= 1) {
      await _unlockAchievement(AchievementType.firstTodo);
    }
    if (totalCompleted >= 10) {
      await _unlockAchievement(AchievementType.complete10);
    }
    if (totalCompleted >= 50) {
      await _unlockAchievement(AchievementType.complete50);
    }
    if (totalCompleted >= 100) {
      await _unlockAchievement(AchievementType.complete100);
    }
    if (totalCompleted >= 500) {
      await _unlockAchievement(AchievementType.complete500);
    }
  }

  Future<void> _checkStreakMilestones(int currentStreak) async {
    // 진행도 업데이트
    await _updateProgress(AchievementType.streak3, currentStreak);
    await _updateProgress(AchievementType.streak7, currentStreak);
    await _updateProgress(AchievementType.streak30, currentStreak);

    // 업적 달성 체크
    if (currentStreak >= 3) {
      await _unlockAchievement(AchievementType.streak3);
    }
    if (currentStreak >= 7) {
      await _unlockAchievement(AchievementType.streak7);
    }
    if (currentStreak >= 30) {
      await _unlockAchievement(AchievementType.streak30);
    }
  }

  Future<void> _checkTimeBasedAchievements(DateTime completedAt) async {
    final hour = completedAt.hour;

    // 얼리버드: 오전 6시 전
    if (hour < 6) {
      await _unlockAchievement(AchievementType.earlyBird);
    }

    // 나이트아울: 자정~오전 4시
    if (hour >= 0 && hour < 4) {
      await _unlockAchievement(AchievementType.nightOwl);
    }
  }

  Future<void> _updateProgress(AchievementType type, int progress) async {
    final achievement = _box.get(type.name);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.currentProgress = progress;
      await achievement.save();
      notifyListeners();
    }
  }

  Future<void> _unlockAchievement(AchievementType type) async {
    final achievement = _box.get(type.name);
    if (achievement != null && !achievement.isUnlocked) {
      final meta = AchievementMeta.getMeta(type);
      achievement.unlockedAt = DateTime.now();
      achievement.currentProgress = meta.target;
      await achievement.save();

      // 콜백 호출
      onAchievementUnlocked?.call(achievement);

      notifyListeners();
      debugPrint('🏆 Achievement unlocked: ${meta.name}');
    }
  }

  /// 업적 초기화 (디버그용)
  Future<void> resetAllAchievements() async {
    await _box.clear();
    await _ensureAllAchievementsExist();
    notifyListeners();
  }
}
