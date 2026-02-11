import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';

/// Doodle 스타일 체크박스 위젯
///
/// 포스트잇에 연필로 그린 듯한 손그림 체크박스입니다.
/// - 미완료: 연필로 그린 원
/// - 완료: 원 안에 휙 그은 체크마크
class DoodleCheckbox extends StatefulWidget {
  const DoodleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.checkColor,
    this.boxColor,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  /// 체크 상태
  final bool value;

  /// 상태 변경 콜백
  final ValueChanged<bool>? onChanged;

  /// 체크박스 크기
  final double size;

  /// 체크마크 색상 (기본값: crayonRed)
  final Color? checkColor;

  /// 박스 테두리 색상 (기본값: pencilDark)
  final Color? boxColor;

  /// 애니메이션 시간
  final Duration animationDuration;

  @override
  State<DoodleCheckbox> createState() => _DoodleCheckboxState();
}

class _DoodleCheckboxState extends State<DoodleCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DoodleCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onChanged != null
          ? () => widget.onChanged!(!widget.value)
          : null,
      child: AnimatedBuilder(
        animation: _checkAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _HandDrawnCheckboxPainter(
              progress: _checkAnimation.value,
              checkColor: widget.checkColor ?? DoodleColors.crayonRed,
              circleColor: widget.boxColor ?? DoodleColors.pencilDark,
            ),
          );
        },
      ),
    );
  }
}

/// 손그림 스타일 체크박스 페인터
class _HandDrawnCheckboxPainter extends CustomPainter {
  _HandDrawnCheckboxPainter({
    required this.progress,
    required this.checkColor,
    required this.circleColor,
  });

  final double progress;
  final Color checkColor;
  final Color circleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // 손그림 원 그리기 (약간 불규칙하게)
    _drawHandDrawnCircle(canvas, center, radius);

    // 체크마크 그리기 (애니메이션)
    if (progress > 0) {
      _drawHandDrawnCheck(canvas, size, progress);
    }
  }

  /// 손으로 그린 듯한 불규칙한 원
  void _drawHandDrawnCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = circleColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // 불규칙한 원을 그리기 위한 점들 생성
    const segments = 12;
    final random = math.Random(42); // 고정된 시드로 일관된 모양

    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi - math.pi / 2;

      // 약간의 불규칙성 추가
      final wobble = (random.nextDouble() - 0.5) * radius * 0.15;
      final r = radius + wobble;

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // 부드러운 곡선으로 연결
        final prevAngle = ((i - 1) / segments) * 2 * math.pi - math.pi / 2;
        final controlAngle = (prevAngle + angle) / 2;
        final controlR = radius * 1.02;

        final cx = center.dx + controlR * math.cos(controlAngle);
        final cy = center.dy + controlR * math.sin(controlAngle);

        path.quadraticBezierTo(cx, cy, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  /// 손으로 그린 듯한 체크마크
  void _drawHandDrawnCheck(Canvas canvas, Size size, double progress) {
    final paint = Paint()
      ..color = checkColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 체크마크 좌표 (휙 그은 느낌)
    final startX = size.width * 0.22;
    final startY = size.height * 0.52;

    final midX = size.width * 0.42;
    final midY = size.height * 0.72;

    final endX = size.width * 0.82;
    final endY = size.height * 0.28;

    final path = Path();

    // 진행도에 따라 체크마크 그리기
    if (progress < 0.4) {
      // 첫 번째 획 (왼쪽에서 중간까지)
      final p = progress / 0.4;
      path.moveTo(startX, startY);
      path.lineTo(
        startX + (midX - startX) * p,
        startY + (midY - startY) * p,
      );
    } else {
      // 첫 번째 획 완료
      path.moveTo(startX, startY);
      path.lineTo(midX, midY);

      // 두 번째 획 (중간에서 끝까지) - 살짝 곡선으로
      final p = (progress - 0.4) / 0.6;

      // 곡선을 위한 컨트롤 포인트
      final cpX = midX + (endX - midX) * 0.3;
      final cpY = midY - size.height * 0.1;

      final currentEndX = midX + (endX - midX) * p;
      final currentEndY = midY + (endY - midY) * p;

      // 진행 중일 때는 직선으로, 완료되면 약간 곡선
      if (p < 1) {
        path.lineTo(currentEndX, currentEndY);
      } else {
        path.quadraticBezierTo(cpX, cpY, endX, endY);
      }
    }

    canvas.drawPath(path, paint);

    // 완료 시 약간의 장식 효과 (체크 끝에 점)
    if (progress >= 1.0) {
      final dotPaint = Paint()
        ..color = checkColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(endX, endY), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandDrawnCheckboxPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        checkColor != oldDelegate.checkColor ||
        circleColor != oldDelegate.circleColor;
  }
}

/// 원형 Doodle 체크박스 (채워지는 스타일)
class DoodleCircleCheckbox extends StatefulWidget {
  const DoodleCircleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.checkColor,
    this.circleColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color? checkColor;
  final Color? circleColor;

  @override
  State<DoodleCircleCheckbox> createState() => _DoodleCircleCheckboxState();
}

class _DoodleCircleCheckboxState extends State<DoodleCircleCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DoodleCircleCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onChanged != null
          ? () => widget.onChanged!(!widget.value)
          : null,
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _DoodleCircleCheckboxPainter(
              progress: _fillAnimation.value,
              fillColor: widget.checkColor ?? DoodleColors.primary,
              circleColor: widget.circleColor ?? DoodleColors.pencilLight,
            ),
          );
        },
      ),
    );
  }
}

/// 원형 체크박스 페인터
class _DoodleCircleCheckboxPainter extends CustomPainter {
  _DoodleCircleCheckboxPainter({
    required this.progress,
    required this.fillColor,
    required this.circleColor,
  });

  final double progress;
  final Color fillColor;
  final Color circleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // 테두리
    final circlePaint = Paint()
      ..color = circleColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, circlePaint);

    // 채우기 (애니메이션)
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius * progress, fillPaint);

      // 체크 아이콘
      if (progress > 0.5) {
        final checkPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final checkPath = Path();
        checkPath.moveTo(size.width * 0.3, size.height * 0.5);
        checkPath.lineTo(size.width * 0.45, size.height * 0.65);
        checkPath.lineTo(size.width * 0.7, size.height * 0.35);

        canvas.drawPath(checkPath, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DoodleCircleCheckboxPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fillColor != oldDelegate.fillColor ||
        circleColor != oldDelegate.circleColor;
  }
}
