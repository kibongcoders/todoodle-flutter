import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/doodle_colors.dart';
import '../../../../core/constants/doodle_typography.dart';
import '../../../../shared/widgets/doodle_background.dart';
import '../../../../widgets/doodle_chip.dart';
import '../../domain/models/statistics_data.dart';
import '../providers/statistics_provider.dart';
import '../widgets/category_bar_chart.dart';
import '../widgets/completion_chart.dart';
import '../widgets/focus_time_chart.dart';
import '../widgets/priority_pie_chart.dart';
import '../widgets/stat_summary_card.dart';

/// 통계 화면
///
/// Doodle 스타일의 통계 대시보드입니다.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodleColors.paperCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: DoodleColors.pencilDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '📊 통계',
          style: DoodleTypography.titleLarge.copyWith(
            color: DoodleColors.pencilDark,
          ),
        ),
        centerTitle: true,
      ),
      body: DoodleLinedBackground(
        lineSpacing: 28,
        child: Consumer<StatisticsProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기간 필터
                  _buildPeriodFilter(context, provider),
                  const SizedBox(height: 24),

                  // 요약 카드
                  StatSummaryCard(stats: provider.summaryStats),
                  const SizedBox(height: 24),

                  // 완료율 추이 차트
                  _buildSectionTitle('📈 완료 추이'),
                  const SizedBox(height: 12),
                  CompletionChart(
                    data: provider.completionTrend,
                    period: provider.period,
                  ),
                  const SizedBox(height: 24),

                  // 우선순위 분포 차트
                  _buildSectionTitle('⚡ 우선순위별 분포'),
                  const SizedBox(height: 12),
                  PriorityPieChart(data: provider.priorityDistribution),
                  const SizedBox(height: 24),

                  // 카테고리별 통계
                  if (provider.categoryStats.isNotEmpty) ...[
                    _buildSectionTitle('📁 카테고리별 통계'),
                    const SizedBox(height: 12),
                    CategoryBarChart(data: provider.categoryStats),
                    const SizedBox(height: 24),
                  ],

                  // 집중 시간 차트
                  _buildSectionTitle('🎯 집중 시간'),
                  const SizedBox(height: 12),
                  FocusTimeChart(data: provider.focusTimeStats),
                  const SizedBox(height: 24),

                  // 인사이트 섹션
                  _buildInsightsSection(provider.insights),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 기간 필터 칩
  Widget _buildPeriodFilter(
      BuildContext context, StatisticsProvider provider) {
    return Center(
      child: DoodleChipGroup<StatsPeriod>(
        items: StatsPeriod.values,
        selectedItem: provider.period,
        labelBuilder: (period) => period.label,
        emojiBuilder: (period) => period.emoji,
        onSelected: (period) => provider.setPeriod(period),
        colorBuilder: (_) => DoodleColors.highlightYellow,
      ),
    );
  }

  /// 섹션 타이틀
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DoodleTypography.titleMedium.copyWith(
        color: DoodleColors.pencilDark,
      ),
    );
  }

  /// 인사이트 섹션
  Widget _buildInsightsSection(StatsInsights insights) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 인사이트',
            style: DoodleTypography.titleMedium.copyWith(
              color: DoodleColors.pencilDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightRow(
            '🏆',
            '가장 생산적인 요일',
            '${insights.weekdayName}요일',
          ),
          const SizedBox(height: 12),
          if (insights.topCategory != null)
            _buildInsightRow(
              '📁',
              '가장 많이 사용한 카테고리',
              insights.topCategory!,
            ),
          if (insights.topCategory != null) const SizedBox(height: 12),
          _buildInsightRow(
            '📊',
            '평균 완료율',
            '${(insights.avgCompletionRate * 100).toInt()}%',
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            '🔥',
            '최장 연속 달성',
            '${insights.longestStreak}일',
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            '✅',
            '일 평균 완료',
            '${insights.avgDailyCompleted.toStringAsFixed(1)}개',
          ),
        ],
      ),
    );
  }

  /// 인사이트 행
  Widget _buildInsightRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: DoodleTypography.bodyMedium.copyWith(
              color: DoodleColors.pencilLight,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DoodleColors.highlightYellow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: DoodleTypography.labelMedium.copyWith(
              color: DoodleColors.pencilDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
