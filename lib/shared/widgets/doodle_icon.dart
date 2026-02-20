import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';
import '../painters/doodle_icon_painter.dart';

/// 손그림 아이콘 타입
enum DoodleIconType {
  // 네비게이션 (5)
  home,
  calendar,
  timer,
  fire,
  settings,

  // 공통 액션 (10)
  add,
  close,
  check,
  arrowBack,
  chevronLeft,
  chevronRight,
  search,
  mic,
  filter,
  delete,
  edit,

  // 미디어 컨트롤 (4)
  play,
  pause,
  stop,
  skipNext,

  // 기타 (6)
  share,
  dragHandle,
  arrowUp,
  arrowDown,
  lock,
  restore,
}

/// Doodle 스타일 손그림 아이콘 위젯
///
/// CustomPainter로 그린 손그림 느낌의 아이콘입니다.
/// DoodleCheckbox와 동일한 wobble 패턴을 사용합니다.
class DoodleIcon extends StatelessWidget {
  const DoodleIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.0,
  });

  /// 아이콘 타입
  final DoodleIconType type;

  /// 아이콘 크기
  final double size;

  /// 아이콘 색상 (기본값: pencilDark)
  final Color? color;

  /// 선 두께
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DoodleIconPainter(
        type: type,
        color: color ?? DoodleColors.pencilDark,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
