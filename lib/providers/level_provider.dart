import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/todo.dart';

/// 레벨/경험치 상태 관리 Provider
///
/// 할일 완료 시 우선순위에 따라 XP를 획득하고,
/// XP 누적으로 레벨이 올라갑니다 (1~50레벨).
class LevelProvider extends ChangeNotifier {
  static const String _boxName = 'level_stats';

  late Box _statsBox;
  bool _initialized = false;

  /// 레벨업 시 호출되는 콜백
  Function(int newLevel)? onLevelUp;

  // Getters
  bool get initialized => _initialized;
  int get totalXP => _statsBox.get('totalXP', defaultValue: 0);
  int get currentLevel => _statsBox.get('currentLevel', defaultValue: 1);

  /// 현재 레벨 시작에 필요한 누적 XP
  int get xpForCurrentLevel => xpRequiredForLevel(currentLevel);

  /// 다음 레벨에 필요한 누적 XP
  int get xpForNextLevel => xpRequiredForLevel(currentLevel + 1);

  /// 현재 레벨 내 진행률 (0.0 ~ 1.0)
  double get currentLevelProgress {
    if (currentLevel >= 50) return 1.0;
    final levelStart = xpForCurrentLevel;
    final levelEnd = xpForNextLevel;
    final range = levelEnd - levelStart;
    if (range <= 0) return 1.0;
    return ((totalXP - levelStart) / range).clamp(0.0, 1.0);
  }

  /// 다음 레벨까지 남은 XP
  int get xpRemainingForNextLevel {
    if (currentLevel >= 50) return 0;
    return xpForNextLevel - totalXP;
  }

  /// 초기화
  Future<void> init() async {
    _statsBox = await Hive.openBox(_boxName);

    // 첫 실행 시 초기값 설정
    if (!_statsBox.containsKey('totalXP')) {
      await _statsBox.put('totalXP', 0);
      await _statsBox.put('currentLevel', 1);
    }

    _initialized = true;
    notifyListeners();
  }

  /// XP 추가 (할일 완료 시 호출)
  Future<void> addXP(int xp) async {
    if (xp <= 0) return;

    final newTotalXP = totalXP + xp;
    await _statsBox.put('totalXP', newTotalXP);

    await _checkLevelUp(newTotalXP);
    notifyListeners();
  }

  /// 레벨업 체크
  Future<void> _checkLevelUp(int newTotalXP) async {
    final newLevel = levelFromXP(newTotalXP);
    final oldLevel = currentLevel;

    if (newLevel > oldLevel) {
      await _statsBox.put('currentLevel', newLevel);
      onLevelUp?.call(newLevel);
    }
  }

  // ─── 정적 유틸리티 ───

  /// 우선순위별 XP 보상
  static int xpForPriority(Priority priority) {
    switch (priority) {
      case Priority.veryLow:
        return 5;
      case Priority.low:
        return 10;
      case Priority.medium:
        return 20;
      case Priority.high:
        return 30;
      case Priority.veryHigh:
        return 50;
    }
  }

  /// 레벨 N에 도달하기 위한 누적 XP (비선형)
  /// 레벨 1: 0, 레벨 2: 200, 레벨 5: 1250, 레벨 10: 5000
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    return level * level * 50;
  }

  /// 누적 XP로 레벨 계산
  static int levelFromXP(int totalXP) {
    if (totalXP <= 0) return 1;
    final level = sqrt(totalXP / 50).floor();
    return level.clamp(1, 50);
  }

  /// 레벨별 칭호
  static String titleForLevel(int level) {
    if (level >= 45) return '전설의 낙서가';
    if (level >= 35) return '마스터 낙서가';
    if (level >= 25) return '숙련된 낙서가';
    if (level >= 15) return '성장하는 낙서가';
    if (level >= 8) return '열심히 그리는 중';
    if (level >= 3) return '초보 낙서가';
    return '낙서 입문자';
  }
}
