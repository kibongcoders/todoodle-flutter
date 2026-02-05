import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/plant.dart';

class PlantWidget extends StatelessWidget {
  const PlantWidget({
    super.key,
    required this.plant,
    this.size = 60,
    this.showGlow = false,
  });

  final Plant plant;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        painter: PlantPainter(
          type: plant.type,
          stage: plant.growthStage,
        ),
      ),
    );
  }
}

class PlantPainter extends CustomPainter {
  PlantPainter({
    required this.type,
    required this.stage,
  });

  final PlantType type;
  final int stage;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case PlantType.grass:
        _paintGrass(canvas, size);
        break;
      case PlantType.flower:
        _paintFlower(canvas, size);
        break;
      case PlantType.tree:
        _paintTree(canvas, size);
        break;
    }
  }

  void _paintGrass(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;

    // 씨앗 (stage 0)
    if (stage == 0) {
      _paintSeed(canvas, size);
      return;
    }

    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 새싹 (stage 1)
    if (stage >= 1) {
      // 중앙 줄기
      final path = Path();
      path.moveTo(centerX, bottom);
      path.quadraticBezierTo(
        centerX,
        bottom - size.height * 0.2,
        centerX,
        bottom - size.height * 0.25,
      );
      canvas.drawPath(path, stemPaint);
    }

    // 풀 (stage 2)
    if (stage >= 2) {
      // 왼쪽 줄기
      final leftPath = Path();
      leftPath.moveTo(centerX - 3, bottom);
      leftPath.quadraticBezierTo(
        centerX - size.width * 0.15,
        bottom - size.height * 0.2,
        centerX - size.width * 0.12,
        bottom - size.height * 0.35,
      );
      canvas.drawPath(leftPath, stemPaint);

      // 오른쪽 줄기
      final rightPath = Path();
      rightPath.moveTo(centerX + 3, bottom);
      rightPath.quadraticBezierTo(
        centerX + size.width * 0.15,
        bottom - size.height * 0.2,
        centerX + size.width * 0.12,
        bottom - size.height * 0.35,
      );
      canvas.drawPath(rightPath, stemPaint);
    }

    // 무성한 풀 (stage 3)
    if (stage >= 3) {
      stemPaint.color = const Color(0xFF388E3C);

      // 추가 줄기들
      for (int i = 0; i < 3; i++) {
        final offset = (i - 1) * size.width * 0.08;
        final path = Path();
        path.moveTo(centerX + offset, bottom);
        path.quadraticBezierTo(
          centerX + offset + (i - 1) * size.width * 0.1,
          bottom - size.height * 0.3,
          centerX + offset + (i - 1) * size.width * 0.15,
          bottom - size.height * 0.45,
        );
        canvas.drawPath(path, stemPaint);
      }
    }
  }

  void _paintFlower(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;

    // 씨앗 (stage 0)
    if (stage == 0) {
      _paintSeed(canvas, size);
      return;
    }

    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 줄기 높이 계산
    double stemHeight = 0;
    if (stage == 1) stemHeight = 0.2;
    if (stage == 2) stemHeight = 0.35;
    if (stage >= 3) stemHeight = 0.5;

    // 줄기 그리기
    if (stage >= 1) {
      final stemPath = Path();
      stemPath.moveTo(centerX, bottom);
      stemPath.quadraticBezierTo(
        centerX + size.width * 0.02,
        bottom - size.height * stemHeight * 0.5,
        centerX,
        bottom - size.height * stemHeight,
      );
      canvas.drawPath(stemPath, stemPaint);
    }

    // 잎 (stage 2+)
    if (stage >= 2) {
      final leafPaint = Paint()
        ..color = const Color(0xFF66BB6A)
        ..style = PaintingStyle.fill;

      // 왼쪽 잎
      final leftLeaf = Path();
      leftLeaf.moveTo(centerX, bottom - size.height * 0.15);
      leftLeaf.quadraticBezierTo(
        centerX - size.width * 0.2,
        bottom - size.height * 0.2,
        centerX - size.width * 0.15,
        bottom - size.height * 0.1,
      );
      leftLeaf.quadraticBezierTo(
        centerX - size.width * 0.1,
        bottom - size.height * 0.12,
        centerX,
        bottom - size.height * 0.15,
      );
      canvas.drawPath(leftLeaf, leafPaint);

      // 오른쪽 잎
      final rightLeaf = Path();
      rightLeaf.moveTo(centerX, bottom - size.height * 0.2);
      rightLeaf.quadraticBezierTo(
        centerX + size.width * 0.2,
        bottom - size.height * 0.25,
        centerX + size.width * 0.15,
        bottom - size.height * 0.15,
      );
      rightLeaf.quadraticBezierTo(
        centerX + size.width * 0.1,
        bottom - size.height * 0.17,
        centerX,
        bottom - size.height * 0.2,
      );
      canvas.drawPath(rightLeaf, leafPaint);
    }

    // 봉오리 (stage 3)
    if (stage == 3) {
      final budPaint = Paint()
        ..color = const Color(0xFFE91E63)
        ..style = PaintingStyle.fill;

      final budY = bottom - size.height * stemHeight;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, budY - size.width * 0.06),
          width: size.width * 0.12,
          height: size.width * 0.15,
        ),
        budPaint,
      );
    }

    // 만개한 꽃 (stage 4)
    if (stage >= 4) {
      final flowerY = bottom - size.height * stemHeight;
      _paintFlowerHead(canvas, Offset(centerX, flowerY), size.width * 0.35);
    }
  }

  void _paintFlowerHead(Canvas canvas, Offset center, double radius) {
    final petalPaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    final centerPaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.fill;

    // 꽃잎 5개
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final petalX = center.dx + math.cos(angle) * radius * 0.5;
      final petalY = center.dy + math.sin(angle) * radius * 0.5;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(petalX, petalY),
          width: radius * 0.6,
          height: radius * 0.8,
        ),
        petalPaint,
      );
    }

    // 꽃 중심
    canvas.drawCircle(center, radius * 0.25, centerPaint);
  }

  void _paintTree(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.9;

    // 씨앗 (stage 0)
    if (stage == 0) {
      _paintSeed(canvas, size);
      return;
    }

    // 새싹 (stage 1)
    if (stage == 1) {
      final stemPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(centerX, bottom);
      path.lineTo(centerX, bottom - size.height * 0.15);
      canvas.drawPath(path, stemPaint);

      // 작은 잎 2개
      final leafPaint = Paint()
        ..color = const Color(0xFF66BB6A)
        ..style = PaintingStyle.fill;

      final leafY = bottom - size.height * 0.15;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX - size.width * 0.06, leafY),
          width: size.width * 0.1,
          height: size.width * 0.06,
        ),
        leafPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX + size.width * 0.06, leafY),
          width: size.width * 0.1,
          height: size.width * 0.06,
        ),
        leafPaint,
      );
      return;
    }

    // 기둥
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;

    double trunkHeight = 0;
    double trunkWidth = 0;
    double canopyRadius = 0;

    switch (stage) {
      case 2: // 묘목
        trunkHeight = size.height * 0.25;
        trunkWidth = size.width * 0.08;
        canopyRadius = size.width * 0.15;
        break;
      case 3: // 어린 나무
        trunkHeight = size.height * 0.35;
        trunkWidth = size.width * 0.1;
        canopyRadius = size.width * 0.22;
        break;
      case 4: // 나무
        trunkHeight = size.height * 0.45;
        trunkWidth = size.width * 0.12;
        canopyRadius = size.width * 0.28;
        break;
      case 5: // 거목
        trunkHeight = size.height * 0.5;
        trunkWidth = size.width * 0.15;
        canopyRadius = size.width * 0.35;
        break;
    }

    // 기둥 그리기
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - trunkWidth / 2,
        bottom - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      Radius.circular(trunkWidth * 0.3),
    );
    canvas.drawRRect(trunkRect, trunkPaint);

    // 수관 (나뭇잎) 그리기
    final canopyPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final canopyY = bottom - trunkHeight - canopyRadius * 0.3;

    // 여러 원으로 수관 표현
    if (stage >= 2) {
      // 메인 수관
      canvas.drawCircle(
        Offset(centerX, canopyY),
        canopyRadius,
        canopyPaint,
      );

      if (stage >= 3) {
        // 좌우 추가 수관
        canvas.drawCircle(
          Offset(centerX - canopyRadius * 0.6, canopyY + canopyRadius * 0.2),
          canopyRadius * 0.7,
          canopyPaint,
        );
        canvas.drawCircle(
          Offset(centerX + canopyRadius * 0.6, canopyY + canopyRadius * 0.2),
          canopyRadius * 0.7,
          canopyPaint,
        );
      }

      if (stage >= 4) {
        // 상단 추가 수관
        canvas.drawCircle(
          Offset(centerX, canopyY - canopyRadius * 0.5),
          canopyRadius * 0.6,
          canopyPaint,
        );
      }

      if (stage >= 5) {
        // 더 풍성한 수관
        canopyPaint.color = const Color(0xFF388E3C);
        canvas.drawCircle(
          Offset(centerX - canopyRadius * 0.4, canopyY - canopyRadius * 0.3),
          canopyRadius * 0.5,
          canopyPaint,
        );
        canvas.drawCircle(
          Offset(centerX + canopyRadius * 0.4, canopyY - canopyRadius * 0.3),
          canopyRadius * 0.5,
          canopyPaint,
        );
      }
    }
  }

  void _paintSeed(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;

    // 땅
    final groundPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom),
        width: size.width * 0.3,
        height: size.width * 0.1,
      ),
      groundPaint,
    );

    // 씨앗
    final seedPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.width * 0.05),
        width: size.width * 0.12,
        height: size.width * 0.08,
      ),
      seedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PlantPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.stage != stage;
  }
}
