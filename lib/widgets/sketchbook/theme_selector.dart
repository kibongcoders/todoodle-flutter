import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';
import '../../core/constants/sketchbook_theme.dart';
import '../../providers/sketchbook_provider.dart';

/// 스케치북 테마 선택 위젯
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key, required this.provider});

  final SketchbookProvider provider;

  @override
  Widget build(BuildContext context) {
    final currentTheme = provider.currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '테마',
            style: TextStyle(
              fontSize: 12,
              color: DoodleColors.pencilLight,
            ),
          ),
          const SizedBox(width: 12),
          ...SketchbookTheme.values.map((theme) {
            final data = SketchbookThemeData.of(theme);
            final isSelected = theme == currentTheme;
            return GestureDetector(
              onTap: () => provider.setTheme(theme),
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: data.pageColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? DoodleColors.primary
                        : DoodleColors.paperGrid,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: DoodleColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: DoodleColors.primary)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
