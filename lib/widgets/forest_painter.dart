import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/plant.dart';

class ForestScenePainter extends CustomPainter {
  final List<Plant> plants;

  ForestScenePainter({required this.plants});

  @override
  void paint(Canvas canvas, Size size) {
    // 각 식물 그리기
    for (final plant in plants) {
      final x = size.width * plant.positionX / 100;
      final y = size.height * plant.positionY / 100;

      // 식물 크기 (종류에 따라 다름)
      double plantSize;
      switch (plant.type) {
        case PlantType.grass:
          plantSize = size.width * 0.08;
          break;
        case PlantType.flower:
          plantSize = size.width * 0.1;
          break;
        case PlantType.tree:
          plantSize = size.width * 0.15;
          break;
      }

      _paintPlant(canvas, plant, Offset(x, y), plantSize);
    }
  }

  void _paintPlant(Canvas canvas, Plant plant, Offset position, double size) {
    canvas.save();
    canvas.translate(position.dx - size / 2, position.dy - size);

    switch (plant.type) {
      case PlantType.grass:
        _paintGrass(canvas, Size(size, size), plant.growthStage);
        break;
      case PlantType.flower:
        _paintFlower(canvas, Size(size, size), plant.growthStage);
        break;
      case PlantType.tree:
        _paintTree(canvas, Size(size, size), plant.growthStage);
        break;
    }

    canvas.restore();
  }

  void _paintGrass(Canvas canvas, Size size, int stage) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;

    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 여러 줄기
    for (int i = -1; i <= 1; i++) {
      final offset = i * size.width * 0.15;
      final path = Path();
      path.moveTo(centerX + offset, bottom);
      path.quadraticBezierTo(
        centerX + offset + i * size.width * 0.1,
        bottom - size.height * 0.4,
        centerX + offset + i * size.width * 0.2,
        bottom - size.height * 0.6,
      );
      canvas.drawPath(path, stemPaint);
    }
  }

  void _paintFlower(Canvas canvas, Size size, int stage) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;

    // 줄기
    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(centerX, bottom);
    stemPath.quadraticBezierTo(
      centerX + size.width * 0.05,
      bottom - size.height * 0.3,
      centerX,
      bottom - size.height * 0.5,
    );
    canvas.drawPath(stemPath, stemPaint);

    // 잎
    final leafPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    final leftLeaf = Path();
    leftLeaf.moveTo(centerX, bottom - size.height * 0.25);
    leftLeaf.quadraticBezierTo(
      centerX - size.width * 0.2,
      bottom - size.height * 0.3,
      centerX - size.width * 0.15,
      bottom - size.height * 0.2,
    );
    leftLeaf.quadraticBezierTo(
      centerX - size.width * 0.1,
      bottom - size.height * 0.22,
      centerX,
      bottom - size.height * 0.25,
    );
    canvas.drawPath(leftLeaf, leafPaint);

    // 꽃
    _paintFlowerHead(
      canvas,
      Offset(centerX, bottom - size.height * 0.5),
      size.width * 0.3,
    );
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
      final petalX = center.dx + math.cos(angle) * radius * 0.4;
      final petalY = center.dy + math.sin(angle) * radius * 0.4;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(petalX, petalY),
          width: radius * 0.5,
          height: radius * 0.7,
        ),
        petalPaint,
      );
    }

    // 꽃 중심
    canvas.drawCircle(center, radius * 0.2, centerPaint);
  }

  void _paintTree(Canvas canvas, Size size, int stage) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;

    // 기둥
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;

    final trunkHeight = size.height * 0.5;
    final trunkWidth = size.width * 0.15;

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

    // 수관
    final canopyPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final canopyRadius = size.width * 0.35;
    final canopyY = bottom - trunkHeight - canopyRadius * 0.3;

    // 메인 수관
    canvas.drawCircle(
      Offset(centerX, canopyY),
      canopyRadius,
      canopyPaint,
    );

    // 좌우 수관
    canvas.drawCircle(
      Offset(centerX - canopyRadius * 0.5, canopyY + canopyRadius * 0.2),
      canopyRadius * 0.7,
      canopyPaint,
    );
    canvas.drawCircle(
      Offset(centerX + canopyRadius * 0.5, canopyY + canopyRadius * 0.2),
      canopyRadius * 0.7,
      canopyPaint,
    );

    // 상단 수관
    canopyPaint.color = const Color(0xFF66BB6A);
    canvas.drawCircle(
      Offset(centerX, canopyY - canopyRadius * 0.4),
      canopyRadius * 0.5,
      canopyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ForestScenePainter oldDelegate) {
    return oldDelegate.plants != plants;
  }
}
