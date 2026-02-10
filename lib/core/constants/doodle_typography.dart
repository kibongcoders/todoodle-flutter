import 'package:flutter/material.dart';

import 'doodle_colors.dart';

/// Todoodle 앱의 Doodle 컨셉 타이포그래피 시스템
///
/// 손글씨 느낌과 가독성을 균형있게 조합한 텍스트 스타일입니다.
/// - 제목: 손글씨 느낌 (추후 커스텀 폰트 적용 가능)
/// - 본문: 기본 폰트로 가독성 확보
class DoodleTypography {
  DoodleTypography._();

  // ============================================
  // Font Families (폰트 패밀리)
  // ============================================

  /// 손글씨 폰트 (제목용) - 추후 NanumPen 등으로 교체 가능
  static const String handwritingFont = 'Pretendard';

  /// 기본 폰트 (본문용)
  static const String bodyFont = 'Pretendard';

  // ============================================
  // Headlines (제목 스타일)
  // ============================================

  /// 대형 제목 - 32px, 손글씨 느낌
  static const headlineLarge = TextStyle(
    fontFamily: handwritingFont,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: DoodleColors.inkBlack,
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// 중형 제목 - 24px
  static const headlineMedium = TextStyle(
    fontFamily: handwritingFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: DoodleColors.inkBlack,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// 소형 제목 - 20px
  static const headlineSmall = TextStyle(
    fontFamily: handwritingFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: DoodleColors.pencilDark,
    height: 1.3,
  );

  // ============================================
  // Titles (타이틀 스타일)
  // ============================================

  /// 대형 타이틀 - 18px, Bold
  static const titleLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: DoodleColors.pencilDark,
    height: 1.4,
  );

  /// 중형 타이틀 - 16px, SemiBold
  static const titleMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilDark,
    height: 1.4,
  );

  /// 소형 타이틀 - 14px, Medium
  static const titleSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilDark,
    height: 1.4,
  );

  // ============================================
  // Body (본문 스타일)
  // ============================================

  /// 대형 본문 - 16px
  static const bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
    height: 1.5,
  );

  /// 중형 본문 - 14px
  static const bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
    height: 1.5,
  );

  /// 소형 본문 - 12px
  static const bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilLight,
    height: 1.5,
  );

  // ============================================
  // Labels (라벨 스타일)
  // ============================================

  /// 대형 라벨 - 14px, Medium
  static const labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilDark,
    height: 1.3,
  );

  /// 중형 라벨 - 12px, Medium
  static const labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilDark,
    height: 1.3,
  );

  /// 소형 라벨 - 10px
  static const labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilLight,
    height: 1.3,
  );

  // ============================================
  // Special Styles (특수 스타일)
  // ============================================

  /// 할일 제목 - 기본
  static const todoTitle = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: DoodleColors.pencilDark,
    height: 1.4,
  );

  /// 할일 제목 - 완료 (취소선)
  static const todoTitleCompleted = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilLight,
    height: 1.4,
    decoration: TextDecoration.lineThrough,
    decorationColor: DoodleColors.crayonRed,
    decorationThickness: 2,
  );

  /// 할일 설명
  static const todoDescription = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilLight,
    height: 1.4,
  );

  /// 배지/태그 텍스트
  static const badge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// 숫자 강조 (타이머 등)
  static const numberLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: DoodleColors.pencilDark,
    height: 1.0,
    letterSpacing: 2,
  );

  /// 숫자 중형
  static const numberMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilDark,
    height: 1.2,
  );

  /// 힌트/플레이스홀더
  static const hint = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DoodleColors.pencilLight,
    fontStyle: FontStyle.italic,
    height: 1.4,
  );

  /// 버튼 텍스트
  static const button = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// 링크 텍스트
  static const link = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DoodleColors.inkBlue,
    decoration: TextDecoration.underline,
    decorationColor: DoodleColors.inkBlue,
    height: 1.4,
  );
}
