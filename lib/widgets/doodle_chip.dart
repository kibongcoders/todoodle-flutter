import 'package:flutter/material.dart';

import '../core/constants/doodle_colors.dart';
import '../core/constants/doodle_typography.dart';

/// Doodle 스타일의 선택 칩
///
/// 손그림 느낌의 선택 가능한 칩 위젯입니다.
/// - 종이 질감 배경
/// - 연필 느낌 테두리
/// - 선택 시 형광펜 효과
class DoodleChip extends StatelessWidget {
  const DoodleChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.selectedColor,
    this.avatar,
    this.padding,
    this.enabled = true,
  });

  /// 칩에 표시할 텍스트
  final String label;

  /// 선택 상태
  final bool isSelected;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 선택 시 배경색 (기본: highlightYellow)
  final Color? selectedColor;

  /// 앞에 표시할 아이콘/위젯 (이모지 등)
  final Widget? avatar;

  /// 내부 패딩
  final EdgeInsetsGeometry? padding;

  /// 활성화 상태
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedColor ?? DoodleColors.highlightYellow)
        : DoodleColors.paperCream;

    final borderColor = isSelected
        ? DoodleColors.pencilDark.withValues(alpha: 0.4)
        : DoodleColors.pencilLight.withValues(alpha: 0.5);

    final textColor = enabled
        ? (isSelected ? DoodleColors.pencilDark : DoodleColors.pencilDark)
        : DoodleColors.pencilLight;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? bgColor : DoodleColors.paperGrid.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (selectedColor ?? DoodleColors.highlightYellow)
                        .withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[
              avatar!,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: DoodleTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Doodle 스타일의 선택 칩 (아이콘 포함)
class DoodleIconChip extends StatelessWidget {
  const DoodleIconChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.icon,
    this.emoji,
    this.onTap,
    this.selectedColor,
    this.enabled = true,
  });

  final String label;
  final bool isSelected;
  final IconData? icon;
  final String? emoji;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Widget? avatar;

    if (emoji != null) {
      avatar = Text(emoji!, style: const TextStyle(fontSize: 16));
    } else if (icon != null) {
      avatar = Icon(
        icon,
        size: 18,
        color: isSelected ? DoodleColors.pencilDark : DoodleColors.pencilLight,
      );
    }

    return DoodleChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: selectedColor,
      avatar: avatar,
      enabled: enabled,
    );
  }
}

/// Doodle 스타일의 칩 그룹 (단일 선택)
class DoodleChipGroup<T> extends StatelessWidget {
  const DoodleChipGroup({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    this.iconBuilder,
    this.emojiBuilder,
    this.colorBuilder,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  /// 선택 가능한 아이템 목록
  final List<T> items;

  /// 현재 선택된 아이템
  final T? selectedItem;

  /// 아이템의 레이블 생성 함수
  final String Function(T item) labelBuilder;

  /// 선택 콜백
  final void Function(T item) onSelected;

  /// 아이템의 아이콘 생성 함수 (선택적)
  final IconData? Function(T item)? iconBuilder;

  /// 아이템의 이모지 생성 함수 (선택적)
  final String? Function(T item)? emojiBuilder;

  /// 아이템의 선택 색상 생성 함수 (선택적)
  final Color? Function(T item)? colorBuilder;

  /// 칩 간 가로 간격
  final double spacing;

  /// 칩 간 세로 간격
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) {
        final isSelected = item == selectedItem;
        final icon = iconBuilder?.call(item);
        final emoji = emojiBuilder?.call(item);
        final color = colorBuilder?.call(item);

        return DoodleIconChip(
          label: labelBuilder(item),
          isSelected: isSelected,
          icon: icon,
          emoji: emoji,
          onTap: () => onSelected(item),
          selectedColor: color,
        );
      }).toList(),
    );
  }
}

/// Doodle 스타일의 칩 그룹 (다중 선택)
class DoodleMultiChipGroup<T> extends StatelessWidget {
  const DoodleMultiChipGroup({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.labelBuilder,
    required this.onToggle,
    this.iconBuilder,
    this.emojiBuilder,
    this.colorBuilder,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  /// 선택 가능한 아이템 목록
  final List<T> items;

  /// 현재 선택된 아이템 집합
  final Set<T> selectedItems;

  /// 아이템의 레이블 생성 함수
  final String Function(T item) labelBuilder;

  /// 토글 콜백
  final void Function(T item) onToggle;

  /// 아이템의 아이콘 생성 함수 (선택적)
  final IconData? Function(T item)? iconBuilder;

  /// 아이템의 이모지 생성 함수 (선택적)
  final String? Function(T item)? emojiBuilder;

  /// 아이템의 선택 색상 생성 함수 (선택적)
  final Color? Function(T item)? colorBuilder;

  /// 칩 간 가로 간격
  final double spacing;

  /// 칩 간 세로 간격
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        final icon = iconBuilder?.call(item);
        final emoji = emojiBuilder?.call(item);
        final color = colorBuilder?.call(item);

        return DoodleIconChip(
          label: labelBuilder(item),
          isSelected: isSelected,
          icon: icon,
          emoji: emoji,
          onTap: () => onToggle(item),
          selectedColor: color,
        );
      }).toList(),
    );
  }
}

/// Doodle 스타일의 컴팩트 칩 (작은 사이즈)
class DoodleCompactChip extends StatelessWidget {
  const DoodleCompactChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.textStyle,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return DoodleChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: selectedColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}

/// Doodle 스타일의 섹션 카드
///
/// 폼 화면에서 섹션을 감싸는 종이 느낌의 카드입니다.
class DoodleSectionCard extends StatelessWidget {
  const DoodleSectionCard({
    super.key,
    required this.child,
    this.title,
    this.titleIcon,
    this.padding,
    this.margin,
    this.useDashedBorder = false,
  });

  final Widget child;
  final String? title;
  final IconData? titleIcon;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool useDashedBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(8),
        border: useDashedBorder
            ? null
            : Border.all(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: DoodleColors.paperCream,
                  border: Border(
                    bottom: BorderSide(
                      color: DoodleColors.paperGrid,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (titleIcon != null) ...[
                      Icon(
                        titleIcon,
                        size: 18,
                        color: DoodleColors.pencilDark,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title!,
                      style: DoodleTypography.labelMedium.copyWith(
                        color: DoodleColors.pencilDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Doodle 스타일의 날짜/시간 선택 행
class DoodleDateTimeRow extends StatelessWidget {
  const DoodleDateTimeRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.isSet = false,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isSet;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSet
              ? DoodleColors.highlightYellow.withValues(alpha: 0.3)
              : DoodleColors.paperCream,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSet
                ? DoodleColors.pencilDark.withValues(alpha: 0.3)
                : DoodleColors.paperGrid,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: DoodleColors.pencilDark,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: DoodleTypography.labelSmall.copyWith(
                      color: DoodleColors.pencilLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: DoodleTypography.bodyMedium.copyWith(
                      color: DoodleColors.pencilDark,
                      fontWeight: isSet ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (isSet && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: DoodleColors.pencilLight,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: DoodleColors.pencilLight,
              ),
          ],
        ),
      ),
    );
  }
}
