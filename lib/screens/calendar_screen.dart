import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import 'todo_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '캘린더',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<TodoProvider, CategoryProvider>(
        builder: (context, todoProvider, categoryProvider, _) {
          final events = todoProvider.getTodosForMonth(_focusedDay);
          final selectedTodos = _selectedDay != null
              ? todoProvider.getTodosByDate(_selectedDay!)
              : <Todo>[];

          return Column(
            children: [
              // 캘린더
              _buildCalendar(events),

              // 구분선
              Container(
                height: 1,
                color: Colors.grey[200],
              ),

              // 선택된 날짜 헤더
              _buildSelectedDateHeader(),

              // 할일 목록
              Expanded(
                child: selectedTodos.isEmpty
                    ? _buildEmptyState()
                    : _buildTodoList(selectedTodos, categoryProvider, todoProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_fab',
        onPressed: () => _openFormScreen(context, null),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, List<Todo>> events) {
    return TableCalendar<Todo>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      locale: 'ko_KR',
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) {
        final dateOnly = DateTime(day.year, day.month, day.day);
        return events[dateOnly] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        // 오늘 날짜
        todayDecoration: const BoxDecoration(
          color: Color(0xFFA8E6CF),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.bold,
        ),
        // 선택된 날짜
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF2E7D32),
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        // 마커 (이벤트)
        markerDecoration: const BoxDecoration(
          color: Color(0xFFFF7043),
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 6,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        // 주말
        weekendTextStyle: TextStyle(color: Colors.red[400]),
        // 기타
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: const TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.w600,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: Color(0xFF2E7D32),
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: Color(0xFF2E7D32),
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: Colors.red[400],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final diff = selected.difference(today).inDays;

    String dateLabel;
    if (diff == 0) {
      dateLabel = '오늘';
    } else if (diff == 1) {
      dateLabel = '내일';
    } else if (diff == -1) {
      dateLabel = '어제';
    } else {
      dateLabel = '${_selectedDay!.month}월 ${_selectedDay!.day}일';
    }

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[_selectedDay!.weekday - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($weekday)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _openFormScreen(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('할일 추가'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                '이 날에는 할일이 없어요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _openFormScreen(context, null),
                child: const Text('할일 추가하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(
    List<Todo> todos,
    CategoryProvider categoryProvider,
    TodoProvider todoProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final category = todo.categoryIds.isNotEmpty
            ? categoryProvider.getCategoryById(todo.categoryIds.first)
            : null;

        return _buildTodoItem(todo, category, todoProvider);
      },
    );
  }

  Widget _buildTodoItem(Todo todo, dynamic category, TodoProvider todoProvider) {
    return GestureDetector(
      onTap: () => _openFormScreen(context, todo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: todo.isCompleted ? Colors.grey[50] : _getPriorityColor(todo.priority),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: todo.isCompleted
                ? Colors.grey[300]!
                : _getPriorityBorderColor(todo.priority),
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            GestureDetector(
              onTap: () => todoProvider.toggleComplete(todo.id),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: todo.isCompleted ? const Color(0xFF66BB6A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: todo.isCompleted
                      ? null
                      : Border.all(
                          color: _getPriorityBorderColor(todo.priority),
                          width: 2,
                        ),
                ),
                child: todo.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      color: todo.isCompleted ? Colors.grey[400] : Colors.grey[800],
                    ),
                  ),
                  if (todo.description != null && todo.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 카테고리 이모지
            if (category != null) ...[
              const SizedBox(width: 8),
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return const Color(0xFFFFCDD2);
      case Priority.high:
        return const Color(0xFFFFEBEE);
      case Priority.medium:
        return const Color(0xFFFFF3E0);
      case Priority.low:
        return const Color(0xFFE8F5E9);
      case Priority.veryLow:
        return const Color(0xFFE3F2FD);
    }
  }

  Color _getPriorityBorderColor(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return const Color(0xFFB71C1C);
      case Priority.high:
        return const Color(0xFFE53935);
      case Priority.medium:
        return const Color(0xFFFFA726);
      case Priority.low:
        return const Color(0xFF66BB6A);
      case Priority.veryLow:
        return const Color(0xFF42A5F5);
    }
  }

  void _openFormScreen(BuildContext context, Todo? todo) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 새 할일 추가 시 선택된 날짜를 기본 마감일로 설정
    final defaultDueDate = todo == null ? _selectedDay : null;

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
              child: TodoFormScreen(
                todo: todo,
                isDialog: true,
                defaultDueDate: defaultDueDate,
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TodoFormScreen(
            todo: todo,
            defaultDueDate: defaultDueDate,
          ),
        ),
      );
    }
  }
}
