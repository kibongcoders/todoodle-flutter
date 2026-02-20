import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/doodle_colors.dart';
import '../shared/widgets/doodle_icon.dart';
import '../core/constants/sketchbook_theme.dart';
import '../models/doodle.dart';
import '../providers/sketchbook_provider.dart';
import '../widgets/crayon_color_picker.dart';
import '../widgets/doodle_widget.dart';
import '../widgets/sketchbook/level_card.dart';
import '../widgets/sketchbook/sketchbook_page.dart';
import '../widgets/sketchbook/stats_card.dart';
import '../widgets/sketchbook/theme_selector.dart';
import 'doodle_collection_screen.dart';

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
  final _repaintKey = GlobalKey();

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
        actions: [
          IconButton(
            onPressed: _shareCurrentPage,
            icon: const DoodleIcon(type: DoodleIconType.share),
            tooltip: '페이지 공유',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoodleCollectionScreen()),
            ),
            icon: const Icon(Icons.auto_stories_outlined),
            tooltip: '낙서 도감',
          ),
        ],
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
                  // 레벨 프로필
                  LevelCard(isWide: isWide),

                  // 통계 카드
                  StatsCard(isWide: isWide),

                  // 현재 그리는 낙서
                  if (provider.currentDoodle != null)
                    _buildCurrentDoodleSection(
                      provider.currentDoodle!,
                      constraints.maxWidth,
                    ),

                  // 테마 선택
                  const ThemeSelector(),

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

  Future<void> _shareCurrentPage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;

        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/todoodle_page_${_currentPage + 1}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Todoodle 스케치북 ${_currentPage + 1}페이지',
        );
      } finally {
        image.dispose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유에 실패했어요')),
        );
      }
    }
  }

  void _showColorPicker(Doodle doodle) {
    CrayonColorPicker.show(
      context,
      currentColorIndex: doodle.colorIndex,
      onColorSelected: (colorIndex) {
        context.read<SketchbookProvider>().colorDoodle(doodle.id, colorIndex);
      },
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
    final isWide = constraints.maxWidth > 600;

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
              final page = SketchbookPage(
                doodles: provider.getDoodlesForPage(pageIndex),
                pageIndex: pageIndex,
                themeData: SketchbookThemeData.of(provider.currentTheme),
                isWide: isWide,
                onDoodleTap: _showColorPicker,
              );
              // 현재 페이지만 RepaintBoundary로 감싸기 (공유 캡처용)
              if (pageIndex == _currentPage) {
                return RepaintBoundary(
                  key: _repaintKey,
                  child: page,
                );
              }
              return page;
            },
          ),
        ),
      ],
    );
  }
}
