import 'package:flutter/material.dart';

/// Todoodle 앱의 Doodle 컨셉 컬러 시스템
///
/// 낙서장/노트의 따뜻하고 편안한 느낌을 주는 컬러 팔레트입니다.
/// 손그림 느낌의 UI를 구현하기 위한 컬러들을 정의합니다.
class DoodleColors {
  DoodleColors._();

  // ============================================
  // Paper & Base (종이/배경 컬러)
  // ============================================

  /// 노트 종이 - 기본 배경색 (따뜻한 크림색)
  static const paperCream = Color(0xFFFFF9E6);

  /// 밝은 종이 - 카드 배경색
  static const paperWhite = Color(0xFFFFFDF7);

  /// 모눈/줄노트 격자 색상
  static const paperGrid = Color(0xFFE8E0D0);

  /// 종이 그림자
  static const paperShadow = Color(0x1A000000);

  // ============================================
  // Pencil & Ink (연필/잉크 - 텍스트용)
  // ============================================

  /// 연필 진하게 - 기본 텍스트
  static const pencilDark = Color(0xFF4A4A4A);

  /// 연필 연하게 - 보조 텍스트, 비활성
  static const pencilLight = Color(0xFF9E9E9E);

  /// 잉크펜 파랑 - 링크, 강조
  static const inkBlue = Color(0xFF5C6BC0);

  /// 잉크펜 검정 - 제목
  static const inkBlack = Color(0xFF2D2D2D);

  // ============================================
  // Highlighters (형광펜 - 강조용)
  // ============================================

  /// 노랑 형광펜
  static const highlightYellow = Color(0xFFFFF59D);

  /// 핑크 형광펜
  static const highlightPink = Color(0xFFFF8A80);

  /// 초록 형광펜
  static const highlightGreen = Color(0xFFC5E1A5);

  /// 파랑 형광펜
  static const highlightBlue = Color(0xFF81D4FA);

  /// 주황 형광펜
  static const highlightOrange = Color(0xFFFFCC80);

  /// 보라 형광펜
  static const highlightPurple = Color(0xFFCE93D8);

  // ============================================
  // Color Pencils (색연필 - 아이콘/장식용)
  // ============================================

  /// 색연필 빨강
  static const crayonRed = Color(0xFFE57373);

  /// 색연필 주황
  static const crayonOrange = Color(0xFFFFB74D);

  /// 색연필 노랑
  static const crayonYellow = Color(0xFFFFF176);

  /// 색연필 초록
  static const crayonGreen = Color(0xFF81C784);

  /// 색연필 파랑
  static const crayonBlue = Color(0xFF64B5F6);

  /// 색연필 보라
  static const crayonPurple = Color(0xFFBA68C8);

  /// 색연필 갈색
  static const crayonBrown = Color(0xFFA1887F);

  // ============================================
  // Priority Colors (우선순위 컬러)
  // ============================================

  /// 비상! (veryHigh) - 빨간 동그라미
  static const priorityVeryHigh = Color(0xFFFF6B6B);
  static const priorityVeryHighBg = Color(0xFFFFEBEE);

  /// 서두르자 (high) - 주황 별
  static const priorityHigh = Color(0xFFFFB347);
  static const priorityHighBg = Color(0xFFFFF3E0);

  /// 보통 (medium) - 노랑 체크
  static const priorityMedium = Color(0xFFFFE066);
  static const priorityMediumBg = Color(0xFFFFFDE7);

  /// 천천히 (low) - 민트 물결
  static const priorityLow = Color(0xFF98D8C8);
  static const priorityLowBg = Color(0xFFE0F2F1);

  /// 여유롭게 (veryLow) - 하늘 점
  static const priorityVeryLow = Color(0xFFAED9E0);
  static const priorityVeryLowBg = Color(0xFFE3F2FD);

  // ============================================
  // Status Colors (상태 컬러)
  // ============================================

  /// 성공/완료 - 초록 체크
  static const success = Color(0xFF66BB6A);

  /// 경고/주의 - 주황
  static const warning = Color(0xFFFFA726);

  /// 에러/위험 - 빨강
  static const error = Color(0xFFEF5350);

  /// 정보 - 파랑
  static const info = Color(0xFF42A5F5);

  // ============================================
  // D-Day Colors (마감일 컬러)
  // ============================================

  /// 마감 지남
  static const dDayOverdue = Color(0xFFE53935);

  /// 3일 이내
  static const dDaySoon = Color(0xFFFFA726);

  /// 여유 있음
  static const dDaySafe = Color(0xFF66BB6A);

  // ============================================
  // Forest/Plant Colors (숲/식물 컬러)
  // ============================================

  /// 잔디 밝은 초록
  static const grassLight = Color(0xFF81C784);

  /// 잔디 진한 초록
  static const grassDark = Color(0xFF4CAF50);

  /// 나무 줄기 갈색
  static const treeTrunk = Color(0xFF795548);

  /// 나뭇잎 초록
  static const leafGreen = Color(0xFF66BB6A);

  /// 꽃 핑크
  static const flowerPink = Color(0xFFE91E63);

  /// 꽃 노랑 (꽃술)
  static const flowerYellow = Color(0xFFFFEB3B);

  // ============================================
  // Achievement Colors (업적 컬러)
  // ============================================

  /// 업적 골드 배경 (밝은)
  static const achievementGoldLight = Color(0xFFFFF8E1);

  /// 업적 골드 배경 (진한)
  static const achievementGoldDark = Color(0xFFFFECB3);

  /// 업적 테두리 골드
  static const achievementBorder = Color(0xFFFFD54F);

  /// 업적 텍스트 강조
  static const achievementAccent = Color(0xFFFF8F00);

  // ============================================
  // Primary Action (메인 액션 컬러)
  // ============================================

  /// 기본 액션 컬러 (낙서 초록)
  static const primary = Color(0xFF7CB342);

  /// 기본 액션 밝은 버전
  static const primaryLight = Color(0xFFA8E6CF);

  /// 기본 액션 어두운 버전
  static const primaryDark = Color(0xFF558B2F);

  // ============================================
  // Helper Methods
  // ============================================

  /// 우선순위에 따른 컬러 반환
  static Color getPriorityColor(int priorityIndex) {
    switch (priorityIndex) {
      case 4:
        return priorityVeryHigh;
      case 3:
        return priorityHigh;
      case 2:
        return priorityMedium;
      case 1:
        return priorityLow;
      case 0:
      default:
        return priorityVeryLow;
    }
  }

  /// 우선순위에 따른 배경 컬러 반환
  static Color getPriorityBackgroundColor(int priorityIndex) {
    switch (priorityIndex) {
      case 4:
        return priorityVeryHighBg;
      case 3:
        return priorityHighBg;
      case 2:
        return priorityMediumBg;
      case 1:
        return priorityLowBg;
      case 0:
      default:
        return priorityVeryLowBg;
    }
  }

  /// D-Day에 따른 컬러 반환
  static Color getDDayColor(int daysRemaining) {
    if (daysRemaining < 0) return dDayOverdue;
    if (daysRemaining <= 3) return dDaySoon;
    return dDaySafe;
  }
}
