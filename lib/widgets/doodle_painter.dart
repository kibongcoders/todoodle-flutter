import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/doodle_colors.dart';
import '../models/doodle.dart';

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
  final Color? fillColor; // 크레파스 채우기 색상

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
    switch (type) {
      case DoodleType.star:
        _drawStar(canvas, size, paint);
      case DoodleType.heart:
        _drawHeart(canvas, size, paint);
      case DoodleType.cloud:
        _drawCloud(canvas, size, paint);
      case DoodleType.moon:
        _drawMoon(canvas, size, paint);
      case DoodleType.house:
        _drawHouse(canvas, size, paint);
      case DoodleType.flower:
        _drawFlower(canvas, size, paint);
      case DoodleType.boat:
        _drawBoat(canvas, size, paint);
      case DoodleType.balloon:
        _drawBalloon(canvas, size, paint);
      case DoodleType.tree:
        _drawTree(canvas, size, paint);
      case DoodleType.bicycle:
        _drawBicycle(canvas, size, paint);
      case DoodleType.rocket:
        _drawRocket(canvas, size, paint);
      case DoodleType.cat:
        _drawCat(canvas, size, paint);
      case DoodleType.rainbowStar:
        _drawRainbowStar(canvas, size, paint);
      case DoodleType.crown:
        _drawCrown(canvas, size, paint);
      case DoodleType.diamond:
        _drawDiamond(canvas, size, paint);
    }
  }

  /// 진행률에 따른 획 수 계산
  int _getStrokesToDraw(int maxStrokes) {
    return (progress * maxStrokes).ceil();
  }

  // ==================== Simple (3획) ====================

  /// 별 (3획: 위쪽 삼각형, 왼쪽 아래 선, 오른쪽 아래 선)
  void _drawStar(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(3);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    // 5각 별의 좌표 계산
    final points = <Offset>[];
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      points.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    // 획 1: 상단에서 좌하단으로
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[2].dx, points[2].dy);
      canvas.drawPath(path, paint);
    }

    // 획 2: 좌하단에서 우상단, 그리고 좌상단으로
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(points[2].dx, points[2].dy)
        ..lineTo(points[4].dx, points[4].dy)
        ..lineTo(points[1].dx, points[1].dy);
      canvas.drawPath(path, paint);
    }

    // 획 3: 우하단으로, 시작점으로 연결
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(points[1].dx, points[1].dy)
        ..lineTo(points[3].dx, points[3].dy)
        ..lineTo(points[0].dx, points[0].dy);
      canvas.drawPath(path, paint);
    }
  }

  /// 하트 (3획: 왼쪽 곡선, 오른쪽 곡선, 아래 뾰족)
  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(3);
    final cx = size.width / 2;
    final top = size.height * 0.25;
    final bottom = size.height * 0.85;
    final w = size.width * 0.45;

    // 획 1: 왼쪽 볼록 곡선
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

    // 획 2: 오른쪽 볼록 곡선
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

    // 획 3: 아래로 모이는 선
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx - w * 0.8, size.height * 0.5)
        ..lineTo(cx, bottom)
        ..lineTo(cx + w * 0.8, size.height * 0.5);
      canvas.drawPath(path, paint);
    }
  }

  /// 구름 (3획: 세 개의 봉우리)
  void _drawCloud(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(3);
    final cy = size.height * 0.55;
    final h = size.height * 0.25;

    // 획 1: 왼쪽 봉우리
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.15, cy)
        ..quadraticBezierTo(
          size.width * 0.25, cy - h,
          size.width * 0.4, cy,
        );
      canvas.drawPath(path, paint);
    }

    // 획 2: 중앙 봉우리
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.35, cy)
        ..quadraticBezierTo(
          size.width * 0.5, cy - h * 1.3,
          size.width * 0.65, cy,
        );
      canvas.drawPath(path, paint);
    }

    // 획 3: 오른쪽 봉우리 + 바닥
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.6, cy)
        ..quadraticBezierTo(
          size.width * 0.75, cy - h,
          size.width * 0.85, cy,
        )
        ..lineTo(size.width * 0.85, cy + h * 0.3)
        ..lineTo(size.width * 0.15, cy + h * 0.3)
        ..lineTo(size.width * 0.15, cy);
      canvas.drawPath(path, paint);
    }
  }

  /// 달 (3획: 바깥 곡선, 안쪽 곡선, 별 점)
  void _drawMoon(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(3);
    final cx = size.width * 0.45;
    final cy = size.height / 2;
    final r = size.width * 0.35;

    // 획 1: 바깥 곡선 (왼쪽)
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

    // 획 2: 안쪽 곡선 (오른쪽으로 파인 부분)
    if (strokes >= 2) {
      final innerR = r * 0.7;
      final path = Path()
        ..moveTo(cx, cy - r)
        ..quadraticBezierTo(
          cx + innerR, cy,
          cx, cy + r,
        );
      canvas.drawPath(path, paint);
    }

    // 획 3: 작은 별
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

  // ==================== Medium (5획) ====================

  /// 집 (5획: 지붕, 벽, 문, 왼쪽 창, 오른쪽 창)
  void _drawHouse(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(5);
    final baseY = size.height * 0.85;
    final roofY = size.height * 0.25;
    final wallTop = size.height * 0.45;

    // 획 1: 지붕
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.1, wallTop)
        ..lineTo(size.width * 0.5, roofY)
        ..lineTo(size.width * 0.9, wallTop);
      canvas.drawPath(path, paint);
    }

    // 획 2: 벽
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.15, wallTop)
        ..lineTo(size.width * 0.15, baseY)
        ..lineTo(size.width * 0.85, baseY)
        ..lineTo(size.width * 0.85, wallTop);
      canvas.drawPath(path, paint);
    }

    // 획 3: 문
    if (strokes >= 3) {
      final path = Path()
        ..addRect(Rect.fromLTWH(
          size.width * 0.4,
          size.height * 0.55,
          size.width * 0.2,
          size.height * 0.3,
        ));
      canvas.drawPath(path, paint);
    }

    // 획 4: 왼쪽 창문
    if (strokes >= 4) {
      final path = Path()
        ..addRect(Rect.fromLTWH(
          size.width * 0.2,
          size.height * 0.52,
          size.width * 0.12,
          size.height * 0.12,
        ));
      canvas.drawPath(path, paint);
    }

    // 획 5: 오른쪽 창문
    if (strokes >= 5) {
      final path = Path()
        ..addRect(Rect.fromLTWH(
          size.width * 0.68,
          size.height * 0.52,
          size.width * 0.12,
          size.height * 0.12,
        ));
      canvas.drawPath(path, paint);
    }
  }

  /// 꽃 (5획: 줄기, 잎, 꽃잎1, 꽃잎2, 중심)
  void _drawFlower(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(5);
    final cx = size.width / 2;
    final flowerY = size.height * 0.35;
    final r = size.width * 0.15;

    // 획 1: 줄기
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx, flowerY + r)
        ..quadraticBezierTo(
          cx - size.width * 0.05, size.height * 0.6,
          cx, size.height * 0.9,
        );
      canvas.drawPath(path, paint);
    }

    // 획 2: 잎
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

    // 획 3: 꽃잎 (위, 아래)
    if (strokes >= 3) {
      final path = Path();
      // 위 꽃잎
      path.moveTo(cx, flowerY - r);
      path.quadraticBezierTo(cx - r * 0.5, flowerY - r * 1.5, cx, flowerY - r * 2);
      path.quadraticBezierTo(cx + r * 0.5, flowerY - r * 1.5, cx, flowerY - r);
      // 아래 꽃잎
      path.moveTo(cx, flowerY + r);
      path.quadraticBezierTo(cx - r * 0.5, flowerY + r * 1.5, cx, flowerY + r * 1.8);
      path.quadraticBezierTo(cx + r * 0.5, flowerY + r * 1.5, cx, flowerY + r);
      canvas.drawPath(path, paint);
    }

    // 획 4: 꽃잎 (좌, 우)
    if (strokes >= 4) {
      final path = Path();
      // 왼쪽 꽃잎
      path.moveTo(cx - r, flowerY);
      path.quadraticBezierTo(cx - r * 1.5, flowerY - r * 0.5, cx - r * 2, flowerY);
      path.quadraticBezierTo(cx - r * 1.5, flowerY + r * 0.5, cx - r, flowerY);
      // 오른쪽 꽃잎
      path.moveTo(cx + r, flowerY);
      path.quadraticBezierTo(cx + r * 1.5, flowerY - r * 0.5, cx + r * 2, flowerY);
      path.quadraticBezierTo(cx + r * 1.5, flowerY + r * 0.5, cx + r, flowerY);
      canvas.drawPath(path, paint);
    }

    // 획 5: 중심 원
    if (strokes >= 5) {
      canvas.drawCircle(Offset(cx, flowerY), r * 0.6, paint);
    }
  }

  /// 배 (5획: 선체, 돛대, 삼각 돛, 깃발, 물결)
  void _drawBoat(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(5);
    final waterY = size.height * 0.7;

    // 획 1: 선체
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.1, waterY)
        ..lineTo(size.width * 0.2, size.height * 0.85)
        ..lineTo(size.width * 0.8, size.height * 0.85)
        ..lineTo(size.width * 0.9, waterY)
        ..close();
      canvas.drawPath(path, paint);
    }

    // 획 2: 돛대
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.5, waterY)
        ..lineTo(size.width * 0.5, size.height * 0.15);
      canvas.drawPath(path, paint);
    }

    // 획 3: 삼각 돛
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.5, size.height * 0.2)
        ..lineTo(size.width * 0.8, size.height * 0.55)
        ..lineTo(size.width * 0.5, size.height * 0.55)
        ..close();
      canvas.drawPath(path, paint);
    }

    // 획 4: 깃발
    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.5, size.height * 0.15)
        ..lineTo(size.width * 0.65, size.height * 0.2)
        ..lineTo(size.width * 0.5, size.height * 0.25);
      canvas.drawPath(path, paint);
    }

    // 획 5: 물결
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
  void _drawBalloon(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(5);
    final cx = size.width / 2;
    final balloonCy = size.height * 0.35;
    final rx = size.width * 0.3;
    final ry = size.height * 0.28;

    // 획 1: 풍선 본체 (타원)
    if (strokes >= 1) {
      final path = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(cx, balloonCy),
          width: rx * 2,
          height: ry * 2,
        ));
      canvas.drawPath(path, paint);
    }

    // 획 2: 꼭지 (작은 삼각형)
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx - size.width * 0.06, balloonCy + ry)
        ..lineTo(cx, balloonCy + ry + size.height * 0.08)
        ..lineTo(cx + size.width * 0.06, balloonCy + ry);
      canvas.drawPath(path, paint);
    }

    // 획 3: 끈
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx, balloonCy + ry + size.height * 0.08);
      path.quadraticBezierTo(
        cx - size.width * 0.1, size.height * 0.75,
        cx + size.width * 0.05, size.height * 0.9,
      );
      canvas.drawPath(path, paint);
    }

    // 획 4: 매듭
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

    // 획 5: 하이라이트
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

  // ==================== Complex (8획) ====================

  /// 나무 (8획)
  void _drawTree(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(8);
    final cx = size.width / 2;

    // 획 1: 줄기
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx - size.width * 0.08, size.height * 0.9)
        ..lineTo(cx - size.width * 0.05, size.height * 0.5)
        ..lineTo(cx + size.width * 0.05, size.height * 0.5)
        ..lineTo(cx + size.width * 0.08, size.height * 0.9);
      canvas.drawPath(path, paint);
    }

    // 획 2-6: 잎 (5개 층)
    for (int i = 0; i < 5 && strokes >= i + 2; i++) {
      final layerY = size.height * (0.45 - i * 0.08);
      final layerW = size.width * (0.4 - i * 0.05);
      final path = Path()
        ..moveTo(cx - layerW, layerY)
        ..quadraticBezierTo(cx, layerY - size.height * 0.12, cx + layerW, layerY);
      canvas.drawPath(path, paint);
    }

    // 획 7: 뿌리
    if (strokes >= 7) {
      final path = Path()
        ..moveTo(cx - size.width * 0.08, size.height * 0.9)
        ..quadraticBezierTo(cx - size.width * 0.15, size.height * 0.95, cx - size.width * 0.2, size.height * 0.9);
      path.moveTo(cx + size.width * 0.08, size.height * 0.9);
      path.quadraticBezierTo(cx + size.width * 0.15, size.height * 0.95, cx + size.width * 0.2, size.height * 0.9);
      canvas.drawPath(path, paint);
    }

    // 획 8: 나뭇잎 디테일
    if (strokes >= 8) {
      final path = Path();
      path.addOval(Rect.fromCenter(center: Offset(cx - size.width * 0.15, size.height * 0.25), width: size.width * 0.08, height: size.width * 0.08));
      path.addOval(Rect.fromCenter(center: Offset(cx + size.width * 0.12, size.height * 0.3), width: size.width * 0.06, height: size.width * 0.06));
      canvas.drawPath(path, paint);
    }
  }

  /// 자전거 (8획)
  void _drawBicycle(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(8);
    final wheelR = size.width * 0.18;
    final leftWheelCx = size.width * 0.25;
    final rightWheelCx = size.width * 0.75;
    final wheelCy = size.height * 0.7;

    // 획 1: 왼쪽 바퀴
    if (strokes >= 1) {
      canvas.drawCircle(Offset(leftWheelCx, wheelCy), wheelR, paint);
    }

    // 획 2: 오른쪽 바퀴
    if (strokes >= 2) {
      canvas.drawCircle(Offset(rightWheelCx, wheelCy), wheelR, paint);
    }

    // 획 3: 프레임 (삼각형)
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(leftWheelCx, wheelCy)
        ..lineTo(size.width * 0.45, size.height * 0.4)
        ..lineTo(rightWheelCx, wheelCy)
        ..lineTo(size.width * 0.5, wheelCy)
        ..lineTo(leftWheelCx, wheelCy);
      canvas.drawPath(path, paint);
    }

    // 획 4: 핸들바
    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.45, size.height * 0.4)
        ..lineTo(size.width * 0.55, size.height * 0.25)
        ..lineTo(size.width * 0.65, size.height * 0.3)
        ..moveTo(size.width * 0.55, size.height * 0.25)
        ..lineTo(size.width * 0.45, size.height * 0.3);
      canvas.drawPath(path, paint);
    }

    // 획 5: 안장
    if (strokes >= 5) {
      final path = Path()
        ..moveTo(size.width * 0.5, wheelCy)
        ..lineTo(size.width * 0.45, size.height * 0.5)
        ..moveTo(size.width * 0.4, size.height * 0.48)
        ..lineTo(size.width * 0.5, size.height * 0.48);
      canvas.drawPath(path, paint);
    }

    // 획 6: 페달
    if (strokes >= 6) {
      final path = Path()
        ..moveTo(size.width * 0.5, wheelCy)
        ..lineTo(size.width * 0.55, size.height * 0.75)
        ..moveTo(size.width * 0.5, wheelCy)
        ..lineTo(size.width * 0.45, size.height * 0.65);
      canvas.drawPath(path, paint);
    }

    // 획 7: 바퀴살 (왼쪽)
    if (strokes >= 7) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = i * math.pi / 2;
        path.moveTo(leftWheelCx, wheelCy);
        path.lineTo(leftWheelCx + wheelR * 0.8 * math.cos(angle), wheelCy + wheelR * 0.8 * math.sin(angle));
      }
      canvas.drawPath(path, paint);
    }

    // 획 8: 바퀴살 (오른쪽)
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
  void _drawRocket(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(8);
    final cx = size.width / 2;

    // 획 1: 로켓 본체 (아래 부분)
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(cx - size.width * 0.15, size.height * 0.7)
        ..lineTo(cx - size.width * 0.15, size.height * 0.4)
        ..lineTo(cx + size.width * 0.15, size.height * 0.4)
        ..lineTo(cx + size.width * 0.15, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    // 획 2: 로켓 머리 (뾰족)
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx - size.width * 0.15, size.height * 0.4)
        ..lineTo(cx, size.height * 0.1)
        ..lineTo(cx + size.width * 0.15, size.height * 0.4);
      canvas.drawPath(path, paint);
    }

    // 획 3: 왼쪽 날개
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx - size.width * 0.15, size.height * 0.6)
        ..lineTo(cx - size.width * 0.3, size.height * 0.8)
        ..lineTo(cx - size.width * 0.15, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    // 획 4: 오른쪽 날개
    if (strokes >= 4) {
      final path = Path()
        ..moveTo(cx + size.width * 0.15, size.height * 0.6)
        ..lineTo(cx + size.width * 0.3, size.height * 0.8)
        ..lineTo(cx + size.width * 0.15, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    // 획 5: 창문
    if (strokes >= 5) {
      canvas.drawCircle(Offset(cx, size.height * 0.45), size.width * 0.08, paint);
    }

    // 획 6: 화염 (왼쪽)
    if (strokes >= 6) {
      final path = Path()
        ..moveTo(cx - size.width * 0.08, size.height * 0.7)
        ..quadraticBezierTo(cx - size.width * 0.12, size.height * 0.85, cx - size.width * 0.05, size.height * 0.95);
      canvas.drawPath(path, paint);
    }

    // 획 7: 화염 (중앙)
    if (strokes >= 7) {
      final path = Path()
        ..moveTo(cx, size.height * 0.7)
        ..quadraticBezierTo(cx - size.width * 0.03, size.height * 0.8, cx, size.height * 0.92);
      canvas.drawPath(path, paint);
    }

    // 획 8: 화염 (오른쪽)
    if (strokes >= 8) {
      final path = Path()
        ..moveTo(cx + size.width * 0.08, size.height * 0.7)
        ..quadraticBezierTo(cx + size.width * 0.12, size.height * 0.85, cx + size.width * 0.05, size.height * 0.95);
      canvas.drawPath(path, paint);
    }
  }

  /// 고양이 (8획)
  void _drawCat(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(8);
    final cx = size.width / 2;
    final headCy = size.height * 0.35;
    final headR = size.width * 0.25;

    // 획 1: 얼굴 (원)
    if (strokes >= 1) {
      canvas.drawCircle(Offset(cx, headCy), headR, paint);
    }

    // 획 2: 왼쪽 귀
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(cx - headR * 0.7, headCy - headR * 0.5)
        ..lineTo(cx - headR * 0.9, headCy - headR * 1.3)
        ..lineTo(cx - headR * 0.2, headCy - headR * 0.8);
      canvas.drawPath(path, paint);
    }

    // 획 3: 오른쪽 귀
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(cx + headR * 0.7, headCy - headR * 0.5)
        ..lineTo(cx + headR * 0.9, headCy - headR * 1.3)
        ..lineTo(cx + headR * 0.2, headCy - headR * 0.8);
      canvas.drawPath(path, paint);
    }

    // 획 4: 눈 (두 개)
    if (strokes >= 4) {
      final eyeY = headCy - headR * 0.1;
      canvas.drawCircle(Offset(cx - headR * 0.4, eyeY), headR * 0.12, paint);
      canvas.drawCircle(Offset(cx + headR * 0.4, eyeY), headR * 0.12, paint);
    }

    // 획 5: 코와 입
    if (strokes >= 5) {
      final path = Path();
      // 코 (삼각형)
      path.moveTo(cx, headCy + headR * 0.1);
      path.lineTo(cx - headR * 0.1, headCy + headR * 0.25);
      path.lineTo(cx + headR * 0.1, headCy + headR * 0.25);
      path.close();
      // 입 (Y 모양)
      path.moveTo(cx, headCy + headR * 0.25);
      path.lineTo(cx, headCy + headR * 0.4);
      path.moveTo(cx, headCy + headR * 0.4);
      path.lineTo(cx - headR * 0.15, headCy + headR * 0.55);
      path.moveTo(cx, headCy + headR * 0.4);
      path.lineTo(cx + headR * 0.15, headCy + headR * 0.55);
      canvas.drawPath(path, paint);
    }

    // 획 6: 수염 (왼쪽)
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

    // 획 7: 수염 (오른쪽)
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

    // 획 8: 몸통 (간단한 타원)
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

  // ==================== Rare (희귀 낙서) ====================

  /// 무지개 별 (5획: 별 외곽 5개 꼭짓점을 각각의 색으로)
  void _drawRainbowStar(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(5);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.42;
    final innerR = size.width * 0.18;

    // 무지개 색상 (stroke 모드에서만 적용)
    final rainbowColors = [
      const Color(0xFFE57373), // 빨강
      const Color(0xFFFFB74D), // 주황
      const Color(0xFFFFF176), // 노랑
      const Color(0xFF81C784), // 초록
      const Color(0xFF64B5F6), // 파랑
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
  void _drawCrown(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(6);
    final cx = size.width / 2;

    // 획 1: 왕관 밑단
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.15, size.height * 0.7)
        ..lineTo(size.width * 0.85, size.height * 0.7)
        ..lineTo(size.width * 0.85, size.height * 0.8)
        ..lineTo(size.width * 0.15, size.height * 0.8)
        ..close();
      canvas.drawPath(path, paint);
    }

    // 획 2: 왼쪽 삼각 꼭짓점
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(size.width * 0.15, size.height * 0.7)
        ..lineTo(size.width * 0.25, size.height * 0.25)
        ..lineTo(size.width * 0.35, size.height * 0.5);
      canvas.drawPath(path, paint);
    }

    // 획 3: 중앙 삼각 꼭짓점
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.35, size.height * 0.5)
        ..lineTo(cx, size.height * 0.15)
        ..lineTo(size.width * 0.65, size.height * 0.5);
      canvas.drawPath(path, paint);
    }

    // 획 4: 오른쪽 삼각 꼭짓점
    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.65, size.height * 0.5)
        ..lineTo(size.width * 0.75, size.height * 0.25)
        ..lineTo(size.width * 0.85, size.height * 0.7);
      canvas.drawPath(path, paint);
    }

    // 획 5: 보석 3개 (꼭짓점 끝)
    if (strokes >= 5) {
      final gemR = size.width * 0.04;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.22), gemR, paint);
      canvas.drawCircle(Offset(cx, size.height * 0.12), gemR, paint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.22), gemR, paint);
    }

    // 획 6: 밑단 장식선
    if (strokes >= 6) {
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.75)
        ..lineTo(size.width * 0.8, size.height * 0.75);
      canvas.drawPath(path, paint);
      // 밑단 보석
      canvas.drawCircle(Offset(cx, size.height * 0.75), size.width * 0.03, paint);
    }
  }

  /// 다이아몬드 (7획: 상단 삼각, 하단 삼각, 좌측 면, 우측 면, 내부 수평선, 좌측 빛, 우측 빛)
  void _drawDiamond(Canvas canvas, Size size, Paint paint) {
    final strokes = _getStrokesToDraw(7);
    final cx = size.width / 2;
    final topY = size.height * 0.1;
    final midY = size.height * 0.35;
    final botY = size.height * 0.9;
    final leftX = size.width * 0.1;
    final rightX = size.width * 0.9;

    // 획 1: 상단 사다리꼴 (위)
    if (strokes >= 1) {
      final path = Path()
        ..moveTo(size.width * 0.3, topY)
        ..lineTo(size.width * 0.7, topY)
        ..lineTo(rightX, midY)
        ..lineTo(leftX, midY)
        ..close();
      canvas.drawPath(path, paint);
    }

    // 획 2: 하단 삼각형 (아래)
    if (strokes >= 2) {
      final path = Path()
        ..moveTo(leftX, midY)
        ..lineTo(cx, botY)
        ..lineTo(rightX, midY);
      canvas.drawPath(path, paint);
    }

    // 획 3: 왼쪽 내부 면
    if (strokes >= 3) {
      final path = Path()
        ..moveTo(size.width * 0.3, topY)
        ..lineTo(cx, midY)
        ..lineTo(leftX, midY);
      canvas.drawPath(path, paint);
    }

    // 획 4: 오른쪽 내부 면
    if (strokes >= 4) {
      final path = Path()
        ..moveTo(size.width * 0.7, topY)
        ..lineTo(cx, midY)
        ..lineTo(rightX, midY);
      canvas.drawPath(path, paint);
    }

    // 획 5: 중앙 수직선
    if (strokes >= 5) {
      final path = Path()
        ..moveTo(cx, midY)
        ..lineTo(cx, botY);
      canvas.drawPath(path, paint);
    }

    // 획 6: 좌측 빛 반사
    if (strokes >= 6) {
      final path = Path()
        ..moveTo(leftX, midY)
        ..lineTo(size.width * 0.35, midY + (botY - midY) * 0.4);
      canvas.drawPath(path, paint);
    }

    // 획 7: 우측 빛 반사
    if (strokes >= 7) {
      final path = Path()
        ..moveTo(rightX, midY)
        ..lineTo(size.width * 0.65, midY + (botY - midY) * 0.4);
      canvas.drawPath(path, paint);
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
