import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/doodle_colors.dart';
import '../core/constants/doodle_typography.dart';
import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../screens/todo_form_screen.dart';
import '../shared/widgets/doodle_checkbox.dart';

class TodoListItem extends StatefulWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.categoryEmoji,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.depth = 0,
  });

  final Todo todo;
  final String categoryEmoji;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int depth;

  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late final double _rotation;
  late final double _offsetX;

  @override
  void initState() {
    super.initState();
    // 각 아이템마다 약간씩 다른 회전값과 오프셋 부여 (자연스러운 포스트잇 느낌)
    final random = math.Random(widget.todo.id.hashCode);
    _rotation = (random.nextDouble() - 0.5) * 0.03; // -1.5° ~ 1.5°
    _offsetX = (random.nextDouble() - 0.5) * 4; // -2px ~ 2px
  }

  // 포스트잇 색상 (우선순위 기반)
  Color _getPostItColor() {
    if (widget.todo.isCompleted) {
      return DoodleColors.postItCompleted;
    }
    return DoodleColors.getPostItColor(widget.todo.priority.index);
  }

  // 포스트잇 테두리 색상 (배경보다 약간 진한 색)
  Color _getPostItBorderColor() {
    final baseColor = _getPostItColor();
    return Color.lerp(baseColor, Colors.black, 0.1)!;
  }

  // 우선순위 이모지
  String _priorityEmoji(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return '🔥';
      case Priority.high:
        return '⭐';
      case Priority.medium:
        return '📌';
      case Priority.low:
        return '🌿';
      case Priority.veryLow:
        return '💤';
    }
  }

  // 예상 시간 라벨
  String? _getTimeLabel() {
    if (widget.todo.estimatedMinutes == null || widget.todo.estimatedMinutes == 0) {
      return null;
    }

    final estimated = widget.todo.estimatedMinutes!;
    final actual = widget.todo.actualMinutes ?? 0;

    if (actual > 0) {
      return '$actual/$estimated분';
    }

    if (estimated >= 60) {
      final hours = estimated ~/ 60;
      final mins = estimated % 60;
      if (mins > 0) {
        return '$hours시간 $mins분';
      }
      return '$hours시간';
    }
    return '$estimated분';
  }

  // 반복 주기 라벨
  String? _getRecurrenceLabel() {
    switch (widget.todo.recurrence) {
      case Recurrence.none:
        return null;
      case Recurrence.daily:
        return '매일';
      case Recurrence.weekly:
        return '매주';
      case Recurrence.monthly:
        return '매월';
      case Recurrence.custom:
        if (widget.todo.recurrenceDays == null || widget.todo.recurrenceDays!.isEmpty) {
          return null;
        }
        final days = ['월', '화', '수', '목', '금', '토', '일'];
        final selectedDays = widget.todo.recurrenceDays!.map((d) => days[d]).join(', ');
        return '매주 $selectedDays';
    }
  }

  // D-Day 계산
  String? _getDDay() {
    if (widget.todo.dueDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      widget.todo.dueDate!.year,
      widget.todo.dueDate!.month,
      widget.todo.dueDate!.day,
    );

    final difference = dueDate.difference(today).inDays;

    if (difference < 0) {
      return 'D+${-difference}';
    } else if (difference == 0) {
      return 'D-Day';
    } else {
      return 'D-$difference';
    }
  }

  // D-Day 색상
  Color _getDDayColor() {
    if (widget.todo.dueDate == null) return DoodleColors.pencilLight;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      widget.todo.dueDate!.year,
      widget.todo.dueDate!.month,
      widget.todo.dueDate!.day,
    );

    final difference = dueDate.difference(today).inDays;
    return DoodleColors.getDDayColor(difference);
  }

  // 마감일 지났는지 확인
  bool _isOverdue() {
    if (widget.todo.dueDate == null || widget.todo.isCompleted) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      widget.todo.dueDate!.year,
      widget.todo.dueDate!.month,
      widget.todo.dueDate!.day,
    );

    return dueDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TodoProvider, CategoryProvider>(
      builder: (context, todoProvider, categoryProvider, _) {
        final children = todoProvider.getChildTodos(widget.todo.id);
        final hasChildren = children.isNotEmpty;

        return Column(
          children: [
            // 포스트잇 아이템
            Transform.translate(
              offset: Offset(_offsetX, 0),
              child: Transform.rotate(
                angle: _rotation,
                child: Dismissible(
                  key: Key(widget.todo.id),
                  direction: DismissDirection.horizontal,
                  background: _buildSwipeBackground(isComplete: true),
                  secondaryBackground: _buildSwipeBackground(isComplete: false),
                  confirmDismiss: (direction) => _handleDismiss(direction, context),
                  onDismissed: (direction) => _onDismissed(direction, context),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: _buildPostItCard(hasChildren),
                  ),
                ),
              ),
            ),

            // 하위 할일 목록
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: children.map((child) {
                  final childCategory = child.categoryIds.isNotEmpty
                      ? categoryProvider.getCategoryById(child.categoryIds.first)
                      : null;
                  return TodoListItem(
                    todo: child,
                    categoryEmoji: childCategory?.emoji ?? '📌',
                    onToggle: () => todoProvider.toggleComplete(child.id),
                    onTap: () => _openFormScreen(context, child),
                    onDelete: () => todoProvider.deleteWithChildren(child.id),
                    depth: widget.depth + 1,
                  );
                }).toList(),
              ),
              crossFadeState: hasChildren && _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostItCard(bool hasChildren) {
    final isOverdue = _isOverdue();

    return Container(
      margin: EdgeInsets.only(
        left: 16 + (widget.depth * 16).toDouble(),
        right: 16,
        top: 6,
        bottom: 6,
      ),
      child: Stack(
        children: [
          // 포스트잇 본체
          DecoratedBox(
            decoration: BoxDecoration(
              color: _getPostItColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              border: Border(
                left: BorderSide(color: _getPostItBorderColor(), width: 1),
                right: BorderSide(color: _getPostItBorderColor(), width: 1),
                bottom: BorderSide(color: _getPostItBorderColor(), width: 1),
              ),
              boxShadow: widget.todo.isCompleted
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(2, 3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 접착 부분 (테이프 효과)
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getPostItBorderColor().withValues(alpha: 0.3),
                        _getPostItColor(),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ),
                // 포스트잇 내용
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 확장/축소 버튼
                      if (hasChildren)
                        GestureDetector(
                          onTap: () => setState(() => _isExpanded = !_isExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2, right: 8),
                            child: AnimatedRotation(
                              turns: _isExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: widget.todo.isCompleted
                                    ? DoodleColors.pencilLight
                                    : DoodleColors.pencilDark,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                      // 체크박스
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: DoodleCheckbox(
                          value: widget.todo.isCompleted,
                          onChanged: (_) => widget.onToggle(),
                          size: 24,
                          checkColor: DoodleColors.crayonRed,
                          boxColor: DoodleColors.pencilDark,
                        ),
                      ),

                      // 내용 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목 행
                            Row(
                              children: [
                                // 우선순위 이모지
                                if (!widget.todo.isCompleted)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Text(
                                      _priorityEmoji(widget.todo.priority),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                // 제목
                                Expanded(
                                  child: Text(
                                    widget.todo.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.todo.isCompleted
                                        ? DoodleTypography.todoTitleCompleted
                                        : DoodleTypography.todoTitle.copyWith(
                                            color: isOverdue
                                                ? DoodleColors.crayonRed
                                                : DoodleColors.inkBlack,
                                          ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // 메타 정보 (스티커 스타일)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                // 카테고리 이모지
                                _StickerBadge(
                                  emoji: widget.categoryEmoji,
                                  isCompleted: widget.todo.isCompleted,
                                ),
                                // D-Day 뱃지
                                if (_getDDay() != null && !widget.todo.isCompleted)
                                  _StickerBadge(
                                    text: _getDDay()!,
                                    color: _getDDayColor(),
                                    isCompleted: widget.todo.isCompleted,
                                  ),
                                // 반복 뱃지
                                if (_getRecurrenceLabel() != null && !widget.todo.isCompleted)
                                  _StickerBadge(
                                    emoji: '🔄',
                                    text: _getRecurrenceLabel()!,
                                    color: DoodleColors.crayonPurple,
                                    isCompleted: widget.todo.isCompleted,
                                  ),
                                // 시간 뱃지
                                if (_getTimeLabel() != null)
                                  _StickerBadge(
                                    emoji: '⏱',
                                    text: _getTimeLabel()!,
                                    color: DoodleColors.inkBlue,
                                    isCompleted: widget.todo.isCompleted,
                                  ),
                                // 마감일
                                if (widget.todo.dueDate != null && !widget.todo.isCompleted)
                                  _StickerBadge(
                                    emoji: '📅',
                                    text: '${widget.todo.dueDate!.month}/${widget.todo.dueDate!.day}',
                                    isCompleted: widget.todo.isCompleted,
                                  ),
                              ],
                            ),

                            // 설명이 있으면 표시
                            if (widget.todo.description != null &&
                                widget.todo.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.todo.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DoodleTypography.bodySmall.copyWith(
                                  color: widget.todo.isCompleted
                                      ? DoodleColors.pencilLight
                                      : DoodleColors.pencilDark.withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 마감 지남 표시 (빨간 스탬프 효과)
          if (isOverdue)
            Positioned(
              right: 8,
              top: 12,
              child: Transform.rotate(
                angle: -0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: DoodleColors.crayonRed.withValues(alpha: 0.8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '지연!',
                    style: DoodleTypography.badge.copyWith(
                      color: DoodleColors.crayonRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),

          // 완료 체크 표시
          if (widget.todo.isCompleted)
            Positioned(
              right: 8,
              top: 12,
              child: Transform.rotate(
                angle: -0.1,
                child: Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: DoodleColors.crayonGreen.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isComplete}) {
    final color = isComplete
        ? (widget.todo.isCompleted ? DoodleColors.crayonOrange : DoodleColors.crayonGreen)
        : DoodleColors.crayonRed;
    final icon = isComplete
        ? (widget.todo.isCompleted ? Icons.replay_rounded : Icons.check_rounded)
        : Icons.delete_rounded;
    final text = isComplete
        ? (widget.todo.isCompleted ? '미완료' : '완료!')
        : '삭제';

    return Container(
      alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(left: isComplete ? 24 : 0, right: isComplete ? 0 : 24),
      margin: EdgeInsets.only(
        left: 16 + (widget.depth * 16).toDouble(),
        right: 16,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isComplete) ...[
            Text(
              text,
              style: DoodleTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 28),
          if (isComplete) ...[
            const SizedBox(width: 8),
            Text(
              text,
              style: DoodleTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool?> _handleDismiss(DismissDirection direction, BuildContext context) async {
    if (direction == DismissDirection.startToEnd) {
      widget.onToggle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.todo.isCompleted
                ? '"${widget.todo.title}" 미완료로 변경'
                : '"${widget.todo.title}" 완료! 🎉',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '취소',
            onPressed: () => widget.onToggle(),
          ),
        ),
      );
      return false;
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할일 삭제'),
        content: Text('"${widget.todo.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: DoodleColors.crayonRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _onDismissed(DismissDirection direction, BuildContext context) {
    if (direction == DismissDirection.endToStart) {
      widget.onDelete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${widget.todo.title}" 삭제됨'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openFormScreen(BuildContext context, Todo? todo, {String? parentId}) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: TodoFormScreen(todo: todo, isDialog: true, parentId: parentId),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TodoFormScreen(todo: todo, parentId: parentId),
        ),
      );
    }
  }
}

/// 스티커 스타일 뱃지 (손으로 붙인 스티커 느낌)
class _StickerBadge extends StatelessWidget {
  const _StickerBadge({
    this.emoji,
    this.text,
    this.color,
    this.isCompleted = false,
  });

  final String? emoji;
  final String? text;
  final Color? color;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final displayColor = isCompleted ? DoodleColors.pencilLight : (color ?? DoodleColors.pencilDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted
            ? DoodleColors.paperGrid.withValues(alpha: 0.5)
            : (color?.withValues(alpha: 0.15) ?? DoodleColors.paperWhite),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCompleted
              ? DoodleColors.pencilLight.withValues(alpha: 0.3)
              : displayColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(
              emoji!,
              style: TextStyle(fontSize: isCompleted ? 10 : 11),
            ),
          if (emoji != null && text != null) const SizedBox(width: 3),
          if (text != null)
            Text(
              text!,
              style: DoodleTypography.badge.copyWith(
                color: displayColor,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
