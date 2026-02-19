import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';
import '../../core/constants/sketchbook_theme.dart';
import '../../models/doodle.dart';
import '../doodle_widget.dart';

/// 스케치북 갤러리 페이지 위젯
class SketchbookPage extends StatelessWidget {
  const SketchbookPage({
    super.key,
    required this.doodles,
    required this.pageIndex,
    required this.themeData,
    required this.isWide,
    this.onDoodleTap,
  });

  final List<Doodle> doodles;
  final int pageIndex;
  final SketchbookThemeData themeData;
  final bool isWide;
  final void Function(Doodle doodle)? onDoodleTap;

  @override
  Widget build(BuildContext context) {
    final doodleSize = isWide ? 140.0 : 100.0;

    return Container(
      margin: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        color: themeData.pageColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeData.borderColor,
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
            decoration: BoxDecoration(
              color: themeData.headerColor,
              borderRadius: const BorderRadius.only(
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
                  decoration: BoxDecoration(
                    color: themeData.pageColor,
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
                          color: themeData.labelColor.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: doodles.map((doodle) {
                        return GestureDetector(
                          onTap: doodle.isCompleted
                              ? () => onDoodleTap?.call(doodle)
                              : null,
                          child: DoodleWidget(
                            doodle: doodle,
                            size: doodleSize,
                            showLabel: true,
                            strokeColor: themeData.doodleStrokeColor,
                            backgroundColor: themeData.pageColor,
                            labelColor: themeData.labelColor,
                          ),
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
              style: TextStyle(
                fontSize: 12,
                color: themeData.labelColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
