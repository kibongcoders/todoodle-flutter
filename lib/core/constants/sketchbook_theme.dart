import 'package:flutter/material.dart';

import 'doodle_colors.dart';

/// 스케치북 테마 종류
enum SketchbookTheme {
  plain, // 도화지 (기본)
  grid, // 격자 노트
  craft, // 크래프트지
  chalkboard, // 흑판
}

/// 스케치북 테마별 시각 속성
class SketchbookThemeData {
  const SketchbookThemeData({
    required this.name,
    required this.emoji,
    required this.backgroundColor,
    required this.pageColor,
    required this.lineColor,
    required this.doodleStrokeColor,
    required this.labelColor,
    required this.headerColor,
    required this.borderColor,
  });

  final String name;
  final String emoji;
  final Color backgroundColor;
  final Color pageColor;
  final Color lineColor;
  final Color doodleStrokeColor;
  final Color labelColor;
  final Color headerColor;
  final Color borderColor;

  /// 테마별 데이터 조회
  static SketchbookThemeData of(SketchbookTheme theme) {
    return _themes[theme]!;
  }

  static const Map<SketchbookTheme, SketchbookThemeData> _themes = {
    SketchbookTheme.plain: SketchbookThemeData(
      name: '도화지',
      emoji: '📄',
      backgroundColor: DoodleColors.paperCream,
      pageColor: DoodleColors.paperWhite,
      lineColor: Colors.transparent,
      doodleStrokeColor: DoodleColors.pencilDark,
      labelColor: DoodleColors.pencilLight,
      headerColor: DoodleColors.paperGrid,
      borderColor: DoodleColors.paperGrid,
    ),
    SketchbookTheme.grid: SketchbookThemeData(
      name: '격자 노트',
      emoji: '📐',
      backgroundColor: DoodleColors.paperCream,
      pageColor: DoodleColors.paperWhite,
      lineColor: Color(0xFFD0D8E8),
      doodleStrokeColor: DoodleColors.pencilDark,
      labelColor: DoodleColors.pencilLight,
      headerColor: Color(0xFFD0D8E8),
      borderColor: Color(0xFFB8C4D8),
    ),
    SketchbookTheme.craft: SketchbookThemeData(
      name: '크래프트지',
      emoji: '📦',
      backgroundColor: Color(0xFFD7C4A7),
      pageColor: Color(0xFFE8D5B7),
      lineColor: Colors.transparent,
      doodleStrokeColor: Color(0xFF5D4037),
      labelColor: Color(0xFF795548),
      headerColor: Color(0xFFBEA98A),
      borderColor: Color(0xFFAA9270),
    ),
    SketchbookTheme.chalkboard: SketchbookThemeData(
      name: '흑판',
      emoji: '🏫',
      backgroundColor: Color(0xFF2D4A3E),
      pageColor: Color(0xFF355347),
      lineColor: Colors.transparent,
      doodleStrokeColor: Color(0xFFE8E8E0),
      labelColor: Color(0xFFB0C4B0),
      headerColor: Color(0xFF243D33),
      borderColor: Color(0xFF4A6B5A),
    ),
  };
}
