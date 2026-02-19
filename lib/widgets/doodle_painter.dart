import 'package:flutter/material.dart';

import '../core/constants/doodle_colors.dart';
import '../models/doodle.dart';
import 'painters/complex_shapes.dart';
import 'painters/medium_shapes.dart';
import 'painters/rare_shapes.dart';
import 'painters/simple_shapes.dart';

/// 낙서 그리기 CustomPainter
///
/// 각 낙서 타입별로 획을 순서대로 그립니다.
/// [progress]는 현재 획 / 최대 획 비율입니다.
class DoodlePainter extends CustomPainter {
  DoodlePainter({
    required this.type,
    required this.progress,
    this.strokeColor,
    this.strokeWidth = 2.5,
    this.fillColor,
  });

  final DoodleType type;
  final double progress; // 0.0 ~ 1.0
  final Color? strokeColor;
  final double strokeWidth;
  final Color? fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 크레파스 채우기 (완성된 낙서에만)
    if (fillColor != null && progress >= 1.0) {
      final fillPaint = Paint()
        ..color = fillColor!.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      _drawShape(canvas, size, fillPaint);
    }

    final paint = Paint()
      ..color = strokeColor ?? DoodleColors.pencilDark
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawShape(canvas, size, paint);
  }

  void _drawShape(Canvas canvas, Size size, Paint paint) {
    final strokes = (progress * type.maxStrokes).ceil();

    switch (type) {
      // Simple (3획)
      case DoodleType.star:
        SimpleShapes.drawStar(canvas, size, paint, strokes);
      case DoodleType.heart:
        SimpleShapes.drawHeart(canvas, size, paint, strokes);
      case DoodleType.cloud:
        SimpleShapes.drawCloud(canvas, size, paint, strokes);
      case DoodleType.moon:
        SimpleShapes.drawMoon(canvas, size, paint, strokes);
      // Medium (5획)
      case DoodleType.house:
        MediumShapes.drawHouse(canvas, size, paint, strokes);
      case DoodleType.flower:
        MediumShapes.drawFlower(canvas, size, paint, strokes);
      case DoodleType.boat:
        MediumShapes.drawBoat(canvas, size, paint, strokes);
      case DoodleType.balloon:
        MediumShapes.drawBalloon(canvas, size, paint, strokes);
      // Complex (8획)
      case DoodleType.tree:
        ComplexShapes.drawTree(canvas, size, paint, strokes);
      case DoodleType.bicycle:
        ComplexShapes.drawBicycle(canvas, size, paint, strokes);
      case DoodleType.rocket:
        ComplexShapes.drawRocket(canvas, size, paint, strokes);
      case DoodleType.cat:
        ComplexShapes.drawCat(canvas, size, paint, strokes);
      // Rare (희귀)
      case DoodleType.rainbowStar:
        RareShapes.drawRainbowStar(canvas, size, paint, strokes);
      case DoodleType.crown:
        RareShapes.drawCrown(canvas, size, paint, strokes);
      case DoodleType.diamond:
        RareShapes.drawDiamond(canvas, size, paint, strokes);
    }
  }

  @override
  bool shouldRepaint(covariant DoodlePainter oldDelegate) {
    return type != oldDelegate.type ||
        progress != oldDelegate.progress ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        fillColor != oldDelegate.fillColor;
  }
}
