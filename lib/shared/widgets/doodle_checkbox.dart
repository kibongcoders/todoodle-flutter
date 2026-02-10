import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';

/// Doodle 스타일 체크박스 위젯
///
/// 손으로 그린 듯한 체크박스입니다.
/// - 미완료: 약간 삐뚤한 빈 네모
/// - 완료: 빨간 체크마크 (휙 그은 느낌)
class DoodleCheckbox extends StatefulWidget {
  const DoodleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.checkColor,
    this.boxColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  /// 체크 상태
  final bool value;

  /// 상태 변경 콜백
  final ValueChanged<bool>? onChanged;

  /// 체크박스 크기
  final double size;

  /// 체크마크 색상 (기본값: crayonRed)
  final Color? checkColor;

  /// 박스 테두리 색상 (기본값: pencilLight)
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
            painter: _DoodleCheckboxPainter(
              progress: _checkAnimation.value,
              checkColor: widget.checkColor ?? DoodleColors.crayonRed,
              boxColor: widget.boxColor ?? DoodleColors.pencilLight,
            ),
          );
        },
      ),
    );
  }
}

/// 체크박스 페인터
class _DoodleCheckboxPainter extends CustomPainter {
  _DoodleCheckboxPainter({
    required this.progress,
    required this.checkColor,
    required this.boxColor,
  });

  final double progress;
  final Color checkColor;
  final Color boxColor;

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = boxColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 손그림 느낌의 약간 불규칙한 사각형
    final boxPath = Path();
    final margin = size.width * 0.1;
    final boxSize = size.width - margin * 2;

    // 약간 삐뚤게 그리기 위한 오프셋
    const skew = 1.0;

    boxPath.moveTo(margin + skew, margin);
    boxPath.lineTo(margin + boxSize - skew, margin + skew);
    boxPath.lineTo(margin + boxSize, margin + boxSize - skew);
    boxPath.lineTo(margin + skew, margin + boxSize + skew);
    boxPath.close();

    canvas.drawPath(boxPath, boxPaint);

    // 체크마크 그리기 (애니메이션)
    if (progress > 0) {
      final checkPaint = Paint()
        ..color = checkColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final checkPath = Path();

      // 체크마크 시작점 (왼쪽 아래)
      final startX = size.width * 0.2;
      final startY = size.height * 0.5;

      // 중간점 (아래 꺾이는 점)
      final midX = size.width * 0.4;
      final midY = size.height * 0.7;

      // 끝점 (오른쪽 위)
      final endX = size.width * 0.85;
      final endY = size.height * 0.25;

      // 진행도에 따라 체크마크 그리기
      if (progress < 0.5) {
        // 첫 번째 획 (왼쪽에서 중간까지)
        final p = progress * 2;
        checkPath.moveTo(startX, startY);
        checkPath.lineTo(
          startX + (midX - startX) * p,
          startY + (midY - startY) * p,
        );
      } else {
        // 첫 번째 획 완료
        checkPath.moveTo(startX, startY);
        checkPath.lineTo(midX, midY);

        // 두 번째 획 (중간에서 끝까지)
        final p = (progress - 0.5) * 2;
        checkPath.lineTo(
          midX + (endX - midX) * p,
          midY + (endY - midY) * p,
        );
      }

      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DoodleCheckboxPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        checkColor != oldDelegate.checkColor ||
        boxColor != oldDelegate.boxColor;
  }
}

/// 원형 Doodle 체크박스
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
