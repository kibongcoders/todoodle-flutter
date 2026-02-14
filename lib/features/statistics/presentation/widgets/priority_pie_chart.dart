import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';
import '../../domain/models/statistics_data.dart';
import 'doodle_chart_theme.dart';

/// 우선순위 분포 파이 차트
///
/// 우선순위별 할일 분포를 파이 차트로 표시합니다.
class PriorityPieChart extends StatefulWidget {
  const PriorityPieChart({
    super.key,
    required this.data,
  });

  final List<PriorityStat> data;

  @override
  State<PriorityPieChart> createState() => _PriorityPieChartState();
}

class _PriorityPieChartState extends State<PriorityPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    // 데이터가 있는 항목만 필터링
    final validData = widget.data.where((d) => d.count > 0).toList();

    if (validData.isEmpty) {
      return _buildEmptyState();
    }

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
            child: PieChart(
              PieChartData(
                pieTouchData: DoodleChartTheme.pieTouchData(
                  onTouch: (index) {
                    setState(() => _touchedIndex = index);
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildSections(validData),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(validData),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<PriorityStat> validData) {
    return validData.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isTouched = index == _touchedIndex;
      final color = DoodleChartTheme.priorityColors[stat.priorityIndex];

      return DoodleChartTheme.pieSectionData(
        value: stat.count.toDouble(),
        title: isTouched ? '${stat.count}개' : '',
        color: color,
        isTouched: isTouched,
        radius: 50,
      );
    }).toList();
  }

  Widget _buildLegend(List<PriorityStat> validData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: validData.map((stat) {
        final color = DoodleChartTheme.priorityColors[stat.priorityIndex];
        return _buildLegendItem(
          color: color,
          label: stat.label,
          count: stat.count,
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: DoodleTypography.labelSmall.copyWith(
            color: DoodleColors.pencilDark,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
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
          '데이터가 없습니다',
          style: DoodleTypography.bodyMedium.copyWith(
            color: DoodleColors.pencilLight,
          ),
        ),
      ),
    );
  }
}
