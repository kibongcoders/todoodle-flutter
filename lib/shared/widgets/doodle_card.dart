import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';

/// Doodle 스타일 카드 위젯
///
/// 노트에 붙인 포스트잇/메모지 느낌의 카드입니다.
/// - 점선 테두리 (손그림 느낌)
/// - 약간 비대칭 그림자
/// - 종이 질감 배경
class DoodleCard extends StatelessWidget {
  const DoodleCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.useDashedBorder = false,
    this.elevation = 1,
    this.onTap,
    this.onLongPress,
  });

  /// 카드 내부 컨텐츠
  final Widget child;

  /// 내부 패딩 (기본값: 16)
  final EdgeInsetsGeometry? padding;

  /// 외부 마진 (기본값: horizontal 16, vertical 8)
  final EdgeInsetsGeometry? margin;

  /// 배경색 (기본값: paperWhite)
  final Color? color;

  /// 테두리 색상 (기본값: pencilLight 50%)
  final Color? borderColor;

  /// 점선 테두리 사용 여부
  final bool useDashedBorder;

  /// 그림자 깊이 (0-3)
  final double elevation;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 롱프레스 콜백
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? DoodleColors.paperWhite;
    final border = borderColor ?? DoodleColors.pencilLight.withValues(alpha: 0.5);

    Widget card = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(4),
        border: useDashedBorder ? null : Border.all(color: border, width: 1.5),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: DoodleColors.paperShadow,
                  offset: Offset(elevation, elevation + 1),
                  blurRadius: elevation * 0.5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: useDashedBorder
            ? CustomPaint(
                painter: _DashedBorderPainter(color: border),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}

/// 점선 테두리 페인터
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
  });

  final Color color;

  static const double _strokeWidth = 1.5;
  static const double _dashLength = 6;
  static const double _dashSpace = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );

    final path = Path()..addRRect(rect);
    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + _dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = end + _dashSpace;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

/// 하이라이트된 Doodle 카드 (형광펜 배경)
class DoodleHighlightCard extends StatelessWidget {
  const DoodleHighlightCard({
    super.key,
    required this.child,
    this.highlightColor,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final Color? highlightColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      color: highlightColor ?? DoodleColors.highlightYellow.withValues(alpha: 0.5),
      borderColor: DoodleColors.pencilLight.withValues(alpha: 0.3),
      padding: padding,
      margin: margin,
      elevation: 0.5,
      onTap: onTap,
      child: child,
    );
  }
}

/// 포스트잇 스타일 카드
class DoodlePostIt extends StatelessWidget {
  const DoodlePostIt({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.rotation = 0,
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// 회전 각도 (라디안, -0.05 ~ 0.05 권장)
  final double rotation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        margin: margin ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? DoodleColors.highlightYellow,
          boxShadow: const [
            BoxShadow(
              color: DoodleColors.paperShadow,
              offset: Offset(2, 3),
              blurRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
