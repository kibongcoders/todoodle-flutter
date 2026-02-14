import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';

/// Doodle 스타일 차트 테마
///
/// fl_chart를 Doodle 디자인 시스템에 맞게 스타일링합니다.
class DoodleChartTheme {
  DoodleChartTheme._();

  // ============================================
  // 공통 스타일
  // ============================================

  /// 그리드 데이터 (점선 스타일)
  static FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: DoodleColors.paperGrid,
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      );

  /// 테두리 데이터 (없음)
  static FlBorderData get borderData => FlBorderData(show: false);

  // ============================================
  // 라인 차트 스타일
  // ============================================

  /// 메인 라인 스타일
  static LineChartBarData lineBarData({
    required List<FlSpot> spots,
    Color? color,
    bool showDots = true,
    bool isCurved = true,
    double barWidth = 3,
  }) {
    final lineColor = color ?? DoodleColors.primary;
    return LineChartBarData(
      spots: spots,
      isCurved: isCurved,
      color: lineColor,
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: DoodleColors.paperWhite,
          strokeWidth: 2,
          strokeColor: lineColor,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.3),
            lineColor.withValues(alpha: 0.05),
          ],
        ),
      ),
    );
  }

  /// 라인 차트 터치 데이터
  static LineTouchData lineTouchData({
    required String Function(LineBarSpot spot) getTooltipText,
  }) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) =>
            DoodleColors.pencilDark.withValues(alpha: 0.9),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              getTooltipText(spot),
              DoodleTypography.labelSmall.copyWith(
                color: DoodleColors.paperWhite,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  // ============================================
  // 파이 차트 스타일
  // ============================================

  /// 우선순위 색상 목록
  static List<Color> get priorityColors => [
        DoodleColors.priorityVeryLow,
        DoodleColors.priorityLow,
        DoodleColors.priorityMedium,
        DoodleColors.priorityHigh,
        DoodleColors.priorityVeryHigh,
      ];

  /// 카테고리 색상 목록 (크레용 색상)
  static List<Color> get categoryColors => [
        DoodleColors.crayonGreen,
        DoodleColors.crayonBlue,
        DoodleColors.crayonPurple,
        DoodleColors.crayonOrange,
        DoodleColors.crayonRed,
        DoodleColors.crayonYellow,
      ];

  /// 파이 차트 섹션 스타일
  static PieChartSectionData pieSectionData({
    required double value,
    required String title,
    required Color color,
    bool isTouched = false,
    double radius = 50,
  }) {
    final fontSize = isTouched ? 14.0 : 12.0;
    final actualRadius = isTouched ? radius + 10 : radius;

    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: actualRadius,
      titleStyle: DoodleTypography.badge.copyWith(
        fontSize: fontSize,
        color: DoodleColors.pencilDark,
        fontWeight: FontWeight.bold,
      ),
      titlePositionPercentageOffset: 0.6,
    );
  }

  /// 파이 차트 터치 데이터
  static PieTouchData pieTouchData({
    required void Function(int?) onTouch,
  }) {
    return PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        if (!event.isInterestedForInteractions ||
            pieTouchResponse == null ||
            pieTouchResponse.touchedSection == null) {
          onTouch(null);
          return;
        }
        onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
      },
    );
  }

  // ============================================
  // 바 차트 스타일
  // ============================================

  /// 바 차트 그룹 데이터
  static BarChartGroupData barGroupData({
    required int x,
    required double value,
    Color? color,
    double width = 16,
    bool isTouched = false,
  }) {
    final barColor = color ?? DoodleColors.primary;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: isTouched ? barColor : barColor.withValues(alpha: 0.8),
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0,
            color: DoodleColors.paperGrid.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  /// 바 차트 터치 데이터
  static BarTouchData barTouchData({
    required String Function(BarChartGroupData group, BarChartRodData rod)
        getTooltipText,
  }) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) =>
            DoodleColors.pencilDark.withValues(alpha: 0.9),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            getTooltipText(group, rod),
            DoodleTypography.labelSmall.copyWith(
              color: DoodleColors.paperWhite,
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // 축 스타일
  // ============================================

  /// 하단 축 타이틀 위젯
  static Widget bottomTitleWidget(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: DoodleTypography.labelSmall.copyWith(
          color: DoodleColors.pencilLight,
        ),
      ),
    );
  }

  /// 좌측 축 타이틀 위젯
  static Widget leftTitleWidget(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: DoodleTypography.labelSmall.copyWith(
        color: DoodleColors.pencilLight,
      ),
      textAlign: TextAlign.right,
    );
  }

  /// 요일 하단 축 타이틀
  static Widget weekdayTitleWidget(double value, TitleMeta meta) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final index = value.toInt();
    final text = index >= 0 && index < 7 ? weekdays[index] : '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: DoodleTypography.labelSmall.copyWith(
          color: DoodleColors.pencilLight,
        ),
      ),
    );
  }

  /// 날짜 하단 축 타이틀 (M/d 형식)
  static Widget dateTitleWidget(
      double value, TitleMeta meta, List<DateTime> dates) {
    final index = value.toInt();
    if (index < 0 || index >= dates.length) {
      return const SizedBox.shrink();
    }
    final date = dates[index];
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
  }
}
