import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/doodle_colors.dart';
import '../models/doodle.dart';
import '../providers/level_provider.dart';
import '../providers/sketchbook_provider.dart';
import '../widgets/doodle_painter.dart';

/// 낙서 도감 화면
///
/// 모든 낙서 타입의 해금/미해금 상태를 보여주는 컬렉션 화면입니다.
class DoodleCollectionScreen extends StatelessWidget {
  const DoodleCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodleColors.paperCream,
      appBar: AppBar(
        title: const Text('낙서 도감'),
        backgroundColor: DoodleColors.paperWhite,
        foregroundColor: DoodleColors.pencilDark,
        elevation: 0,
      ),
      body: Consumer2<SketchbookProvider, LevelProvider>(
        builder: (context, sketchbook, level, _) {
          final unlocked = sketchbook.unlockedTypes;
          final normalTypes = DoodleType.values
              .where((t) => Doodle.requiredLevel(t) == null)
              .toList();
          final rareTypes = DoodleType.values
              .where((t) => Doodle.requiredLevel(t) != null)
              .toList();
          final totalTypes = DoodleType.values.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 요약 카드
              _buildSummaryCard(unlocked.length, totalTypes),
              const SizedBox(height: 20),

              // 간단 섹션
              _buildSectionHeader('간단', '3획', DoodleColors.crayonBlue),
              const SizedBox(height: 8),
              _buildDoodleGrid(
                normalTypes.where((t) => t.category == DoodleCategory.simple).toList(),
                unlocked,
                sketchbook,
              ),
              const SizedBox(height: 20),

              // 보통 섹션
              _buildSectionHeader('보통', '5획', DoodleColors.crayonGreen),
              const SizedBox(height: 8),
              _buildDoodleGrid(
                normalTypes.where((t) => t.category == DoodleCategory.medium).toList(),
                unlocked,
                sketchbook,
              ),
              const SizedBox(height: 20),

              // 복잡 섹션
              _buildSectionHeader('복잡', '8획', DoodleColors.crayonPurple),
              const SizedBox(height: 8),
              _buildDoodleGrid(
                normalTypes.where((t) => t.category == DoodleCategory.complex).toList(),
                unlocked,
                sketchbook,
              ),

              // 희귀 섹션
              if (rareTypes.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionHeader('희귀', '레벨 해금', DoodleColors.achievementAccent),
                const SizedBox(height: 8),
                _buildRareDoodleGrid(rareTypes, unlocked, sketchbook, level),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int unlocked, int total) {
    final progress = total > 0 ? unlocked / total : 0.0;
    return Card(
      color: DoodleColors.paperWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DoodleColors.paperGrid),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$total종 중 $unlocked종 해금',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DoodleColors.pencilDark,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: DoodleColors.paperGrid,
                valueColor: const AlwaysStoppedAnimation<Color>(DoodleColors.primary),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: DoodleColors.pencilLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDoodleGrid(
    List<DoodleType> types,
    Set<DoodleType> unlocked,
    SketchbookProvider sketchbook,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        final isUnlocked = unlocked.contains(type);
        final count = sketchbook.getCountByType(type);
        final latest = sketchbook.getLatestDoodleOfType(type);
        return _buildCollectionCard(
          type: type,
          isUnlocked: isUnlocked,
          count: count,
          fillColor: latest?.crayonColor,
        );
      }).toList(),
    );
  }

  Widget _buildRareDoodleGrid(
    List<DoodleType> types,
    Set<DoodleType> unlocked,
    SketchbookProvider sketchbook,
    LevelProvider level,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        final isUnlocked = unlocked.contains(type);
        final count = sketchbook.getCountByType(type);
        final latest = sketchbook.getLatestDoodleOfType(type);
        final reqLevel = Doodle.requiredLevel(type);
        final canUnlock = reqLevel != null && level.currentLevel >= reqLevel;
        return _buildCollectionCard(
          type: type,
          isUnlocked: isUnlocked,
          count: count,
          fillColor: latest?.crayonColor,
          isRare: true,
          requiredLevel: reqLevel,
          canUnlock: canUnlock,
        );
      }).toList(),
    );
  }

  Widget _buildCollectionCard({
    required DoodleType type,
    required bool isUnlocked,
    required int count,
    Color? fillColor,
    bool isRare = false,
    int? requiredLevel,
    bool canUnlock = true,
  }) {
    // 한글 이름 (Doodle 모델의 typeName 재현)
    final name = _typeNameOf(type);
    const size = 80.0;

    return Container(
      width: size + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRare
              ? (isUnlocked
                  ? DoodleColors.achievementAccent
                  : DoodleColors.achievementGoldLight)
              : DoodleColors.paperGrid,
          width: isRare ? 2 : 1,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 낙서 그림
          SizedBox(
            width: size,
            height: size,
            child: isUnlocked
                ? CustomPaint(
                    painter: DoodlePainter(
                      type: type,
                      progress: 1.0,
                      strokeColor: DoodleColors.pencilDark,
                      fillColor: fillColor,
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.12,
                        child: CustomPaint(
                          size: const Size(size, size),
                          painter: DoodlePainter(
                            type: type,
                            progress: 1.0,
                            strokeColor: DoodleColors.pencilLight,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        size: 24,
                        color: DoodleColors.pencilLight.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 4),
          // 이름
          Text(
            isUnlocked ? name : '???',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isUnlocked ? DoodleColors.pencilDark : DoodleColors.pencilLight,
            ),
          ),
          // 완성 횟수 또는 해금 조건
          if (isUnlocked)
            Text(
              '$count회',
              style: const TextStyle(
                fontSize: 10,
                color: DoodleColors.pencilLight,
              ),
            )
          else if (requiredLevel != null)
            Text(
              canUnlock ? '출현 가능' : 'Lv.$requiredLevel',
              style: TextStyle(
                fontSize: 10,
                color: canUnlock
                    ? DoodleColors.primary
                    : DoodleColors.pencilLight,
              ),
            ),
        ],
      ),
    );
  }

  String _typeNameOf(DoodleType type) {
    switch (type) {
      case DoodleType.star:
        return '별';
      case DoodleType.heart:
        return '하트';
      case DoodleType.cloud:
        return '구름';
      case DoodleType.moon:
        return '달';
      case DoodleType.house:
        return '집';
      case DoodleType.flower:
        return '꽃';
      case DoodleType.boat:
        return '배';
      case DoodleType.balloon:
        return '풍선';
      case DoodleType.tree:
        return '나무';
      case DoodleType.bicycle:
        return '자전거';
      case DoodleType.rocket:
        return '로켓';
      case DoodleType.cat:
        return '고양이';
      case DoodleType.rainbowStar:
        return '무지개 별';
      case DoodleType.crown:
        return '왕관';
      case DoodleType.diamond:
        return '다이아몬드';
    }
  }
}
