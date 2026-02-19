import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/doodle_colors.dart';
import '../../core/constants/doodle_typography.dart';
import '../../providers/level_provider.dart';

/// 레벨 정보 카드 위젯
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProvider>(
      builder: (context, levelProvider, _) {
        if (!levelProvider.initialized) return const SizedBox.shrink();

        final level = levelProvider.currentLevel;
        final title = LevelProvider.titleForLevel(level);
        final progress = levelProvider.currentLevelProgress;
        final remaining = levelProvider.xpRemainingForNextLevel;
        final totalXP = levelProvider.totalXP;
        final margin = isWide ? 20.0 : 16.0;

        return Card(
          margin: EdgeInsets.fromLTRB(margin, margin, margin, 0),
          color: DoodleColors.paperWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: DoodleColors.primaryLight, width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(isWide ? 20 : 16),
            child: Row(
              children: [
                // 레벨 원형 배지
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DoodleColors.primaryLight.withValues(alpha: 0.3),
                    border: Border.all(
                      color: DoodleColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: DoodleTypography.numberMedium.copyWith(
                        color: DoodleColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 레벨 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Lv. $level',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DoodleColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              color: DoodleColors.pencilLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // XP 프로그래스 바
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: DoodleColors.paperGrid,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  DoodleColors.primary,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: DoodleColors.pencilLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '총 XP: $totalXP',
                            style: const TextStyle(
                              fontSize: 11,
                              color: DoodleColors.pencilLight,
                            ),
                          ),
                          if (level < 50)
                            Text(
                              '다음 레벨까지 $remaining XP',
                              style: const TextStyle(
                                fontSize: 11,
                                color: DoodleColors.pencilLight,
                              ),
                            ),
                          if (level >= 50)
                            const Text(
                              'MAX LEVEL!',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: DoodleColors.achievementAccent,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
