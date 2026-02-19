import 'package:flutter/material.dart';

import '../core/constants/doodle_colors.dart';
import '../core/constants/doodle_typography.dart';
import '../providers/level_provider.dart';

/// 레벨업 축하 팝업을 표시합니다 (큐 지원)
class LevelUpPopup {
  LevelUpPopup._();

  static OverlayEntry? _currentOverlay;
  static final List<int> _queue = [];
  static BuildContext? _context;
  static bool _isShowing = false;

  /// 레벨업 팝업 표시 (큐에 추가)
  static void show(BuildContext context, int newLevel) {
    _context = context;
    _queue.add(newLevel);

    if (!_isShowing) {
      _showNext();
    }
  }

  static void _showNext() {
    if (_queue.isEmpty || _context == null) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final level = _queue.removeAt(0);

    _currentOverlay = OverlayEntry(
      builder: (context) => _LevelUpPopupWidget(
        level: level,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          Future.delayed(const Duration(milliseconds: 300), _showNext);
        },
      ),
    );

    Overlay.of(_context!).insert(_currentOverlay!);
  }

  /// 모든 팝업 즉시 닫기
  static void dismissAll() {
    _queue.clear();
    _currentOverlay?.remove();
    _currentOverlay = null;
    _isShowing = false;
  }
}

class _LevelUpPopupWidget extends StatefulWidget {
  const _LevelUpPopupWidget({
    required this.level,
    required this.onDismiss,
  });

  final int level;
  final VoidCallback onDismiss;

  @override
  State<_LevelUpPopupWidget> createState() => _LevelUpPopupWidgetState();
}

class _LevelUpPopupWidgetState extends State<_LevelUpPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // 3초 후 자동 닫힘
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = LevelProvider.titleForLevel(widget.level);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _dismiss,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        DoodleColors.primaryLight,
                        DoodleColors.highlightGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: DoodleColors.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DoodleColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 레벨 숫자
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.level}',
                            style: DoodleTypography.numberMedium.copyWith(
                              color: DoodleColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 텍스트
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  '🎉',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '레벨 업!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: DoodleColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lv. ${widget.level} 달성!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 12,
                                color: DoodleColors.primaryDark
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 닫기 버튼
                      IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close,
                          color: DoodleColors.primaryDark.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
