import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';
import '../../domain/models/statistics_data.dart';
import 'doodle_chart_theme.dart';

/// 완료율 추이 라인 차트
///
/// 일별 할일 완료 개수를 라인 차트로 표시합니다.
class CompletionChart extends StatelessWidget {
  const CompletionChart({
    super.key,
    required this.data,
    required this.period,
  });

  final List<CompletionPoint> data;
  final StatsPeriod period;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    // 최대값 계산
    final maxY = data
        .map((p) => p.completed.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY < 5 ? 5.0 : maxY + 1;

    // FlSpot 데이터 생성
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.completed.toDouble());
    }).toList();

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
        boxShadow: const [
          BoxShadow(
            color: DoodleColors.paperShadow,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: DoodleChartTheme.gridData,
          borderData: DoodleChartTheme.borderData,
          titlesData: _getTitlesData(),
          minY: 0,
          maxY: adjustedMaxY,
          lineBarsData: [
            DoodleChartTheme.lineBarData(
              spots: spots,
              color: DoodleColors.primary,
            ),
          ],
          lineTouchData: DoodleChartTheme.lineTouchData(
            getTooltipText: (spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < data.length) {
                final point = data[index];
                return '${point.date.month}/${point.date.day}: ${point.completed}개';
              }
              return '';
            },
          ),
        ),
      ),
    );
  }

  FlTitlesData _getTitlesData() {
    // 표시할 라벨 간격 계산
    final interval = _calculateInterval();

    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: interval,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            final date = data[index].date;
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                '${date.month}/${date.day}',
                style: DoodleTypography.labelSmall.copyWith(
                  color: DoodleColors.pencilLight,
                  fontSize: 10,
                ),
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

  double _calculateInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    if (data.length <= 30) return 5;
    return 30;
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
