import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../screens/todo_form_screen.dart';

class TodoListItem extends StatefulWidget {
  final Todo todo;
  final String categoryEmoji;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int depth;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.categoryEmoji,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.depth = 0,
  });

  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

  // Material 3 스타일 우선순위 색상
  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return const Color(0xFFB71C1C); // 진한 빨강
      case Priority.high:
        return const Color(0xFFE53935); // 빨강
      case Priority.medium:
        return const Color(0xFFFFA726); // 주황
      case Priority.low:
        return const Color(0xFF66BB6A); // 초록
      case Priority.veryLow:
        return const Color(0xFF42A5F5); // 파랑
    }
  }

  // 우선순위 배경 색상 (연한 버전)
  Color _priorityBackgroundColor(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return const Color(0xFFFFCDD2); // 연한 빨강
      case Priority.high:
        return const Color(0xFFFFEBEE);
      case Priority.medium:
        return const Color(0xFFFFF3E0);
      case Priority.low:
        return const Color(0xFFE8F5E9);
      case Priority.veryLow:
        return const Color(0xFFE3F2FD); // 연한 파랑
    }
  }

  // 우선순위 라벨
  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return '비상';
      case Priority.high:
        return '높음';
      case Priority.medium:
        return '보통';
      case Priority.low:
        return '낮음';
      case Priority.veryLow:
        return '매우 낮음';
    }
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
    if (widget.todo.dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      widget.todo.dueDate!.year,
      widget.todo.dueDate!.month,
      widget.todo.dueDate!.day,
    );

    final difference = dueDate.difference(today).inDays;

    if (difference < 0) {
      return const Color(0xFFE53935); // 지남 - 빨강
    } else if (difference == 0) {
      return const Color(0xFFE53935); // 오늘 - 빨강
    } else if (difference <= 3) {
      return const Color(0xFFFFA726); // 3일 이내 - 주황
    } else {
      return const Color(0xFF66BB6A); // 여유 - 초록
    }
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

  String _buildSubtitle() {
    final parts = <String>[];

    // 카테고리 이모지
    parts.add(widget.categoryEmoji);

    // 마감일이 있으면 표시
    if (widget.todo.dueDate != null) {
      final due = widget.todo.dueDate!;
      parts.add('${due.month}/${due.day}');
    }

    // 설명이 있으면 표시
    if (widget.todo.description != null && widget.todo.description!.isNotEmpty) {
      parts.add(widget.todo.description!);
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TodoProvider, CategoryProvider>(
      builder: (context, todoProvider, categoryProvider, _) {
        final children = todoProvider.getChildTodos(widget.todo.id);
        final hasChildren = children.isNotEmpty;

        return Column(
          children: [
            Dismissible(
              key: Key(widget.todo.id),
              direction: DismissDirection.horizontal,
              // 오른쪽으로 스와이프 (완료/미완료 토글)
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                margin: EdgeInsets.only(
                  left: 16 + (widget.depth * 20).toDouble(),
                  right: 16,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.todo.isCompleted
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.todo.isCompleted
                          ? Icons.replay_rounded
                          : Icons.check_circle_rounded,
                      color: widget.todo.isCompleted
                          ? Colors.orange
                          : const Color(0xFF2E7D32),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.todo.isCompleted ? '미완료' : '완료',
                      style: TextStyle(
                        color: widget.todo.isCompleted
                            ? Colors.orange
                            : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 왼쪽으로 스와이프 (삭제)
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: EdgeInsets.only(
                  left: 16 + (widget.depth * 20).toDouble(),
                  right: 16,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    SizedBox(width: 16),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // 완료/미완료 토글
                  widget.onToggle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.todo.isCompleted
                            ? '"${widget.todo.title}" 미완료로 변경'
                            : '"${widget.todo.title}" 완료!',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: '취소',
                        onPressed: () => widget.onToggle(),
                      ),
                    ),
                  );
                  return false; // 항목 유지
                }
                // 삭제 확인 다이얼로그
                final confirmed = await showDialog<bool>(
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
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
                return confirmed ?? false;
              },
              onDismissed: (direction) {
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
              },
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 16 + (widget.depth * 20).toDouble(),
                    right: 16,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.todo.isCompleted
                        ? Colors.grey[50]
                        : _isOverdue()
                            ? const Color(0xFFFFEBEE) // 지연된 할일 - 연한 빨강 배경
                            : _priorityBackgroundColor(widget.todo.priority),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.todo.isCompleted
                          ? Colors.grey[300]!
                          : _isOverdue()
                              ? const Color(0xFFE53935) // 지연된 할일 - 빨간 테두리
                              : _priorityColor(widget.todo.priority).withValues(alpha: 0.3),
                      width: _isOverdue() ? 2 : 1,
                    ),
                    boxShadow: widget.todo.isCompleted
                        ? null
                        : _isOverdue()
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFE53935).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: _priorityColor(widget.todo.priority).withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        // 확장/축소 버튼
                        if (hasChildren)
                          GestureDetector(
                            onTap: () => setState(() => _isExpanded = !_isExpanded),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AnimatedRotation(
                                turns: _isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: widget.todo.isCompleted
                                      ? Colors.grey[400]
                                      : _priorityColor(widget.todo.priority),
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 4),

                        const SizedBox(width: 8),

                        // 체크박스 영역
                        GestureDetector(
                          onTap: widget.onToggle,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: widget.todo.isCompleted
                                  ? const Color(0xFF66BB6A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: widget.todo.isCompleted
                                  ? null
                                  : Border.all(
                                      color: _priorityColor(widget.todo.priority),
                                      width: 2,
                                    ),
                            ),
                            child: widget.todo.isCompleted
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 내용 영역
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 제목
                              Text(
                                widget.todo.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  decoration: widget.todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: widget.todo.isCompleted
                                      ? Colors.grey[400]
                                      : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // 메타 정보 (카테고리 + 날짜 + 설명)
                              Row(
                                children: [
                                  // 우선순위 뱃지
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: widget.todo.isCompleted
                                          ? Colors.grey[200]
                                          : _priorityColor(widget.todo.priority).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _priorityLabel(widget.todo.priority),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: widget.todo.isCompleted
                                            ? Colors.grey[400]
                                            : _priorityColor(widget.todo.priority),
                                      ),
                                    ),
                                  ),
                                  // D-Day 뱃지 (마감일이 있을 때만)
                                  if (_getDDay() != null && !widget.todo.isCompleted) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getDDayColor().withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _getDDayColor().withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _getDDay()!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _getDDayColor(),
                                        ),
                                      ),
                                    ),
                                  ],
                                  // 반복 주기 뱃지
                                  if (_getRecurrenceLabel() != null && !widget.todo.isCompleted) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.repeat_rounded,
                                            size: 10,
                                            color: Color(0xFF9C27B0),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            _getRecurrenceLabel()!,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF9C27B0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  // 부가 정보
                                  Expanded(
                                    child: Text(
                                      _buildSubtitle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.todo.isCompleted
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 액션 버튼들
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 하위 할일 추가 버튼
                            _ActionButton(
                              onTap: () => _openFormScreen(context, null, parentId: widget.todo.id),
                              icon: Icons.add_rounded,
                              color: widget.todo.isCompleted
                                  ? Colors.grey[400]!
                                  : const Color(0xFF2E7D32),
                              backgroundColor: const Color(0xFFA8E6CF).withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 6),
                            // 삭제 버튼
                            _ActionButton(
                              onTap: widget.onDelete,
                              icon: Icons.delete_outline_rounded,
                              color: widget.todo.isCompleted
                                  ? Colors.grey[400]!
                                  : Colors.red[400]!,
                              backgroundColor: const Color(0xFFFFCDD2).withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 하위 할일 목록 (애니메이션)
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

// 액션 버튼 위젯
class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
