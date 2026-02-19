import 'package:flutter/material.dart';

import '../core/constants/doodle_colors.dart';
import '../models/doodle.dart';
import 'doodle_painter.dart';

/// 낙서를 표시하는 위젯
///
/// 진행 중이거나 완성된 낙서를 보여줍니다.
/// 완성 시 애니메이션 효과가 적용됩니다.
class DoodleWidget extends StatelessWidget {
  const DoodleWidget({
    super.key,
    required this.doodle,
    this.size = 100,
    this.showLabel = true,
    this.strokeColor,
    this.backgroundColor,
    this.labelColor,
  });

  final Doodle doodle;
  final double size;
  final bool showLabel;
  final Color? strokeColor;
  final Color? backgroundColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 낙서 그림
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? DoodleColors.paperWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: DoodleColors.paperGrid,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: DoodleColors.paperShadow,
                blurRadius: 4,
                offset: Offset(1, 2),
              ),
            ],
          ),
          child: CustomPaint(
            painter: DoodlePainter(
              type: doodle.type,
              progress: doodle.progress,
              strokeColor: strokeColor ?? _getStrokeColor(),
              fillColor: doodle.crayonColor,
            ),
          ),
        ),

        // 라벨
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            doodle.typeName,
            style: TextStyle(
              fontSize: 12,
              color: labelColor ?? DoodleColors.pencilLight,
              fontWeight: doodle.isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          if (!doodle.isCompleted)
            Text(
              '${doodle.currentStroke}/${doodle.maxStrokes}',
              style: TextStyle(
                fontSize: 10,
                color: labelColor ?? DoodleColors.pencilLight,
              ),
            ),
        ],
      ],
    );
  }

  Color _getStrokeColor() {
    if (doodle.isCompleted) {
      return DoodleColors.pencilDark;
    }
    // 진행 중일 때는 약간 연한 색
    return DoodleColors.pencilLight;
  }
}

/// 애니메이션이 적용된 낙서 위젯
///
/// 획이 추가될 때 애니메이션으로 그려지는 효과
class AnimatedDoodleWidget extends StatefulWidget {
  const AnimatedDoodleWidget({
    super.key,
    required this.doodle,
    this.size = 120,
    this.animationDuration = const Duration(milliseconds: 500),
    this.onAnimationComplete,
  });

  final Doodle doodle;
  final double size;
  final Duration animationDuration;
  final VoidCallback? onAnimationComplete;

  @override
  State<AnimatedDoodleWidget> createState() => _AnimatedDoodleWidgetState();
}

class _AnimatedDoodleWidgetState extends State<AnimatedDoodleWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  // 완성 pop 애니메이션
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  bool _justCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _previousProgress = widget.doodle.progress;

    // Pop 애니메이션 (1.0 → 1.15 → 0.95 → 1.0 바운스)
    _popController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_justCompleted) {
          _popController.forward(from: 0);
          _justCompleted = false;
        }
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedDoodleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doodle.progress != oldWidget.doodle.progress) {
      _previousProgress = oldWidget.doodle.progress;

      // 완성 감지 (progress가 1.0에 도달)
      if (widget.doodle.progress >= 1.0 && oldWidget.doodle.progress < 1.0) {
        _justCompleted = true;
      }

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _popAnimation]),
      builder: (context, child) {
        // 이전 진행률에서 현재 진행률까지 보간
        final currentProgress = _previousProgress +
            (_animation.value * (widget.doodle.progress - _previousProgress));

        final scale = _popController.isAnimating ? _popAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DoodleColors.paperCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _popController.isAnimating
                    ? DoodleColors.primary.withValues(alpha: 0.6)
                    : DoodleColors.paperGrid,
                width: _popController.isAnimating ? 2.5 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _popController.isAnimating
                      ? DoodleColors.primary.withValues(alpha: 0.2)
                      : DoodleColors.paperShadow,
                  blurRadius: _popController.isAnimating ? 12 : 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: Size(widget.size - 16, widget.size - 48),
                    painter: DoodlePainter(
                      type: widget.doodle.type,
                      progress: currentProgress,
                      strokeColor: DoodleColors.pencilDark,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doodle.statusDescription,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DoodleColors.pencilDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 낙서 미리보기 (타입만으로 표시)
class DoodlePreview extends StatelessWidget {
  const DoodlePreview({
    super.key,
    required this.type,
    this.size = 60,
    this.strokeColor,
  });

  final DoodleType type;
  final double size;
  final Color? strokeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: DoodleColors.paperGrid,
          width: 1,
        ),
      ),
      child: CustomPaint(
        painter: DoodlePainter(
          type: type,
          progress: 1.0, // 완성된 모습
          strokeColor: strokeColor ?? DoodleColors.pencilLight,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
