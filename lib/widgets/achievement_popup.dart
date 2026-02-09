import 'package:flutter/material.dart';

import '../models/achievement.dart';

/// 업적 획득 팝업을 표시합니다
class AchievementPopup {
  AchievementPopup._();

  static OverlayEntry? _currentOverlay;

  /// 업적 획득 팝업 표시
  static void show(BuildContext context, Achievement achievement) {
    // 이전 팝업이 있으면 제거
    _currentOverlay?.remove();

    final meta = AchievementMeta.getMeta(achievement.type);

    _currentOverlay = OverlayEntry(
      builder: (context) => _AchievementPopupWidget(
        meta: meta,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }
}

class _AchievementPopupWidget extends StatefulWidget {
  const _AchievementPopupWidget({
    required this.meta,
    required this.onDismiss,
  });

  final AchievementMeta meta;
  final VoidCallback onDismiss;

  @override
  State<_AchievementPopupWidget> createState() => _AchievementPopupWidgetState();
}

class _AchievementPopupWidgetState extends State<_AchievementPopupWidget>
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
                      colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD54F),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 아이콘
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
                            widget.meta.icon,
                            style: const TextStyle(fontSize: 28),
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
                                  '업적 달성!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFF8F00),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.meta.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.meta.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.brown[400],
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
                          color: Colors.brown[300],
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
