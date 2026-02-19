import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 희귀 낙서 도형 (레벨 해금: 무지개 별, 왕관, 다이아몬드)
class RareShapes {
  RareShapes._();

  /// 무지개 별 (5획: 별 외곽 5개 꼭짓점을 각각의 색으로)
  static void drawRainbowStar(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.42;
    final innerR = size.width * 0.18;

    final rainbowColors = [
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFFFFF176),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
    ];

    final points = <Offset>[];
    for (int i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = -math.pi / 2 + (i + 0.5) * 2 * math.pi / 5;
      points.add(Offset(cx + outerR * math.cos(outerAngle), cy + outerR * math.sin(outerAngle)));
      points.add(Offset(cx + innerR * math.cos(innerAngle), cy + innerR * math.sin(innerAngle)));
    }

    for (int i = 0; i < strokes && i < 5; i++) {
      final p1 = points[i * 2];
      final p2 = points[(i * 2 + 1) % 10];
      final p3 = points[(i * 2 + 2) % 10];

      final usePaint = paint.style == PaintingStyle.fill
          ? paint
          : (Paint()
            ..color = rainbowColors[i]
            ..strokeWidth = paint.strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);
      canvas.drawPath(path, usePaint);
    }
  }

  /// 왕관 (6획: 밑단, 좌측 꼭짓점, 중앙 꼭짓점, 우측 꼭짓점, 보석 3개, 장식선)
  static void drawCrown(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.15, size.height * 0.7)
        ..lineTo(size.width * 0.85, size.height * 0.7)
        ..lineTo(size.width * 0.85, size.height * 0.8)
        ..lineTo(size.width * 0.15, size.height * 0.8)
        ..close();
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.15, size.height * 0.7)
        ..lineTo(size.width * 0.25, size.height * 0.25)
        ..lineTo(size.width * 0.35, size.height * 0.5);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.35, size.height * 0.5)
        ..lineTo(cx, size.height * 0.15)
        ..lineTo(size.width * 0.65, size.height * 0.5);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.65, size.height * 0.5)
        ..lineTo(size.width * 0.75, size.height * 0.25)
        ..lineTo(size.width * 0.85, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      final gemR = size.width * 0.04;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.22), gemR, paint);
      canvas.drawCircle(Offset(cx, size.height * 0.12), gemR, paint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.22), gemR, paint);
    }

    if (strokes >= 6) {
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.75)
        ..lineTo(size.width * 0.8, size.height * 0.75);
      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset(cx, size.height * 0.75), size.width * 0.03, paint);
    }
  }

  /// 다이아몬드 (7획: 상단 삼각, 하단 삼각, 좌측 면, 우측 면, 내부 수평선, 좌측 빛, 우측 빛)
  static void drawDiamond(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final topY = size.height * 0.1;
    final midY = size.height * 0.35;
    final botY = size.height * 0.9;
    final leftX = size.width * 0.1;
    final rightX = size.width * 0.9;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.3, topY)
        ..lineTo(size.width * 0.7, topY)
        ..lineTo(rightX, midY)
        ..lineTo(leftX, midY)
        ..close();
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(leftX, midY)
        ..lineTo(cx, botY)
        ..lineTo(rightX, midY);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.3, topY)
        ..lineTo(cx, midY)
        ..lineTo(leftX, midY);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.7, topY)
        ..lineTo(cx, midY)
        ..lineTo(rightX, midY);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      final path = Path()
        ..moveTo(cx, midY)
        ..lineTo(cx, botY);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 6) {
      final path = Path()
        ..moveTo(leftX, midY)
        ..lineTo(size.width * 0.35, midY + (botY - midY) * 0.4);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 7) {
      final path = Path()
        ..moveTo(rightX, midY)
        ..lineTo(size.width * 0.65, midY + (botY - midY) * 0.4);
      canvas.drawPath(path, paint);
    }
  }
}
