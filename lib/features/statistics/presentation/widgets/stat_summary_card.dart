import 'package:flutter/material.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';
import '../../domain/models/statistics_data.dart';

/// 요약 통계 카드
///
/// 핵심 지표 4개를 2x2 그리드로 표시합니다.
class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    super.key,
    required this.stats,
  });

  final SummaryStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoodleColors.paperGrid,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: DoodleColors.paperShadow,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  emoji: '✅',
                  value: stats.totalCompleted.toString(),
                  label: '완료한 할일',
                  color: DoodleColors.crayonGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  emoji: '🔥',
                  value: '${stats.currentStreak}일',
                  label: '연속 달성',
                  color: DoodleColors.crayonOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  emoji: '⏱',
                  value: stats.focusTimeFormatted,
                  label: '총 집중 시간',
                  color: DoodleColors.crayonBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  emoji: '🏆',
                  value: stats.achievementPercentage,
                  label: '업적 달성',
                  color: DoodleColors.crayonPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                value,
                style: DoodleTypography.numberMedium.copyWith(
                  color: DoodleColors.pencilDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: DoodleTypography.labelSmall.copyWith(
              color: DoodleColors.pencilLight,
            ),
          ),
        ],
      ),
    );
  }
}
