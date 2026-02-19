import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 복잡한 낙서 도형 (8획: 나무, 자전거, 로켓, 고양이)
class ComplexShapes {
  ComplexShapes._();

  /// 나무 (8획)
  static void drawTree(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx - size.width * 0.08, size.height * 0.9)
        ..lineTo(cx - size.width * 0.05, size.height * 0.5)
        ..lineTo(cx + size.width * 0.05, size.height * 0.5)
        ..lineTo(cx + size.width * 0.08, size.height * 0.9);
      canvas.drawPath(path, paint);
    }

    for (int i = 0; i < 5 && strokes >= i + 2; i++) {
      final layerY = size.height * (0.45 - i * 0.08);
      final layerW = size.width * (0.4 - i * 0.05);
      final path = Path()
        ..moveTo(cx - layerW, layerY)
        ..quadraticBezierTo(cx, layerY - size.height * 0.12, cx + layerW, layerY);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 7) {
      final path = Path()
        ..moveTo(cx - size.width * 0.08, size.height * 0.9)
        ..quadraticBezierTo(cx - size.width * 0.15, size.height * 0.95, cx - size.width * 0.2, size.height * 0.9);
      path.moveTo(cx + size.width * 0.08, size.height * 0.9);
      path.quadraticBezierTo(cx + size.width * 0.15, size.height * 0.95, cx + size.width * 0.2, size.height * 0.9);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 8) {
      final path = Path();
      path.addOval(Rect.fromCenter(center: Offset(cx - size.width * 0.15, size.height * 0.25), width: size.width * 0.08, height: size.width * 0.08));
      path.addOval(Rect.fromCenter(center: Offset(cx + size.width * 0.12, size.height * 0.3), width: size.width * 0.06, height: size.width * 0.06));
      canvas.drawPath(path, paint);
    }
  }

  /// 자전거 (8획)
  static void drawBicycle(Canvas canvas, Size size, Paint paint, int strokes) {
    final wheelR = size.width * 0.18;
    final leftWheelCx = size.width * 0.25;
    final rightWheelCx = size.width * 0.75;
    final wheelCy = size.height * 0.7;

    if (strokes >= 1) {
      canvas.drawCircle(Offset(leftWheelCx, wheelCy), wheelR, paint);
    }

    if (strokes >= 2) {
      canvas.drawCircle(Offset(rightWheelCx, wheelCy), wheelR, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(leftWheelCx, wheelCy)
        ..lineTo(size.width * 0.45, size.height * 0.4)
        ..lineTo(rightWheelCx, wheelCy)
        ..lineTo(size.width * 0.5, wheelCy)
        ..lineTo(leftWheelCx, wheelCy);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.45, size.height * 0.4)
        ..lineTo(size.width * 0.55, size.height * 0.25)
        ..lineTo(size.width * 0.65, size.height * 0.3)
        ..moveTo(size.width * 0.55, size.height * 0.25)
        ..lineTo(size.width * 0.45, size.height * 0.3);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      final path = Path()
        ..moveTo(size.width * 0.5, wheelCy)
        ..lineTo(size.width * 0.45, size.height * 0.5)
        ..moveTo(size.width * 0.4, size.height * 0.48)
        ..lineTo(size.width * 0.5, size.height * 0.48);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 6) {
      final path = Path()
        ..moveTo(size.width * 0.5, wheelCy)
        ..lineTo(size.width * 0.55, size.height * 0.75)
        ..moveTo(size.width * 0.5, wheelCy)
        ..lineTo(size.width * 0.45, size.height * 0.65);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 7) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = i * math.pi / 2;
        path.moveTo(leftWheelCx, wheelCy);
        path.lineTo(leftWheelCx + wheelR * 0.8 * math.cos(angle), wheelCy + wheelR * 0.8 * math.sin(angle));
      }
      canvas.drawPath(path, paint);
    }

    if (strokes >= 8) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = i * math.pi / 2;
        path.moveTo(rightWheelCx, wheelCy);
        path.lineTo(rightWheelCx + wheelR * 0.8 * math.cos(angle), wheelCy + wheelR * 0.8 * math.sin(angle));
      }
      canvas.drawPath(path, paint);
    }
  }

  /// 로켓 (8획)
  static void drawRocket(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx - size.width * 0.15, size.height * 0.7)
        ..lineTo(cx - size.width * 0.15, size.height * 0.4)
        ..lineTo(cx + size.width * 0.15, size.height * 0.4)
        ..lineTo(cx + size.width * 0.15, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx - size.width * 0.15, size.height * 0.4)
        ..lineTo(cx, size.height * 0.1)
        ..lineTo(cx + size.width * 0.15, size.height * 0.4);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx - size.width * 0.15, size.height * 0.6)
        ..lineTo(cx - size.width * 0.3, size.height * 0.8)
        ..lineTo(cx - size.width * 0.15, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path()
        ..moveTo(cx + size.width * 0.15, size.height * 0.6)
        ..lineTo(cx + size.width * 0.3, size.height * 0.8)
        ..lineTo(cx + size.width * 0.15, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      canvas.drawCircle(Offset(cx, size.height * 0.45), size.width * 0.08, paint);
    }

    if (strokes >= 6) {
      final path = Path()
        ..moveTo(cx - size.width * 0.08, size.height * 0.7)
        ..quadraticBezierTo(cx - size.width * 0.12, size.height * 0.85, cx - size.width * 0.05, size.height * 0.95);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 7) {
      final path = Path()
        ..moveTo(cx, size.height * 0.7)
        ..quadraticBezierTo(cx - size.width * 0.03, size.height * 0.8, cx, size.height * 0.92);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 8) {
      final path = Path()
        ..moveTo(cx + size.width * 0.08, size.height * 0.7)
        ..quadraticBezierTo(cx + size.width * 0.12, size.height * 0.85, cx + size.width * 0.05, size.height * 0.95);
      canvas.drawPath(path, paint);
    }
  }

  /// 고양이 (8획)
  static void drawCat(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final headCy = size.height * 0.35;
    final headR = size.width * 0.25;

    if (strokes >= 1) {
      canvas.drawCircle(Offset(cx, headCy), headR, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx - headR * 0.7, headCy - headR * 0.5)
        ..lineTo(cx - headR * 0.9, headCy - headR * 1.3)
        ..lineTo(cx - headR * 0.2, headCy - headR * 0.8);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx + headR * 0.7, headCy - headR * 0.5)
        ..lineTo(cx + headR * 0.9, headCy - headR * 1.3)
        ..lineTo(cx + headR * 0.2, headCy - headR * 0.8);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final eyeY = headCy - headR * 0.1;
      canvas.drawCircle(Offset(cx - headR * 0.4, eyeY), headR * 0.12, paint);
      canvas.drawCircle(Offset(cx + headR * 0.4, eyeY), headR * 0.12, paint);
    }

    if (strokes >= 5) {
      final path = Path();
      path.moveTo(cx, headCy + headR * 0.1);
      path.lineTo(cx - headR * 0.1, headCy + headR * 0.25);
      path.lineTo(cx + headR * 0.1, headCy + headR * 0.25);
      path.close();
      path.moveTo(cx, headCy + headR * 0.25);
      path.lineTo(cx, headCy + headR * 0.4);
      path.moveTo(cx, headCy + headR * 0.4);
      path.lineTo(cx - headR * 0.15, headCy + headR * 0.55);
      path.moveTo(cx, headCy + headR * 0.4);
      path.lineTo(cx + headR * 0.15, headCy + headR * 0.55);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 6) {
      final whiskerY = headCy + headR * 0.2;
      final path = Path()
        ..moveTo(cx - headR * 0.3, whiskerY - headR * 0.1)
        ..lineTo(cx - headR * 1.0, whiskerY - headR * 0.2)
        ..moveTo(cx - headR * 0.3, whiskerY)
        ..lineTo(cx - headR * 1.0, whiskerY)
        ..moveTo(cx - headR * 0.3, whiskerY + headR * 0.1)
        ..lineTo(cx - headR * 1.0, whiskerY + headR * 0.2);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 7) {
      final whiskerY = headCy + headR * 0.2;
      final path = Path()
        ..moveTo(cx + headR * 0.3, whiskerY - headR * 0.1)
        ..lineTo(cx + headR * 1.0, whiskerY - headR * 0.2)
        ..moveTo(cx + headR * 0.3, whiskerY)
        ..lineTo(cx + headR * 1.0, whiskerY)
        ..moveTo(cx + headR * 0.3, whiskerY + headR * 0.1)
        ..lineTo(cx + headR * 1.0, whiskerY + headR * 0.2);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 8) {
      final path = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(cx, size.height * 0.75),
          width: size.width * 0.35,
          height: size.height * 0.25,
        ));
      canvas.drawPath(path, paint);
    }
  }
}
