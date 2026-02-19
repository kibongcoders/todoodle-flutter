import 'package:flutter/material.dart';

/// 보통 복잡도 낙서 도형 (5획: 집, 꽃, 배, 풍선)
class MediumShapes {
  MediumShapes._();

  /// 집 (5획: 지붕, 벽, 문, 왼쪽 창, 오른쪽 창)
  static void drawHouse(Canvas canvas, Size size, Paint paint, int strokes) {
    final roofY = size.height * 0.25;
    final wallTop = size.height * 0.45;
    final baseY = size.height * 0.85;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.1, wallTop)
        ..lineTo(size.width * 0.5, roofY)
        ..lineTo(size.width * 0.9, wallTop);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.15, wallTop)
        ..lineTo(size.width * 0.15, baseY)
        ..lineTo(size.width * 0.85, baseY)
        ..lineTo(size.width * 0.85, wallTop);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..addRect(Rect.fromLTWH(
          size.width * 0.4, size.height * 0.55,
          size.width * 0.2, size.height * 0.3,
        ));
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path()
        ..addRect(Rect.fromLTWH(
          size.width * 0.2, size.height * 0.52,
          size.width * 0.12, size.height * 0.12,
        ));
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      final path = Path()
        ..addRect(Rect.fromLTWH(
          size.width * 0.68, size.height * 0.52,
          size.width * 0.12, size.height * 0.12,
        ));
      canvas.drawPath(path, paint);
    }
  }

  /// 꽃 (5획: 줄기, 잎, 꽃잎1, 꽃잎2, 중심)
  static void drawFlower(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final flowerY = size.height * 0.35;
    final r = size.width * 0.15;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx, flowerY + r)
        ..quadraticBezierTo(
          cx - size.width * 0.05, size.height * 0.6,
          cx, size.height * 0.9,
        );
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx, size.height * 0.65)
        ..quadraticBezierTo(
          cx + size.width * 0.2, size.height * 0.55,
          cx + size.width * 0.25, size.height * 0.65,
        )
        ..quadraticBezierTo(
          cx + size.width * 0.15, size.height * 0.7,
          cx, size.height * 0.65,
        );
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path();
      path.moveTo(cx, flowerY - r);
      path.quadraticBezierTo(cx - r * 0.5, flowerY - r * 1.5, cx, flowerY - r * 2);
      path.quadraticBezierTo(cx + r * 0.5, flowerY - r * 1.5, cx, flowerY - r);
      path.moveTo(cx, flowerY + r);
      path.quadraticBezierTo(cx - r * 0.5, flowerY + r * 1.5, cx, flowerY + r * 1.8);
      path.quadraticBezierTo(cx + r * 0.5, flowerY + r * 1.5, cx, flowerY + r);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path();
      path.moveTo(cx - r, flowerY);
      path.quadraticBezierTo(cx - r * 1.5, flowerY - r * 0.5, cx - r * 2, flowerY);
      path.quadraticBezierTo(cx - r * 1.5, flowerY + r * 0.5, cx - r, flowerY);
      path.moveTo(cx + r, flowerY);
      path.quadraticBezierTo(cx + r * 1.5, flowerY - r * 0.5, cx + r * 2, flowerY);
      path.quadraticBezierTo(cx + r * 1.5, flowerY + r * 0.5, cx + r, flowerY);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      canvas.drawCircle(Offset(cx, flowerY), r * 0.6, paint);
    }
  }

  /// 배 (5획: 선체, 돛대, 삼각 돛, 깃발, 물결)
  static void drawBoat(Canvas canvas, Size size, Paint paint, int strokes) {
    final waterY = size.height * 0.7;

    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.1, waterY)
        ..lineTo(size.width * 0.2, size.height * 0.85)
        ..lineTo(size.width * 0.8, size.height * 0.85)
        ..lineTo(size.width * 0.9, waterY)
        ..close();
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.5, waterY)
        ..lineTo(size.width * 0.5, size.height * 0.15);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.5, size.height * 0.2)
        ..lineTo(size.width * 0.8, size.height * 0.55)
        ..lineTo(size.width * 0.5, size.height * 0.55)
        ..close();
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.5, size.height * 0.15)
        ..lineTo(size.width * 0.65, size.height * 0.2)
        ..lineTo(size.width * 0.5, size.height * 0.25);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      final path = Path()
        ..moveTo(size.width * 0.05, size.height * 0.9);
      for (int i = 0; i < 4; i++) {
        path.quadraticBezierTo(
          size.width * (0.15 + i * 0.25), size.height * 0.85,
          size.width * (0.25 + i * 0.25), size.height * 0.9,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  /// 풍선 (5획: 본체, 꼭지, 끈, 매듭, 하이라이트)
  static void drawBalloon(Canvas canvas, Size size, Paint paint, int strokes) {
    final cx = size.width / 2;
    final balloonCy = size.height * 0.35;
    final rx = size.width * 0.3;
    final ry = size.height * 0.28;

    if (strokes >= 1) {
      final path = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(cx, balloonCy),
          width: rx * 2,
          height: ry * 2,
        ));
      canvas.drawPath(path, paint);
    }

    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx - size.width * 0.06, balloonCy + ry)
        ..lineTo(cx, balloonCy + ry + size.height * 0.08)
        ..lineTo(cx + size.width * 0.06, balloonCy + ry);
      canvas.drawPath(path, paint);
    }

    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx, balloonCy + ry + size.height * 0.08);
      path.quadraticBezierTo(
        cx - size.width * 0.1, size.height * 0.75,
        cx + size.width * 0.05, size.height * 0.9,
      );
      canvas.drawPath(path, paint);
    }

    if (strokes >= 4) {
      final knotY = balloonCy + ry + size.height * 0.1;
      final path = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(cx, knotY),
          width: size.width * 0.06,
          height: size.height * 0.04,
        ));
      canvas.drawPath(path, paint);
    }

    if (strokes >= 5) {
      final path = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(cx - rx * 0.4, balloonCy - ry * 0.3),
          width: rx * 0.25,
          height: ry * 0.35,
        ));
      canvas.drawPath(path, paint);
    }
  }
}
