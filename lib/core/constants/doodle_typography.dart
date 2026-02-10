import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'doodle_colors.dart';

/// Todoodle 앱의 Doodle 컨셉 타이포그래피 시스템
///
/// 손글씨 폰트와 가독성을 균형있게 조합한 텍스트 스타일입니다.
/// - 제목: Gaegu (귀여운 손글씨)
/// - 본문: Nanum Gothic (가독성)
class DoodleTypography {
  DoodleTypography._();

  // ============================================
  // Font Families (폰트 패밀리)
  // ============================================

  /// 손글씨 폰트 가져오기 (Gaegu - 귀여운 손글씨)
  static TextStyle _handwriting({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = DoodleColors.pencilDark,
    double height = 1.4,
    double letterSpacing = 0,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return GoogleFonts.gaegu(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// 본문 폰트 가져오기 (Nanum Gothic - 가독성)
  static TextStyle _body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = DoodleColors.pencilDark,
    double height = 1.4,
    double letterSpacing = 0,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return GoogleFonts.nanumGothic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  // ============================================
  // Headlines (제목 스타일) - 손글씨 폰트
  // ============================================

  /// 대형 제목 - 36px, 손글씨
  static TextStyle get headlineLarge => _handwriting(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: DoodleColors.inkBlack,
        height: 1.2,
        letterSpacing: -0.5,
      );

  /// 중형 제목 - 28px, 손글씨
  static TextStyle get headlineMedium => _handwriting(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: DoodleColors.inkBlack,
        height: 1.2,
        letterSpacing: -0.3,
      );

  /// 소형 제목 - 22px, 손글씨
  static TextStyle get headlineSmall => _handwriting(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.2,
      );

  // ============================================
  // Titles (타이틀 스타일) - 손글씨 폰트
  // ============================================

  /// 대형 타이틀 - 20px, 손글씨
  static TextStyle get titleLarge => _handwriting(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.3,
      );

  /// 중형 타이틀 - 18px, 손글씨
  static TextStyle get titleMedium => _handwriting(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.3,
      );

  /// 소형 타이틀 - 16px, 손글씨
  static TextStyle get titleSmall => _handwriting(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.3,
      );

  // ============================================
  // Body (본문 스타일) - 가독성 폰트
  // ============================================

  /// 대형 본문 - 16px
  static TextStyle get bodyLarge => _body(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DoodleColors.pencilDark,
        height: 1.5,
      );

  /// 중형 본문 - 14px
  static TextStyle get bodyMedium => _body(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DoodleColors.pencilDark,
        height: 1.5,
      );

  /// 소형 본문 - 12px
  static TextStyle get bodySmall => _body(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DoodleColors.pencilLight,
        height: 1.5,
      );

  // ============================================
  // Labels (라벨 스타일) - 손글씨 폰트
  // ============================================

  /// 대형 라벨 - 15px, 손글씨
  static TextStyle get labelLarge => _handwriting(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.3,
      );

  /// 중형 라벨 - 13px, 손글씨
  static TextStyle get labelMedium => _handwriting(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.3,
      );

  /// 소형 라벨 - 11px, 손글씨
  static TextStyle get labelSmall => _handwriting(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilLight,
        height: 1.3,
      );

  // ============================================
  // Special Styles (특수 스타일)
  // ============================================

  /// 할일 제목 - 기본 (손글씨)
  static TextStyle get todoTitle => _handwriting(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.3,
      );

  /// 할일 제목 - 완료 (취소선, 손글씨)
  static TextStyle get todoTitleCompleted => _handwriting(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DoodleColors.pencilLight,
        height: 1.3,
        decoration: TextDecoration.lineThrough,
        decorationColor: DoodleColors.crayonRed,
        decorationThickness: 2,
      );

  /// 할일 설명 (본문 폰트)
  static TextStyle get todoDescription => _body(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: DoodleColors.pencilLight,
        height: 1.4,
      );

  /// 배지/태그 텍스트 (손글씨)
  static TextStyle get badge => _handwriting(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  /// 숫자 강조 (타이머 등) - 손글씨
  static TextStyle get numberLarge => _handwriting(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.0,
        letterSpacing: 2,
      );

  /// 숫자 중형 - 손글씨
  static TextStyle get numberMedium => _handwriting(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: DoodleColors.pencilDark,
        height: 1.2,
      );

  /// 힌트/플레이스홀더 (본문 폰트)
  static TextStyle get hint => _body(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DoodleColors.pencilLight,
        fontStyle: FontStyle.italic,
        height: 1.4,
      );

  /// 버튼 텍스트 (손글씨)
  static TextStyle get button => _handwriting(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.5,
      );

  /// 링크 텍스트 (본문 폰트)
  static TextStyle get link => _body(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DoodleColors.inkBlue,
        decoration: TextDecoration.underline,
        decorationColor: DoodleColors.inkBlue,
        height: 1.4,
      );
}
