/// 통계 기간 필터
enum StatsPeriod {
  week,
  month,
  year,
}

extension StatsPeriodExtension on StatsPeriod {
  String get label {
    switch (this) {
      case StatsPeriod.week:
        return '주';
      case StatsPeriod.month:
        return '월';
      case StatsPeriod.year:
        return '연';
    }
  }

  String get emoji {
    switch (this) {
      case StatsPeriod.week:
        return '📅';
      case StatsPeriod.month:
        return '📆';
      case StatsPeriod.year:
        return '🗓️';
    }
  }

  int get days {
    switch (this) {
      case StatsPeriod.week:
        return 7;
      case StatsPeriod.month:
        return 30;
      case StatsPeriod.year:
        return 365;
    }
  }
}

/// 요약 통계
class SummaryStats {
  const SummaryStats({
    required this.totalCompleted,
    required this.currentStreak,
    required this.totalFocusMinutes,
    required this.achievementProgress,
    required this.completionRate,
  });

  /// 총 완료한 할일 수
  final int totalCompleted;

  /// 현재 연속 달성 일수
  final int currentStreak;

  /// 총 집중 시간 (분)
  final int totalFocusMinutes;

  /// 업적 달성률 (0.0 ~ 1.0)
  final double achievementProgress;

  /// 완료율 (0.0 ~ 1.0)
  final double completionRate;

  /// 집중 시간을 시간:분 형식으로 반환
  String get focusTimeFormatted {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// 업적 달성률을 백분율 문자열로 반환
  String get achievementPercentage =>
      '${(achievementProgress * 100).toInt()}%';

  /// 완료율을 백분율 문자열로 반환
  String get completionPercentage => '${(completionRate * 100).toInt()}%';
}

/// 완료율 추이 데이터 포인트
class CompletionPoint {
  const CompletionPoint({
    required this.date,
    required this.completed,
    required this.total,
  });

  /// 날짜
  final DateTime date;

  /// 완료된 할일 수
  final int completed;

  /// 전체 할일 수
  final int total;

  /// 완료율 (0.0 ~ 1.0)
  double get rate => total > 0 ? completed / total : 0.0;
}

/// 카테고리별 통계
class CategoryStat {
  const CategoryStat({
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.completedCount,
    required this.totalCount,
  });

  /// 카테고리 ID
  final String categoryId;

  /// 카테고리 이름
  final String name;

  /// 카테고리 이모지
  final String emoji;

  /// 완료된 할일 수
  final int completedCount;

  /// 전체 할일 수
  final int totalCount;

  /// 완료율 (0.0 ~ 1.0)
  double get completionRate =>
      totalCount > 0 ? completedCount / totalCount : 0.0;
}

/// 집중 시간 통계 (일별)
class FocusTimeStat {
  const FocusTimeStat({
    required this.date,
    required this.minutes,
    required this.sessions,
  });

  /// 날짜
  final DateTime date;

  /// 집중 시간 (분)
  final int minutes;

  /// 완료된 세션 수
  final int sessions;

  /// 시간을 시간:분 형식으로 반환
  String get timeFormatted {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

/// 우선순위별 통계
class PriorityStat {
  const PriorityStat({
    required this.priorityIndex,
    required this.label,
    required this.count,
    required this.completedCount,
  });

  /// 우선순위 인덱스 (0: veryLow ~ 4: veryHigh)
  final int priorityIndex;

  /// 우선순위 라벨
  final String label;

  /// 전체 할일 수
  final int count;

  /// 완료된 할일 수
  final int completedCount;

  /// 완료율
  double get completionRate => count > 0 ? completedCount / count : 0.0;
}

/// 통계 인사이트
class StatsInsights {
  const StatsInsights({
    required this.mostProductiveWeekday,
    required this.topCategory,
    required this.topTag,
    required this.avgCompletionRate,
    required this.longestStreak,
    required this.avgDailyCompleted,
  });

  /// 가장 생산적인 요일 (1: 월요일 ~ 7: 일요일)
  final int mostProductiveWeekday;

  /// 가장 많이 사용한 카테고리
  final String? topCategory;

  /// 가장 많이 사용한 태그
  final String? topTag;

  /// 평균 완료율
  final double avgCompletionRate;

  /// 최장 연속 달성 일수
  final int longestStreak;

  /// 일 평균 완료 개수
  final double avgDailyCompleted;

  /// 요일 이름 반환
  String get weekdayName {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    if (mostProductiveWeekday >= 1 && mostProductiveWeekday <= 7) {
      return weekdays[mostProductiveWeekday - 1];
    }
    return '-';
  }
}
