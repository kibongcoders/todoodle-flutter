import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';
import '../../domain/models/statistics_data.dart';
import 'doodle_chart_theme.dart';

/// 집중 시간 바 차트
///
/// 일별 집중 시간을 세로 바 차트로 표시합니다.
class FocusTimeChart extends StatefulWidget {
  const FocusTimeChart({
    super.key,
    required this.data,
  });

  final List<FocusTimeStat> data;

  @override
  State<FocusTimeChart> createState() => _FocusTimeChartState();
}

class _FocusTimeChartState extends State<FocusTimeChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    // 최대값 계산 (분 단위)
    final maxMinutes = widget.data
        .map((d) => d.minutes.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxMinutes < 30 ? 30.0 : maxMinutes + 10;

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
          // 총 집중 시간 요약
          _buildSummary(),
          const SizedBox(height: 16),
          // 차트
          SizedBox(
            height: 160,
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
                        '${stat.date.month}/${stat.date.day}\n${stat.timeFormatted} (${stat.sessions}세션)',
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

  Widget _buildSummary() {
    // 총 집중 시간 계산
    final totalMinutes = widget.data.fold<int>(0, (sum, d) => sum + d.minutes);
    final totalSessions = widget.data.fold<int>(0, (sum, d) => sum + d.sessions);

    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeText = hours > 0 ? '${hours}시간 ${mins}분' : '${mins}분';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryItem('⏱', timeText, '총 집중 시간'),
        Container(
          width: 1,
          height: 40,
          color: DoodleColors.paperGrid,
        ),
        _buildSummaryItem('🎯', '$totalSessions', '완료 세션'),
      ],
    );
  }

  Widget _buildSummaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value,
              style: DoodleTypography.titleMedium.copyWith(
                color: DoodleColors.pencilDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: DoodleTypography.labelSmall.copyWith(
            color: DoodleColors.pencilLight,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isTouched = index == _touchedIndex;

      return DoodleChartTheme.barGroupData(
        x: index,
        value: stat.minutes.toDouble(),
        color: DoodleColors.crayonBlue,
        width: 20,
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
            // 요일 표시
            const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
            final weekday = weekdays[stat.date.weekday - 1];
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                weekday,
                style: DoodleTypography.labelSmall.copyWith(
                  color: DoodleColors.pencilLight,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTitlesWidget: (value, meta) {
            // 분을 시간:분 형식으로 표시
            final mins = value.toInt();
            String text;
            if (mins >= 60) {
              text = '${mins ~/ 60}h';
            } else {
              text = '${mins}m';
            }
            return Text(
              text,
              style: DoodleTypography.labelSmall.copyWith(
                color: DoodleColors.pencilLight,
                fontSize: 10,
              ),
            );
          },
        ),
      ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              '집중 기록이 없습니다',
              style: DoodleTypography.bodyMedium.copyWith(
                color: DoodleColors.pencilLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '포모도로 타이머를 사용해보세요!',
              style: DoodleTypography.labelSmall.copyWith(
                color: DoodleColors.pencilLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
