import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/doodle_colors.dart';
import '../models/doodle.dart';
import '../providers/sketchbook_provider.dart';
import '../widgets/doodle_widget.dart';

/// 스케치북 화면
///
/// 완성된 낙서들을 페이지 넘기기 형태로 보여주는 갤러리입니다.
class SketchbookScreen extends StatefulWidget {
  const SketchbookScreen({super.key});

  @override
  State<SketchbookScreen> createState() => _SketchbookScreenState();
}

class _SketchbookScreenState extends State<SketchbookScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodleColors.paperCream,
      appBar: AppBar(
        title: const Text('내 스케치북'),
        backgroundColor: DoodleColors.paperWhite,
        foregroundColor: DoodleColors.pencilDark,
        elevation: 0,
      ),
      body: Consumer<SketchbookProvider>(
        builder: (context, provider, _) {
          if (!provider.initialized) {
            return const Center(
              child: CircularProgressIndicator(
                color: DoodleColors.primary,
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              return Column(
                children: [
                  // 통계 카드
                  _buildStatsCard(provider, isWide),

                  // 현재 그리는 낙서
                  if (provider.currentDoodle != null)
                    _buildCurrentDoodleSection(
                      provider.currentDoodle!,
                      constraints.maxWidth,
                    ),

                  // 스케치북 갤러리
                  Expanded(
                    child: _buildSketchbookGallery(provider, constraints),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(SketchbookProvider provider, bool isWide) {
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
                  isWide: isWide,
                ),
                _buildStatItem(
                  icon: Icons.brush_outlined,
                  label: '완성된 낙서',
                  value: '${provider.totalDoodlesCompleted}',
                  color: DoodleColors.primary,
                  isWide: isWide,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: '연속 기록',
                  value: '${provider.currentStreak}일',
                  color: DoodleColors.warning,
                  isWide: isWide,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: DoodleColors.paperGrid),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryCount(
                  '간단',
                  provider.simpleCount,
                  DoodleColors.crayonBlue,
                ),
                _buildCategoryCount(
                  '보통',
                  provider.mediumCount,
                  DoodleColors.crayonGreen,
                ),
                _buildCategoryCount(
                  '복잡',
                  provider.complexCount,
                  DoodleColors.crayonPurple,
                ),
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
    required bool isWide,
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

  Widget _buildCurrentDoodleSection(Doodle doodle, double screenWidth) {
    final doodleSize = screenWidth > 600 ? 90.0 : 70.0;
    final horizontalMargin = screenWidth > 600 ? 20.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoodleColors.highlightYellow,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: DoodleColors.paperShadow,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 낙서 미리보기
          SizedBox(
            width: doodleSize,
            height: doodleSize,
            child: AnimatedDoodleWidget(
              doodle: doodle,
              size: doodleSize,
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지금 그리는 중: ${doodle.typeName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DoodleColors.pencilDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doodle.categoryName} 낙서 (${doodle.maxStrokes}획)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: DoodleColors.pencilLight,
                  ),
                ),
                const SizedBox(height: 8),
                // 진행률 바
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: doodle.progress,
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
                      '${doodle.currentStroke}/${doodle.maxStrokes}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DoodleColors.pencilLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSketchbookGallery(
      SketchbookProvider provider, BoxConstraints constraints) {
    final doodles = provider.completedDoodles;

    if (doodles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: DoodleColors.pencilLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 완성된 낙서가 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: DoodleColors.pencilDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '할일을 완료하면 낙서가 한 획씩 그려져요!',
              style: TextStyle(
                fontSize: 14,
                color: DoodleColors.pencilLight,
              ),
            ),
          ],
        ),
      );
    }

    final totalPages = provider.totalPages;

    return Column(
      children: [
        // 페이지 인디케이터
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: DoodleColors.pencilDark,
              ),
              Text(
                '${_currentPage + 1} / $totalPages 페이지',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DoodleColors.pencilDark,
                ),
              ),
              IconButton(
                onPressed: _currentPage < totalPages - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: DoodleColors.pencilDark,
              ),
            ],
          ),
        ),

        // 페이지 뷰
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, pageIndex) {
              return _buildSketchbookPage(
                provider.getDoodlesForPage(pageIndex),
                pageIndex,
                constraints,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSketchbookPage(
      List<Doodle> doodles, int pageIndex, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;
    final doodleSize = isWide ? 140.0 : 100.0;

    return Container(
      margin: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DoodleColors.paperGrid,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: DoodleColors.paperShadow,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 페이지 헤더 (노트 스프링 느낌)
          Container(
            height: 30,
            decoration: const BoxDecoration(
              color: DoodleColors.paperGrid,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                isWide ? 10 : 6,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: DoodleColors.paperWhite,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // 낙서 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: doodles.isEmpty
                  ? Center(
                      child: Text(
                        '이 페이지는 아직 비어있어요',
                        style: TextStyle(
                          color: DoodleColors.pencilLight.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: doodles.map((doodle) {
                        return DoodleWidget(
                          doodle: doodle,
                          size: doodleSize,
                          showLabel: true,
                        );
                      }).toList(),
                    ),
            ),
          ),

          // 페이지 번호
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '- ${pageIndex + 1} -',
              style: const TextStyle(
                fontSize: 12,
                color: DoodleColors.pencilLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
