import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';
import '../../domain/models/statistics_data.dart';
import 'doodle_chart_theme.dart';

/// 카테고리별 바 차트
///
/// 카테고리별 완료 개수를 가로 바 차트로 표시합니다.
class CategoryBarChart extends StatefulWidget {
  const CategoryBarChart({
    super.key,
    required this.data,
  });

  final List<CategoryStat> data;

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    // 최대값 계산
    final maxY = widget.data
        .map((d) => d.completedCount.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY < 5 ? 5.0 : maxY + 1;

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
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: adjustedMaxY,
                barTouchData: BarTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.spot == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = response.spot!.touchedBarGroupIndex;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        DoodleColors.pencilDark.withValues(alpha: 0.9),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final stat = widget.data[groupIndex];
                      return BarTooltipItem(
                        '${stat.emoji} ${stat.name}\n${stat.completedCount}개 완료',
                        DoodleTypography.labelSmall.copyWith(
                          color: DoodleColors.paperWhite,
                        ),
                      );
                    },
                  ),
                ),
                gridData: DoodleChartTheme.gridData,
                borderData: DoodleChartTheme.borderData,
                titlesData: _getTitlesData(),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final color = DoodleChartTheme.categoryColors[
          index % DoodleChartTheme.categoryColors.length];
      final isTouched = index == _touchedIndex;

      return DoodleChartTheme.barGroupData(
        x: index,
        value: stat.completedCount.toDouble(),
        color: color,
        width: 24,
        isTouched: isTouched,
      );
    }).toList();
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= widget.data.length) {
              return const SizedBox.shrink();
            }
            final stat = widget.data[index];
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                stat.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: DoodleChartTheme.leftTitleWidget,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoodleColors.paperGrid,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '카테고리 데이터가 없습니다',
          style: DoodleTypography.bodyMedium.copyWith(
            color: DoodleColors.pencilLight,
          ),
        ),
      ),
    );
  }
}
