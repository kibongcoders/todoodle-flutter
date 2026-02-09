import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/achievement_provider.dart';
import '../widgets/achievement_popup.dart';
import 'calendar_screen.dart';
import 'focus_screen.dart';
import 'habit_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    FocusScreen(),
    HabitScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 업적 획득 시 팝업 표시 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final achievementProvider = context.read<AchievementProvider>();
      achievementProvider.onAchievementUnlocked = (achievement) {
        if (mounted) {
          AchievementPopup.show(context, achievement);
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: '홈',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_month_rounded,
                  label: '캘린더',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.timer_rounded,
                  label: '집중',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.local_fire_department_rounded,
                  label: '습관',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_rounded,
                  label: '설정',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8E6CF).withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
