import 'package:flutter/foundation.dart';

import '../../../../models/todo.dart';
import '../../../../providers/achievement_provider.dart';
import '../../../../providers/category_provider.dart';
import '../../../../providers/focus_provider.dart';
import '../../../../providers/sketchbook_provider.dart';
import '../../../../providers/todo_provider.dart';
import '../../domain/models/statistics_data.dart';

/// 통계 Provider
///
/// 각 Provider에서 데이터를 수집하고 통계를 계산합니다.
class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider({
    required TodoProvider todoProvider,
    required FocusProvider focusProvider,
    required SketchbookProvider sketchbookProvider,
    required AchievementProvider achievementProvider,
    required CategoryProvider categoryProvider,
  })  : _todoProvider = todoProvider,
        _focusProvider = focusProvider,
        _sketchbookProvider = sketchbookProvider,
        _achievementProvider = achievementProvider,
        _categoryProvider = categoryProvider;

  final TodoProvider _todoProvider;
  final FocusProvider _focusProvider;
  final SketchbookProvider _sketchbookProvider;
  final AchievementProvider _achievementProvider;
  final CategoryProvider _categoryProvider;

  // ============================================
  // 상태
  // ============================================

  StatsPeriod _period = StatsPeriod.week;
  StatsPeriod get period => _period;

  void setPeriod(StatsPeriod period) {
    if (_period != period) {
      _period = period;
      notifyListeners();
    }
  }

  // ============================================
  // 날짜 범위 계산
  // ============================================

  /// 현재 기간에 따른 시작/종료 날짜
  (DateTime start, DateTime end) get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_period) {
      case StatsPeriod.week:
        return (today.subtract(const Duration(days: 6)), today);
      case StatsPeriod.month:
        return (DateTime(now.year, now.month - 1, now.day), today);
      case StatsPeriod.year:
        return (DateTime(now.year - 1, now.month, now.day), today);
    }
  }

  /// 기간 내 모든 날짜 목록
  List<DateTime> get datesInRange {
    final (start, end) = dateRange;
    final dates = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  // ============================================
  // 요약 통계
  // ============================================

  /// 요약 통계 데이터
  SummaryStats get summaryStats {
    final (start, end) = dateRange;
    final completions = _todoProvider.getCompletionsByDateRange(start, end);

    // 기간 내 완료된 할일 총 개수
    int totalCompleted = 0;
    int totalTodos = 0;

    for (final date in datesInRange) {
      final dateKey = DateTime(date.year, date.month, date.day);
      final todos = completions[dateKey] ?? [];
      totalCompleted += todos.where((t) => t.isCompleted).length;
      totalTodos += todos.length;
    }

    // 완료율
    final completionRate = totalTodos > 0 ? totalCompleted / totalTodos : 0.0;

    // 현재 스트릭
    final currentStreak = _sketchbookProvider.currentStreak;

    // 총 집중 시간
    final totalFocusMinutes = _focusProvider.getAllTimeFocusMinutes();

    // 업적 달성률
    final achievementProgress = _achievementProvider.totalCount > 0
        ? _achievementProvider.unlockedCount / _achievementProvider.totalCount
        : 0.0;

    return SummaryStats(
      totalCompleted: totalCompleted,
      currentStreak: currentStreak,
      totalFocusMinutes: totalFocusMinutes,
      achievementProgress: achievementProgress,
      completionRate: completionRate,
    );
  }

  // ============================================
  // 완료율 추이
  // ============================================

  /// 일별 완료 추이 데이터
  List<CompletionPoint> get completionTrend {
    final (start, end) = dateRange;
    final completions = _todoProvider.getCompletionsByDateRange(start, end);
    final points = <CompletionPoint>[];

    for (final date in datesInRange) {
      final dateKey = DateTime(date.year, date.month, date.day);
      final todos = completions[dateKey] ?? [];
      final completed = todos.where((t) => t.isCompleted).length;
      final total = todos.length;

      points.add(CompletionPoint(
        date: date,
        completed: completed,
        total: total,
      ));
    }

    return points;
  }

  // ============================================
  // 우선순위별 분포
  // ============================================

  /// 우선순위별 통계
  List<PriorityStat> get priorityDistribution {
    final (start, end) = dateRange;
    final completions = _todoProvider.getCompletionsByDateRange(start, end);

    // 모든 할일 수집
    final allTodos = <Todo>[];
    for (final todos in completions.values) {
      allTodos.addAll(todos);
    }

    // 우선순위별 집계
    final stats = <PriorityStat>[];
    for (final priority in Priority.values) {
      final todosWithPriority =
          allTodos.where((t) => t.priority == priority).toList();
      final completed = todosWithPriority.where((t) => t.isCompleted).length;

      stats.add(PriorityStat(
        priorityIndex: priority.index,
        label: _priorityLabel(priority),
        count: todosWithPriority.length,
        completedCount: completed,
      ));
    }

    return stats;
  }

  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.veryLow:
        return '매우 낮음';
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '보통';
      case Priority.high:
        return '높음';
      case Priority.veryHigh:
        return '매우 높음';
    }
  }

  // ============================================
  // 카테고리별 통계
  // ============================================

  /// 카테고리별 통계 (상위 5개)
  List<CategoryStat> get categoryStats {
    final (start, end) = dateRange;
    final completions = _todoProvider.getCompletionsByDateRange(start, end);

    // 모든 할일 수집
    final allTodos = <Todo>[];
    for (final todos in completions.values) {
      allTodos.addAll(todos);
    }

    // 카테고리별 집계
    final categoryMap = <String, (int total, int completed)>{};

    for (final todo in allTodos) {
      for (final categoryId in todo.categoryIds) {
        final current = categoryMap[categoryId] ?? (0, 0);
        categoryMap[categoryId] = (
          current.$1 + 1,
          current.$2 + (todo.isCompleted ? 1 : 0),
        );
      }
    }

    // CategoryStat 리스트 생성
    final stats = <CategoryStat>[];
    for (final entry in categoryMap.entries) {
      final category = _categoryProvider.getCategoryById(entry.key);
      if (category != null) {
        stats.add(CategoryStat(
          categoryId: entry.key,
          name: category.name,
          emoji: category.emoji,
          completedCount: entry.value.$2,
          totalCount: entry.value.$1,
        ));
      }
    }

    // 완료 수 기준 정렬 후 상위 5개
    stats.sort((a, b) => b.completedCount.compareTo(a.completedCount));
    return stats.take(5).toList();
  }

  // ============================================
  // 집중 시간 통계
  // ============================================

  /// 주간 집중 시간 통계
  List<FocusTimeStat> get focusTimeStats {
    final weeklyStats = _focusProvider.getWeeklyStats();

    return weeklyStats.map((stat) {
      return FocusTimeStat(
        date: stat['date'] as DateTime,
        minutes: stat['minutes'] as int,
        sessions: stat['sessions'] as int,
      );
    }).toList();
  }

  // ============================================
  // 인사이트
  // ============================================

  /// 통계 인사이트
  StatsInsights get insights {
    final (start, end) = dateRange;
    final completions = _todoProvider.getCompletionsByDateRange(start, end);

    // 요일별 완료 수 집계
    final weekdayCompletions = List<int>.filled(7, 0);
    int totalCompleted = 0;
    int daysWithData = 0;

    for (final entry in completions.entries) {
      final completed = entry.value.where((t) => t.isCompleted).length;
      if (entry.value.isNotEmpty) {
        daysWithData++;
      }
      totalCompleted += completed;
      // DateTime.weekday: 1(월) ~ 7(일)
      weekdayCompletions[entry.key.weekday - 1] += completed;
    }

    // 가장 생산적인 요일
    int mostProductiveWeekday = 1;
    int maxCompletions = 0;
    for (int i = 0; i < 7; i++) {
      if (weekdayCompletions[i] > maxCompletions) {
        maxCompletions = weekdayCompletions[i];
        mostProductiveWeekday = i + 1;
      }
    }

    // 상위 카테고리
    final topCategoryStat = categoryStats.isNotEmpty ? categoryStats.first : null;

    // 상위 태그
    final allTags = _todoProvider.getAllTags();
    final topTag = allTags.isNotEmpty ? allTags.first : null;

    // 평균 완료율
    final trend = completionTrend;
    double totalRate = 0;
    int validDays = 0;
    for (final point in trend) {
      if (point.total > 0) {
        totalRate += point.rate;
        validDays++;
      }
    }
    final avgCompletionRate = validDays > 0 ? totalRate / validDays : 0.0;

    // 최장 스트릭 (습관 할일 기준)
    final habits = _todoProvider.getHabits();
    int longestStreak = 0;
    for (final habit in habits) {
      if (habit.longestStreak > longestStreak) {
        longestStreak = habit.longestStreak;
      }
    }

    // 일 평균 완료
    final avgDailyCompleted =
        daysWithData > 0 ? totalCompleted / daysWithData : 0.0;

    return StatsInsights(
      mostProductiveWeekday: mostProductiveWeekday,
      topCategory: topCategoryStat != null
          ? '${topCategoryStat.emoji} ${topCategoryStat.name}'
          : null,
      topTag: topTag,
      avgCompletionRate: avgCompletionRate,
      longestStreak: longestStreak,
      avgDailyCompleted: avgDailyCompleted,
    );
  }
}
