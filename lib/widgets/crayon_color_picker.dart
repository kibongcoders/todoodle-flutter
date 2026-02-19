import 'package:flutter/material.dart';

import '../core/constants/doodle_colors.dart';

/// 크레파스 색상 선택 바텀시트
///
/// 완성된 낙서에 색칠할 색상을 선택합니다.
class CrayonColorPicker extends StatelessWidget {
  const CrayonColorPicker({
    super.key,
    required this.currentColorIndex,
    required this.onColorSelected,
  });

  final int? currentColorIndex;
  final ValueChanged<int?> onColorSelected;

  static Future<void> show(
    BuildContext context, {
    required int? currentColorIndex,
    required ValueChanged<int?> onColorSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CrayonColorPicker(
        currentColorIndex: currentColorIndex,
        onColorSelected: (index) {
          onColorSelected(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DoodleColors.pencilLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '크레파스 색칠',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DoodleColors.pencilDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 리셋 (연필 기본)
                _buildColorButton(
                  color: DoodleColors.pencilLight,
                  isSelected: currentColorIndex == null,
                  icon: Icons.edit_outlined,
                  onTap: () => onColorSelected(null),
                ),
                const SizedBox(width: 8),
                // 크레파스 7색
                ...List.generate(DoodleColors.crayonPalette.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildColorButton(
                      color: DoodleColors.crayonPalette[index],
                      isSelected: currentColorIndex == index,
                      onTap: () => onColorSelected(index),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton({
    required Color color,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? DoodleColors.pencilDark : DoodleColors.paperGrid,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: icon != null
            ? Icon(icon, size: 16, color: Colors.white)
            : isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
      ),
    );
  }
}
