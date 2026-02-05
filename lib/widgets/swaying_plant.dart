import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/plant.dart';
import 'plant_widget.dart';

class SwayingPlant extends StatefulWidget {
  const SwayingPlant({
    super.key,
    required this.plant,
    this.size = 60,
    this.showGlow = false,
    this.delayMs = 0,
  });

  final Plant plant;
  final double size;
  final bool showGlow;
  final int delayMs;

  @override
  State<SwayingPlant> createState() => _SwayingPlantState();
}

class _SwayingPlantState extends State<SwayingPlant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 각 식물마다 다른 속도로 흔들리게
    final duration = 2000 + _random.nextInt(1500);

    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 딜레이 후 애니메이션 시작
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.rotationZ(_animation.value),
          child: child,
        );
      },
      child: PlantWidget(
        plant: widget.plant,
        size: widget.size,
        showGlow: widget.showGlow,
      ),
    );
  }
}

class SwayingForestScene extends StatelessWidget {
  const SwayingForestScene({
    super.key,
    required this.plants,
    this.heightRatio = 0.25,
  });

  final List<Plant> plants;
  final double heightRatio;

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: plants.asMap().entries.map((entry) {
              final index = entry.key;
              final plant = entry.value;

              // 반응형 위치 계산 - X는 가로 퍼센트
              final x = width * plant.positionX / 100;

              // 반응형 크기 계산
              double baseSize;
              switch (plant.type) {
                case PlantType.grass:
                  baseSize = width * 0.06;
                  break;
                case PlantType.flower:
                  baseSize = width * 0.08;
                  break;
                case PlantType.tree:
                  baseSize = width * 0.12;
                  break;
              }

              // 최소/최대 크기 제한
              final plantSize = baseSize.clamp(25.0, 80.0);

              // Y 위치: 하단 바닥 기준으로 위로 올라감
              // positionY가 30~70 범위이므로, 이를 0~40% 높이로 변환
              final yOffset = height * (plant.positionY - 30) / 100;

              return Positioned(
                left: x - plantSize / 2,
                bottom: yOffset, // bottom 기준으로 배치 (바닥에서 위로)
                child: SwayingPlant(
                  plant: plant,
                  size: plantSize,
                  delayMs: index * 100,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
