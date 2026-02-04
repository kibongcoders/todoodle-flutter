import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/habit_heatmap.dart';

class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('습관 트래커'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, _) {
          final habits = todoProvider.getHabits();

          if (habits.isEmpty) {
            return _buildEmptyState();
          }

          final today = DateTime.now();
          final startDate = today.subtract(const Duration(days: 84)); // 12주
          final completionsByDate = todoProvider.getCompletionsByDateRange(startDate, today);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 전체 요약 카드
                _buildOverallSummaryCard(context, habits, completionsByDate),
                const SizedBox(height: 24),

                // 전체 히트맵
                _buildOverallHeatmapCard(context, habits, completionsByDate),
                const SizedBox(height: 24),

                // 개별 습관 목록
                Text(
                  '나의 습관',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                ...habits.map((habit) => _buildHabitCard(context, habit)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🌱',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 습관이 없어요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '반복 할일을 추가하면 습관으로 추적됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '할일 추가 시 "반복" 옵션을 선택하세요',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallSummaryCard(
    BuildContext context,
    List<Todo> habits,
    Map<DateTime, List<Todo>> completionsByDate,
  ) {
    // 오늘 완료한 습관 수
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayCompletions = completionsByDate[today]?.length ?? 0;

    // 총 완료 횟수
    int totalCompletions = 0;
    for (final habit in habits) {
      totalCompletions += habit.totalCompletions;
    }

    // 전체 연속 달성 중인 습관 수
    int activeStreaks = 0;
    int longestStreak = 0;
    for (final habit in habits) {
      if (habit.currentStreak > 0) activeStreaks++;
      if (habit.longestStreak > longestStreak) {
        longestStreak = habit.longestStreak;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '📊',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  '습관 요약',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '오늘 완료',
                    '$todayCompletions/${habits.length}',
                    const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '연속 진행 중',
                    '$activeStreaks개',
                    const Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '총 완료',
                    '$totalCompletions회',
                    const Color(0xFF42A5F5),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '최장 연속',
                    '$longestStreak일',
                    const Color(0xFFAB47BC),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallHeatmapCard(
    BuildContext context,
    List<Todo> habits,
    Map<DateTime, List<Todo>> completionsByDate,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🌿',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  '활동 히트맵',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OverallHabitHeatmap(
              completionsByDate: completionsByDate,
              totalHabits: habits.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Todo habit) {
    String recurrenceText;
    switch (habit.recurrence) {
      case Recurrence.daily:
        recurrenceText = '매일';
      case Recurrence.weekly:
        recurrenceText = '매주';
      case Recurrence.monthly:
        recurrenceText = '매월';
      case Recurrence.custom:
        final days = habit.recurrenceDays ?? [];
        final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
        final selectedDays = days.map((d) => dayNames[d]).join(', ');
        recurrenceText = selectedDays.isEmpty ? '커스텀' : selectedDays;
      default:
        recurrenceText = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recurrenceText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 연속 달성 배지
                if (habit.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak}일',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 통계 행
            Row(
              children: [
                _buildMiniStat('총 완료', '${habit.totalCompletions}회'),
                const SizedBox(width: 24),
                _buildMiniStat('최장 연속', '${habit.longestStreak}일'),
              ],
            ),
            const SizedBox(height: 16),

            // 개별 히트맵
            HabitHeatmap(habit: habit, weeksToShow: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
