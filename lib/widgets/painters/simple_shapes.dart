import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 간단한 낙서 도형 (3획: 별, 하트, 구름, 달)
class SimpleShapes {
  SimpleShapes._();

  /// 별 (3획: 위쪽 삼각형, 왼쪽 아래 선, 오른쪽 아래 선)
  static void drawStar(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    final points = <Offset>[];
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      points.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[2].dx, points[2].dy);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(points[2].dx, points[2].dy)
        ..lineTo(points[4].dx, points[4].dy)
        ..lineTo(points[1].dx, points[1].dy);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(points[1].dx, points[1].dy)
        ..lineTo(points[3].dx, points[3].dy)
        ..lineTo(points[0].dx, points[0].dy);
      canvas.drawPath(path, paint);
    }
  }

  /// 하트 (3획: 왼쪽 곡선, 오른쪽 곡선, 아래 뾰족)
  static void drawHeart(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final top = size.height * 0.25;
    final bottom = size.height * 0.85;
    final w = size.width * 0.45;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx, top + size.height * 0.1)
        ..cubicTo(
          cx - w * 0.5, top - size.height * 0.1,
          cx - w, top + size.height * 0.15,
          cx - w * 0.8, size.height * 0.5,
        );
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx, top + size.height * 0.1)
        ..cubicTo(
          cx + w * 0.5, top - size.height * 0.1,
          cx + w, top + size.height * 0.15,
          cx + w * 0.8, size.height * 0.5,
        );
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx - w * 0.8, size.height * 0.5)
        ..lineTo(cx, bottom)
        ..lineTo(cx + w * 0.8, size.height * 0.5);
      canvas.drawPath(path, paint);
    }
  }

  /// 구름 (3획: 세 개의 봉우리)
  static void drawCloud(Canvas canvas, Size size, Paint paint, int strokes) {
    final cy = size.height * 0.55;
    final h = size.height * 0.25;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.15, cy)
        ..quadraticBezierTo(size.width * 0.25, cy - h, size.width * 0.4, cy);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.35, cy)
        ..quadraticBezierTo(size.width * 0.5, cy - h * 1.3, size.width * 0.65, cy);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.6, cy)
        ..quadraticBezierTo(size.width * 0.75, cy - h, size.width * 0.85, cy)
        ..lineTo(size.width * 0.85, cy + h * 0.3)
        ..lineTo(size.width * 0.15, cy + h * 0.3)
        ..lineTo(size.width * 0.15, cy);
      canvas.drawPath(path, paint);
    }
  }

  /// 달 (3획: 바깥 곡선, 안쪽 곡선, 별 점)
  static void drawMoon(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width * 0.45;
    final cy = size.height / 2;
    final r = size.width * 0.35;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx, cy - r)
        ..arcToPoint(
          Offset(cx, cy + r),
          radius: Radius.circular(r),
          clockwise: false,
        );
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final innerR = r * 0.7;
      final path = Path()
        ..moveTo(cx, cy - r)
        ..quadraticBezierTo(cx + innerR, cy, cx, cy + r);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final starCx = size.width * 0.8;
      final starCy = size.height * 0.3;
      final sr = size.width * 0.08;
      final path = Path()
        ..moveTo(starCx, starCy - sr)
        ..lineTo(starCx + sr * 0.3, starCy - sr * 0.3)
        ..lineTo(starCx + sr, starCy)
        ..lineTo(starCx + sr * 0.3, starCy + sr * 0.3)
        ..lineTo(starCx, starCy + sr)
        ..lineTo(starCx - sr * 0.3, starCy + sr * 0.3)
        ..lineTo(starCx - sr, starCy)
        ..lineTo(starCx - sr * 0.3, starCy - sr * 0.3)
        ..close();
      canvas.drawPath(path, paint);
    }
  }
}
