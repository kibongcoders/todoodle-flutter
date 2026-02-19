import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';
import '../../providers/sketchbook_provider.dart';

/// 스케치북 통계 카드 위젯
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.provider,
    required this.isWide,
  });

  final SketchbookProvider provider;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(isWide ? 20 : 16),
      color: DoodleColors.paperWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DoodleColors.paperGrid),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 20 : 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: '완료한 할일',
                  value: '${provider.totalTodosCompleted}',
                  color: DoodleColors.success,
                ),
                _buildStatItem(
                  icon: Icons.brush_outlined,
                  label: '완성된 낙서',
                  value: '${provider.totalDoodlesCompleted}',
                  color: DoodleColors.primary,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: '연속 기록',
                  value: '${provider.currentStreak}일',
                  color: DoodleColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: DoodleColors.paperGrid),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryCount('간단', provider.simpleCount, DoodleColors.crayonBlue),
                _buildCategoryCount('보통', provider.mediumCount, DoodleColors.crayonGreen),
                _buildCategoryCount('복잡', provider.complexCount, DoodleColors.crayonPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isWide ? 32 : 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isWide ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isWide ? 14 : 12,
            color: DoodleColors.pencilLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCount(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: const TextStyle(
            fontSize: 13,
            color: DoodleColors.pencilDark,
          ),
        ),
      ],
    );
  }
}
