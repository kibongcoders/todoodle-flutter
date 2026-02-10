import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';

/// 줄노트 스타일 배경 위젯
///
/// 노트북 페이지처럼 수평선이 그려진 배경을 제공합니다.
class DoodleLinedBackground extends StatelessWidget {
  const DoodleLinedBackground({
    super.key,
    required this.child,
    this.lineSpacing = 28.0,
    this.lineColor,
    this.backgroundColor,
    this.showMarginLine = false,
    this.marginLineColor,
    this.marginPosition = 40.0,
  });

  /// 내부 컨텐츠
  final Widget child;

  /// 줄 간격 (기본값: 28)
  final double lineSpacing;

  /// 줄 색상 (기본값: paperGrid)
  final Color? lineColor;

  /// 배경 색상 (기본값: paperCream)
  final Color? backgroundColor;

  /// 왼쪽 여백선 표시 여부
  final bool showMarginLine;

  /// 여백선 색상 (기본값: highlightPink)
  final Color? marginLineColor;

  /// 여백선 위치 (기본값: 40)
  final double marginPosition;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? DoodleColors.paperCream,
      child: CustomPaint(
        painter: _LinedPaperPainter(
          lineSpacing: lineSpacing,
          lineColor: lineColor ?? DoodleColors.paperGrid,
          showMarginLine: showMarginLine,
          marginLineColor: marginLineColor ?? DoodleColors.highlightPink,
          marginPosition: marginPosition,
        ),
        child: child,
      ),
    );
  }
}

/// 줄노트 페인터
class _LinedPaperPainter extends CustomPainter {
  _LinedPaperPainter({
    required this.lineSpacing,
    required this.lineColor,
    required this.showMarginLine,
    required this.marginLineColor,
    required this.marginPosition,
  });

  final double lineSpacing;
  final Color lineColor;
  final bool showMarginLine;
  final Color marginLineColor;
  final double marginPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    // 수평선 그리기
    var y = lineSpacing;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
      y += lineSpacing;
    }

    // 여백선 그리기 (선택적)
    if (showMarginLine) {
      final marginPaint = Paint()
        ..color = marginLineColor
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset(marginPosition, 0),
        Offset(marginPosition, size.height),
        marginPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinedPaperPainter oldDelegate) {
    return lineSpacing != oldDelegate.lineSpacing ||
        lineColor != oldDelegate.lineColor ||
        showMarginLine != oldDelegate.showMarginLine ||
        marginLineColor != oldDelegate.marginLineColor ||
        marginPosition != oldDelegate.marginPosition;
  }
}

/// 모눈종이 스타일 배경 위젯
class DoodleGridBackground extends StatelessWidget {
  const DoodleGridBackground({
    super.key,
    required this.child,
    this.gridSize = 20.0,
    this.lineColor,
    this.backgroundColor,
  });

  final Widget child;
  final double gridSize;
  final Color? lineColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? DoodleColors.paperCream,
      child: CustomPaint(
        painter: _GridPaperPainter(
          gridSize: gridSize,
          lineColor: lineColor ?? DoodleColors.paperGrid.withValues(alpha: 0.5),
        ),
        child: child,
      ),
    );
  }
}

/// 모눈종이 페인터
class _GridPaperPainter extends CustomPainter {
  _GridPaperPainter({
    required this.gridSize,
    required this.lineColor,
  });

  final double gridSize;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    // 수직선
    var x = gridSize;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += gridSize;
    }

    // 수평선
    var y = gridSize;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += gridSize;
    }
  }

  @override
  bool shouldRepaint(covariant _GridPaperPainter oldDelegate) {
    return gridSize != oldDelegate.gridSize || lineColor != oldDelegate.lineColor;
  }
}

/// 점선 노트 스타일 배경 위젯
class DoodleDottedBackground extends StatelessWidget {
  const DoodleDottedBackground({
    super.key,
    required this.child,
    this.dotSpacing = 20.0,
    this.dotRadius = 1.0,
    this.dotColor,
    this.backgroundColor,
  });

  final Widget child;
  final double dotSpacing;
  final double dotRadius;
  final Color? dotColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? DoodleColors.paperCream,
      child: CustomPaint(
        painter: _DottedPaperPainter(
          dotSpacing: dotSpacing,
          dotRadius: dotRadius,
          dotColor: dotColor ?? DoodleColors.paperGrid,
        ),
        child: child,
      ),
    );
  }
}

/// 점선 노트 페인터
class _DottedPaperPainter extends CustomPainter {
  _DottedPaperPainter({
    required this.dotSpacing,
    required this.dotRadius,
    required this.dotColor,
  });

  final double dotSpacing;
  final double dotRadius;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    var y = dotSpacing;
    while (y < size.height) {
      var x = dotSpacing;
      while (x < size.width) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
        x += dotSpacing;
      }
      y += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPaperPainter oldDelegate) {
    return dotSpacing != oldDelegate.dotSpacing ||
        dotRadius != oldDelegate.dotRadius ||
        dotColor != oldDelegate.dotColor;
  }
}
