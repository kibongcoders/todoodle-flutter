import 'package:flutter/material.dart';

import '../models/todo.dart';

class HabitHeatmap extends StatelessWidget {
  final Todo habit;
  final int weeksToShow;

  const HabitHeatmap({
    super.key,
    required this.habit,
    this.weeksToShow = 12,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: (weeksToShow * 7) - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 라벨
        _buildMonthLabels(startDate, today),
        const SizedBox(height: 4),
        // 히트맵 그리드
        _buildHeatmapGrid(context, startDate, today),
        const SizedBox(height: 8),
        // 범례
        _buildLegend(context),
      ],
    );
  }

  Widget _buildMonthLabels(DateTime start, DateTime end) {
    final months = <String>[];
    final positions = <int>[];

    var current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) || current.month == end.month) {
      final monthNames = ['', '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
      months.add(monthNames[current.month]);

      // 해당 월의 첫째 날이 시작일로부터 몇 주 차인지 계산
      final daysSinceStart = current.difference(start).inDays;
      positions.add((daysSinceStart / 7).floor());

      current = DateTime(current.year, current.month + 1, 1);
    }

    return SizedBox(
      height: 16,
      child: Stack(
        children: List.generate(months.length, (index) {
          if (index == 0) return const SizedBox.shrink();
          return Positioned(
            left: positions[index] * 14.0 + 24,
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeatmapGrid(BuildContext context, DateTime start, DateTime end) {
    final dayLabels = ['월', '', '수', '', '금', '', ''];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 요일 라벨
        Column(
          children: dayLabels
              .map((label) => SizedBox(
                    width: 20,
                    height: 14,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ))
              .toList(),
        ),
        // 히트맵 셀들
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildWeeks(context, start, end),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeeks(BuildContext context, DateTime start, DateTime end) {
    final weeks = <Widget>[];
    var currentWeekStart = start;

    // 시작일이 월요일이 아니면 조정
    while (currentWeekStart.weekday != DateTime.monday) {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 1));
    }

    while (currentWeekStart.isBefore(end) || currentWeekStart.isAtSameMomentAs(end)) {
      weeks.add(_buildWeekColumn(context, currentWeekStart, end));
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  Widget _buildWeekColumn(BuildContext context, DateTime weekStart, DateTime end) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Column(
      children: List.generate(7, (dayIndex) {
        final date = weekStart.add(Duration(days: dayIndex));
        final dateOnly = DateTime(date.year, date.month, date.day);

        // 오늘 이후는 빈 셀
        if (dateOnly.isAfter(todayOnly)) {
          return const SizedBox(width: 12, height: 12);
        }

        final isCompleted = habit.wasCompletedOn(date);

        return GestureDetector(
          onTap: () => _showDateInfo(context, date, isCompleted),
          child: Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: _getCellColor(isCompleted, dateOnly.isAtSameMomentAs(todayOnly)),
              borderRadius: BorderRadius.circular(2),
              border: dateOnly.isAtSameMomentAs(todayOnly)
                  ? Border.all(color: const Color(0xFF2E7D32), width: 1.5)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Color _getCellColor(bool isCompleted, bool isToday) {
    if (isCompleted) {
      return const Color(0xFF4CAF50);
    }
    return Colors.grey[200]!;
  }

  void _showDateInfo(BuildContext context, DateTime date, bool isCompleted) {
    final dateStr = '${date.year}.${date.month}.${date.day}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted ? '$dateStr - 완료!' : '$dateStr - 미완료',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '적음',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '완료',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

// 전체 습관 히트맵 (여러 습관 합산)
class OverallHabitHeatmap extends StatelessWidget {
  final Map<DateTime, List<Todo>> completionsByDate;
  final int totalHabits;
  final int weeksToShow;

  const OverallHabitHeatmap({
    super.key,
    required this.completionsByDate,
    required this.totalHabits,
    this.weeksToShow = 12,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: (weeksToShow * 7) - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthLabels(startDate, today),
        const SizedBox(height: 4),
        _buildHeatmapGrid(context, startDate, today),
        const SizedBox(height: 8),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildMonthLabels(DateTime start, DateTime end) {
    final months = <String>[];
    final positions = <int>[];

    var current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) || current.month == end.month) {
      final monthNames = ['', '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
      months.add(monthNames[current.month]);

      final daysSinceStart = current.difference(start).inDays;
      positions.add((daysSinceStart / 7).floor());

      current = DateTime(current.year, current.month + 1, 1);
    }

    return SizedBox(
      height: 16,
      child: Stack(
        children: List.generate(months.length, (index) {
          if (index == 0) return const SizedBox.shrink();
          return Positioned(
            left: positions[index] * 14.0 + 24,
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeatmapGrid(BuildContext context, DateTime start, DateTime end) {
    final dayLabels = ['월', '', '수', '', '금', '', ''];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: dayLabels
              .map((label) => SizedBox(
                    width: 20,
                    height: 14,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ))
              .toList(),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildWeeks(context, start, end),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeeks(BuildContext context, DateTime start, DateTime end) {
    final weeks = <Widget>[];
    var currentWeekStart = start;

    while (currentWeekStart.weekday != DateTime.monday) {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 1));
    }

    while (currentWeekStart.isBefore(end) || currentWeekStart.isAtSameMomentAs(end)) {
      weeks.add(_buildWeekColumn(context, currentWeekStart, end));
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  Widget _buildWeekColumn(BuildContext context, DateTime weekStart, DateTime end) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Column(
      children: List.generate(7, (dayIndex) {
        final date = weekStart.add(Duration(days: dayIndex));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (dateOnly.isAfter(todayOnly)) {
          return const SizedBox(width: 12, height: 12);
        }

        final completedCount = completionsByDate[dateOnly]?.length ?? 0;
        final intensity = totalHabits > 0 ? completedCount / totalHabits : 0.0;

        return GestureDetector(
          onTap: () => _showDateInfo(context, date, completedCount),
          child: Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: _getCellColor(intensity),
              borderRadius: BorderRadius.circular(2),
              border: dateOnly.isAtSameMomentAs(todayOnly)
                  ? Border.all(color: const Color(0xFF2E7D32), width: 1.5)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Color _getCellColor(double intensity) {
    if (intensity == 0) return Colors.grey[200]!;
    if (intensity <= 0.25) return const Color(0xFFC8E6C9);
    if (intensity <= 0.5) return const Color(0xFF81C784);
    if (intensity <= 0.75) return const Color(0xFF4CAF50);
    return const Color(0xFF2E7D32);
  }

  void _showDateInfo(BuildContext context, DateTime date, int count) {
    final dateStr = '${date.year}.${date.month}.${date.day}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$dateStr - $count개 습관 완료'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '적음',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFC8E6C9),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF81C784),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '많음',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
