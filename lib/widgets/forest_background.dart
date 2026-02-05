import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/forest_provider.dart';
import 'swaying_plant.dart';

class ForestBackground extends StatelessWidget {
  const ForestBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, forestProvider, _) {
        if (!forestProvider.initialized) {
          return child;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            // 반응형 높이 비율 (화면 크기에 따라 조절)
            final forestHeightRatio = screenWidth > 600 ? 0.2 : 0.25;

            return Stack(
              children: [
                // 배경 그라데이션 (하늘 -> 땅)
                _buildBackground(),

                // 뒷쪽 숲 (다 자란 식물들, 살랑살랑 애니메이션)
                if (forestProvider.forestPlants.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: screenHeight * forestHeightRatio,
                    child: Opacity(
                      opacity: 0.5,
                      child: SwayingForestScene(
                        plants: forestProvider.forestPlants,
                        heightRatio: 1.0,
                      ),
                    ),
                  ),

                // 메인 콘텐츠
                child,
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBackground() {
    final colors = _getTimeBasedColors();
    final hour = DateTime.now().hour;

    return Stack(
      children: [
        // 기본 그라데이션 배경
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // 시간대별 시각적 요소
        ..._buildTimeBasedElements(hour),
      ],
    );
  }

  List<Widget> _buildTimeBasedElements(int hour) {
    // 새벽 (4~6시) - 떠오르는 태양
    if (hour >= 4 && hour < 6) {
      return [
        _buildSun(
          alignment: const Alignment(0.8, 0.6),
          size: 60,
          color: const Color(0xFFFFE082),
          glowColor: const Color(0xFFFFCC80),
          glowSize: 100,
        ),
      ];
    }
    // 아침 (6~9시) - 떠오른 태양
    if (hour >= 6 && hour < 9) {
      return [
        _buildSun(
          alignment: const Alignment(0.7, 0.3),
          size: 50,
          color: const Color(0xFFFFD54F),
          glowColor: const Color(0xFFFFE082),
          glowSize: 80,
        ),
        _buildCloud(const Alignment(-0.6, -0.5), 0.4),
      ];
    }
    // 오전~점심 (9~14시) - 높은 태양 + 구름
    if (hour >= 9 && hour < 14) {
      return [
        _buildSun(
          alignment: const Alignment(0.0, -0.7),
          size: 45,
          color: const Color(0xFFFFEB3B),
          glowColor: const Color(0xFFFFF59D),
          glowSize: 70,
        ),
        _buildCloud(const Alignment(-0.7, -0.4), 0.5),
        _buildCloud(const Alignment(0.5, -0.3), 0.3),
      ];
    }
    // 오후 (14~17시) - 서쪽으로 기우는 태양
    if (hour >= 14 && hour < 17) {
      return [
        _buildSun(
          alignment: const Alignment(-0.6, -0.3),
          size: 50,
          color: const Color(0xFFFFE082),
          glowColor: const Color(0xFFFFCC80),
          glowSize: 80,
        ),
        _buildCloud(const Alignment(0.4, -0.5), 0.4),
      ];
    }
    // 저녁/노을 (17~20시) - 노을 태양 + 노을 광선
    if (hour >= 17 && hour < 20) {
      return [
        // 노을 광선 효과
        _buildSunsetRays(),
        // 지는 태양
        _buildSun(
          alignment: const Alignment(-0.8, 0.5),
          size: 70,
          color: const Color(0xFFFF7043),
          glowColor: const Color(0xFFFFAB91),
          glowSize: 120,
        ),
      ];
    }
    // 밤 (20~24시) - 달 + 별
    if (hour >= 20 && hour < 24) {
      return [
        _buildStars(count: 15),
        _buildMoon(const Alignment(0.6, -0.6)),
      ];
    }
    // 심야 (0~4시) - 달 + 많은 별
    return [
      _buildStars(count: 25),
      _buildMoon(const Alignment(-0.5, -0.5)),
    ];
  }

  Widget _buildSun({
    required Alignment alignment,
    required double size,
    required Color color,
    required Color glowColor,
    required double glowSize,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: glowSize,
        height: glowSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              glowColor.withValues(alpha: 0.6),
              glowColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSunsetRays() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: CustomPaint(
        painter: _SunsetRaysPainter(),
      ),
    );
  }

  Widget _buildMoon(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFFFFFDE7),
              Color(0xFFE0E0E0),
            ],
            center: Alignment(-0.3, -0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFFDE7).withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars({required int count}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final random = math.Random(42); // 고정된 시드로 일관된 별 위치
        return Stack(
          children: List.generate(count, (index) {
            final x = random.nextDouble() * constraints.maxWidth;
            final y = random.nextDouble() * constraints.maxHeight * 0.5; // 상단 절반에만
            final size = 2.0 + random.nextDouble() * 3;
            final opacity = 0.5 + random.nextDouble() * 0.5;

            return Positioned(
              left: x,
              top: y,
              child: _TwinklingStar(size: size, baseOpacity: opacity),
            );
          }),
        );
      },
    );
  }

  Widget _buildCloud(Alignment alignment, double opacity) {
    return Align(
      alignment: alignment,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 80,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 15,
                top: -10,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 35,
                top: -15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getTimeBasedColors() {
    final hour = DateTime.now().hour;

    // 새벽 (4~6시)
    if (hour >= 4 && hour < 6) {
      return const [
        Color(0xFF1A237E), // 진한 남색
        Color(0xFF5C6BC0), // 인디고
        Color(0xFF3E2723), // 어두운 땅
      ];
    }
    // 아침 (6~9시)
    if (hour >= 6 && hour < 9) {
      return const [
        Color(0xFFFFE0B2), // 연한 주황
        Color(0xFFFFCC80), // 살구색
        Color(0xFF8BC34A), // 밝은 초록 땅
      ];
    }
    // 오전 (9~12시)
    if (hour >= 9 && hour < 12) {
      return const [
        Color(0xFFE3F2FD), // 밝은 하늘
        Color(0xFFBBDEFB), // 연한 파랑
        Color(0xFF81C784), // 초록 땅
      ];
    }
    // 점심 (12~14시)
    if (hour >= 12 && hour < 14) {
      return const [
        Color(0xFFE1F5FE), // 밝은 하늘
        Color(0xFFB3E5FC), // 연한 하늘
        Color(0xFF66BB6A), // 초록 땅
      ];
    }
    // 오후 (14~17시)
    if (hour >= 14 && hour < 17) {
      return const [
        Color(0xFFF0FFF4), // 연한 민트 하늘
        Color(0xFFE8F5E9), // 중간
        Color(0xFFC8E6C9), // 땅 근처
      ];
    }
    // 저녁 (17~20시)
    if (hour >= 17 && hour < 20) {
      return const [
        Color(0xFFFFAB91), // 노을 주황
        Color(0xFFFFCC80), // 살구색
        Color(0xFF5D4037), // 어두운 땅
      ];
    }
    // 밤 (20~24시)
    if (hour >= 20 && hour < 24) {
      return const [
        Color(0xFF1A237E), // 진한 남색
        Color(0xFF303F9F), // 남색
        Color(0xFF263238), // 어두운 땅
      ];
    }
    // 심야 (0~4시)
    return const [
      Color(0xFF0D1B2A), // 아주 어두운 파랑
      Color(0xFF1B263B), // 어두운 파랑
      Color(0xFF1B1B1B), // 거의 검은 땅
    ];
  }
}

// 노을 광선 효과를 그리는 CustomPainter
class _SunsetRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.1, size.height * 0.75);
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 여러 광선 그리기
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 8) - math.pi / 4;
      final rayLength = size.width * 1.5;

      final path = Path();
      path.moveTo(center.dx, center.dy);

      final endX1 = center.dx + rayLength * math.cos(angle - 0.05);
      final endY1 = center.dy + rayLength * math.sin(angle - 0.05);
      final endX2 = center.dx + rayLength * math.cos(angle + 0.05);
      final endY2 = center.dy + rayLength * math.sin(angle + 0.05);

      path.lineTo(endX1, endY1);
      path.lineTo(endX2, endY2);
      path.close();

      paint.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          const Color(0xFFFFAB91).withValues(alpha: 0.3 - i * 0.03),
          const Color(0xFFFFAB91).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: rayLength));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 반짝이는 별 위젯
class _TwinklingStar extends StatefulWidget {
  const _TwinklingStar({
    required this.size,
    required this.baseOpacity,
  });

  final double size;
  final double baseOpacity;

  @override
  State<_TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<_TwinklingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    final duration = 1000 + random.nextInt(2000);

    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.baseOpacity * 0.3,
      end: widget.baseOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 랜덤 딜레이 후 시작
    Future.delayed(Duration(milliseconds: random.nextInt(1000)), () {
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
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: _animation.value * 0.5),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }
}
