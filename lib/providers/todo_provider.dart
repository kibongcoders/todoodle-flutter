import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';
import '../services/notification_service.dart';
import 'forest_provider.dart';
import 'settings_provider.dart';

enum DateFilter {
  all,      // 전체
  today,    // 오늘
  upcoming, // 예정됨 (7일 이내)
}

class TodoProvider extends ChangeNotifier {
  final Box<Todo> _box = Hive.box<Todo>('todos');
  final _uuid = const Uuid();
  final _notificationService = NotificationService();

  SettingsProvider? _settingsProvider;
  ForestProvider? _forestProvider;

  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
    _setupNotificationCallbacks();
  }

  void setForestProvider(ForestProvider provider) {
    _forestProvider = provider;
  }

  /// 알림 액션 콜백 설정
  void _setupNotificationCallbacks() {
    _notificationService.onActionReceived = (todoId, action) {
      if (action == 'complete') {
        toggleComplete(todoId);
      } else if (action == 'open') {
        // 앱이 열리면 해당 할일 화면으로 이동 (추후 구현 가능)
      }
    };
  }

  /// 일일 미완료 요약 알림 스케줄링
  Future<void> scheduleDailySummaryNotification() async {
    if (_settingsProvider == null || !_settingsProvider!.dailySummaryEnabled) {
      await _notificationService.cancelDailySummary();
      return;
    }

    final incompleteCount = _box.values
        .where((t) => !t.isCompleted && !t.isArchived && t.deletedAt == null)
        .length;

    await _notificationService.scheduleDailySummary(
      hour: _settingsProvider!.dailySummaryTime.hour,
      minute: _settingsProvider!.dailySummaryTime.minute,
      incompleteCount: incompleteCount,
    );
  }

  /// 스누즈 알림 스케줄링
  Future<void> snoozeNotification(String todoId, int minutes) async {
    final todo = _box.get(todoId);
    if (todo != null) {
      await _notificationService.scheduleSnoozeNotification(todo, minutes);
    }
  }

  bool get _isGlobalNotificationEnabled =>
      _settingsProvider?.notificationEnabled ?? true;

  String? _selectedCategoryId;
  bool _showCompleted = true;
  DateFilter _dateFilter = DateFilter.all;
  String _searchQuery = '';
  String? get selectedCategoryId => _selectedCategoryId;
  bool get showCompleted => _showCompleted;
  DateFilter get dateFilter => _dateFilter;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // 검색 필터링 헬퍼 메서드
  bool _matchesSearchQuery(Todo todo) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    final titleMatch = todo.title.toLowerCase().contains(query);
    final descMatch = todo.description?.toLowerCase().contains(query) ?? false;
    return titleMatch || descMatch;
  }

  List<Todo> get todos {
    var items = _box.values.toList();

    if (_selectedCategoryId != null) {
      items = items.where((t) => t.categoryIds.contains(_selectedCategoryId)).toList();
    }

    if (!_showCompleted) {
      items = items.where((t) => !t.isCompleted).toList();
    }

    items.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    return items;
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  void setDateFilter(DateFilter filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  // 날짜 필터링 헬퍼 메서드
  bool _matchesDateFilter(Todo todo) {
    if (_dateFilter == DateFilter.all) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekLater = today.add(const Duration(days: 7));

    final dueDate = todo.dueDate;
    if (dueDate == null) {
      // 마감일이 없는 경우: "전체"에서만 표시
      return _dateFilter == DateFilter.all;
    }

    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    switch (_dateFilter) {
      case DateFilter.all:
        return true;
      case DateFilter.today:
        // 오늘 마감인 항목
        return dueDateOnly.isAtSameMomentAs(today);
      case DateFilter.upcoming:
        // 오늘 이후 7일 이내 마감 (오늘 포함)
        return dueDateOnly.isAfter(today.subtract(const Duration(days: 1))) &&
               dueDateOnly.isBefore(weekLater);
    }
  }

  // 다음 sortOrder 값 가져오기
  int _getNextSortOrder(String? parentId) {
    final siblings = parentId == null
        ? _box.values.where((t) => t.parentId == null)
        : _box.values.where((t) => t.parentId == parentId);
    if (siblings.isEmpty) return 0;
    return siblings.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  void addTodo({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    List<String>? categoryIds,
    DateTime? dueDate,
    DateTime? startDate,
    String? parentId,
    Recurrence recurrence = Recurrence.none,
    List<int>? recurrenceDays,
    bool notificationEnabled = true,
    List<int>? reminderOffsets,
    List<String>? tags,
    int? estimatedMinutes,
    int? actualMinutes,
  }) {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      categoryIds: categoryIds ?? ['personal'],
      createdAt: DateTime.now(),
      dueDate: dueDate,
      startDate: startDate,
      parentId: parentId,
      recurrence: recurrence,
      recurrenceDays: recurrenceDays,
      notificationEnabled: notificationEnabled,
      reminderOffsets: reminderOffsets,
      sortOrder: _getNextSortOrder(parentId),
      tags: tags,
      estimatedMinutes: estimatedMinutes,
      actualMinutes: actualMinutes,
    );
    _box.put(todo.id, todo);

    // 마감일이 있고 알림이 활성화되어 있으면 알림 스케줄링
    if (dueDate != null && notificationEnabled && _isGlobalNotificationEnabled) {
      _notificationService.scheduleTodoNotification(todo);
    }

    notifyListeners();
  }

  List<Todo> getChildTodos(String parentId) {
    return _box.values.where((t) => t.parentId == parentId).toList();
  }

  List<Todo> getRootTodos() {
    var items = _box.values
        .where((t) => t.parentId == null && !t.isArchived && t.deletedAt == null)
        .toList();

    if (_selectedCategoryId != null) {
      items = items.where((t) => t.categoryIds.contains(_selectedCategoryId)).toList();
    }

    if (!_showCompleted) {
      items = items.where((t) => !t.isCompleted).toList();
    }

    // 날짜 필터 적용
    items = items.where(_matchesDateFilter).toList();

    // 검색 필터 적용
    items = items.where(_matchesSearchQuery).toList();

    items.sort((a, b) {
      // 완료된 항목은 항상 아래로
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // 수동 정렬 순서 사용
      return a.sortOrder.compareTo(b.sortOrder);
    });

    return items;
  }

  // 할일 순서 변경
  void reorderTodo(int oldIndex, int newIndex) {
    final items = getRootTodos();

    // 완료되지 않은 항목만 재정렬 대상
    final incompleteTodos = items.where((t) => !t.isCompleted).toList();
    final completedTodos = items.where((t) => t.isCompleted).toList();

    if (oldIndex >= incompleteTodos.length || newIndex > incompleteTodos.length) {
      return; // 완료된 항목은 이동 불가
    }

    if (newIndex > oldIndex) newIndex--;

    final item = incompleteTodos.removeAt(oldIndex);
    incompleteTodos.insert(newIndex, item);

    // sortOrder 재할당
    for (int i = 0; i < incompleteTodos.length; i++) {
      incompleteTodos[i].sortOrder = i;
      incompleteTodos[i].save();
    }

    // 완료된 항목들은 미완료 항목들 뒤로
    for (int i = 0; i < completedTodos.length; i++) {
      completedTodos[i].sortOrder = incompleteTodos.length + i;
      completedTodos[i].save();
    }

    notifyListeners();
  }

  // 마감일별 섹션 그룹핑
  Map<String, List<Todo>> getGroupedTodos() {
    final items = getRootTodos();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = today.add(const Duration(days: 7));

    final Map<String, List<Todo>> grouped = {
      'overdue': [],    // 지연됨
      'today': [],      // 오늘
      'tomorrow': [],   // 내일
      'thisWeek': [],   // 이번 주
      'later': [],      // 나중에
      'noDueDate': [],  // 마감일 없음
      'completed': [],  // 완료됨
    };

    for (final todo in items) {
      if (todo.isCompleted) {
        grouped['completed']!.add(todo);
        continue;
      }

      final dueDate = todo.dueDate;
      if (dueDate == null) {
        grouped['noDueDate']!.add(todo);
        continue;
      }

      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

      if (dueDateOnly.isBefore(today)) {
        grouped['overdue']!.add(todo);
      } else if (dueDateOnly.isAtSameMomentAs(today)) {
        grouped['today']!.add(todo);
      } else if (dueDateOnly.isAtSameMomentAs(tomorrow)) {
        grouped['tomorrow']!.add(todo);
      } else if (dueDateOnly.isBefore(weekEnd)) {
        grouped['thisWeek']!.add(todo);
      } else {
        grouped['later']!.add(todo);
      }
    }

    return grouped;
  }

  void deleteWithChildren(String id) {
    final children = getChildTodos(id);
    for (final child in children) {
      deleteWithChildren(child.id);
    }
    _notificationService.cancelTodoNotification(id);
    _box.delete(id);
    notifyListeners();
  }

  void updateTodo({
    required String id,
    String? title,
    String? description,
    Priority? priority,
    List<String>? categoryIds,
    DateTime? dueDate,
    DateTime? startDate,
    Recurrence? recurrence,
    List<int>? recurrenceDays,
    bool? notificationEnabled,
    List<int>? reminderOffsets,
    List<String>? tags,
  }) {
    final todo = _box.get(id);
    if (todo != null) {
      if (title != null) todo.title = title;
      if (description != null) todo.description = description;
      if (priority != null) todo.priority = priority;
      if (categoryIds != null) todo.categoryIds = categoryIds;
      if (dueDate != null) todo.dueDate = dueDate;
      if (startDate != null) todo.startDate = startDate;
      if (recurrence != null) todo.recurrence = recurrence;
      if (recurrenceDays != null) todo.recurrenceDays = recurrenceDays;
      if (notificationEnabled != null) todo.notificationEnabled = notificationEnabled;
      if (reminderOffsets != null) todo.reminderOffsets = reminderOffsets;
      if (tags != null) todo.tags = tags;
      todo.save();

      // 마감일이 있고 알림이 활성화되어 있으면 알림 스케줄링
      if (todo.dueDate != null && todo.notificationEnabled && _isGlobalNotificationEnabled) {
        _notificationService.scheduleTodoNotification(todo);
      } else {
        _notificationService.cancelTodoNotification(id);
      }

      notifyListeners();
    }
  }

  void toggleComplete(String id) {
    final todo = _box.get(id);
    if (todo != null) {
      final wasCompleted = todo.isCompleted;
      todo.isCompleted = !todo.isCompleted;

      // 반복 할일의 경우 완료 이력 기록 (습관 트래커)
      if (!wasCompleted && todo.isCompleted && todo.recurrence != Recurrence.none) {
        final history = List<DateTime>.from(todo.completionHistory ?? []);
        history.add(DateTime.now());
        todo.completionHistory = history;
      }

      // 완료 상태로 변경될 때 식물 성장
      if (!wasCompleted && todo.isCompleted) {
        _forestProvider?.growPlant();
      }

      todo.save();

      // 완료되면 알림 취소, 미완료로 변경되면 다시 스케줄링
      if (todo.isCompleted) {
        _notificationService.cancelTodoNotification(id);
      } else if (todo.dueDate != null && todo.notificationEnabled && _isGlobalNotificationEnabled) {
        _notificationService.scheduleTodoNotification(todo);
      }

      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _notificationService.cancelTodoNotification(id);
    _box.delete(id);
    notifyListeners();
  }

  // 아카이브로 이동
  void archiveTodo(String id) {
    final todo = _box.get(id);
    if (todo != null) {
      todo.isArchived = true;
      todo.save();
      _notificationService.cancelTodoNotification(id);
      notifyListeners();
    }
  }

  // 아카이브에서 복원
  void unarchiveTodo(String id) {
    final todo = _box.get(id);
    if (todo != null) {
      todo.isArchived = false;
      todo.save();
      if (todo.dueDate != null && todo.notificationEnabled && _isGlobalNotificationEnabled) {
        _notificationService.scheduleTodoNotification(todo);
      }
      notifyListeners();
    }
  }

  // 아카이브 목록 가져오기
  List<Todo> getArchivedTodos() {
    return _box.values
        .where((t) => t.isArchived && t.deletedAt == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 휴지통으로 이동 (소프트 삭제)
  void softDeleteTodo(String id) {
    final todo = _box.get(id);
    if (todo != null) {
      todo.deletedAt = DateTime.now();
      todo.save();
      _notificationService.cancelTodoNotification(id);
      notifyListeners();
    }
  }

  // 휴지통에서 복원
  void restoreTodo(String id) {
    final todo = _box.get(id);
    if (todo != null) {
      todo.deletedAt = null;
      todo.save();
      if (todo.dueDate != null && todo.notificationEnabled && _isGlobalNotificationEnabled) {
        _notificationService.scheduleTodoNotification(todo);
      }
      notifyListeners();
    }
  }

  // 휴지통 목록 가져오기
  List<Todo> getTrashTodos() {
    return _box.values
        .where((t) => t.deletedAt != null)
        .toList()
      ..sort((a, b) => (b.deletedAt ?? DateTime.now()).compareTo(a.deletedAt ?? DateTime.now()));
  }

  // 휴지통 비우기 (30일 지난 항목 영구 삭제)
  void cleanupTrash() {
    final now = DateTime.now();
    final todosToDelete = _box.values.where((t) {
      if (t.deletedAt == null) return false;
      return now.difference(t.deletedAt!).inDays >= 30;
    }).toList();

    for (final todo in todosToDelete) {
      _box.delete(todo.id);
    }
    if (todosToDelete.isNotEmpty) {
      notifyListeners();
    }
  }

  // 휴지통 완전 비우기
  void emptyTrash() {
    final todosToDelete = _box.values.where((t) => t.deletedAt != null).toList();
    for (final todo in todosToDelete) {
      _box.delete(todo.id);
    }
    notifyListeners();
  }

  // 영구 삭제
  void permanentlyDeleteTodo(String id) {
    _box.delete(id);
    notifyListeners();
  }

  void deleteTodosByCategory(String categoryId) {
    final todosToDelete = _box.values.where((t) => t.categoryIds.contains(categoryId)).toList();
    for (final todo in todosToDelete) {
      _notificationService.cancelTodoNotification(todo.id);
      _box.delete(todo.id);
    }
    notifyListeners();
  }

  Todo? getTodo(String id) {
    return _box.get(id);
  }

  // 모든 태그 목록 가져오기 (중복 제거)
  List<String> getAllTags() {
    final tags = <String>{};
    for (final todo in _box.values) {
      if (todo.deletedAt == null) {
        tags.addAll(todo.tags);
      }
    }
    final tagList = tags.toList()..sort();
    return tagList;
  }

  // 특정 태그가 있는 할일 목록
  List<Todo> getTodosByTag(String tag) {
    return _box.values
        .where((t) => t.tags.contains(tag) && !t.isArchived && t.deletedAt == null)
        .toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });
  }

  // 할일에 태그 추가
  void addTagToTodo(String todoId, String tag) {
    final todo = _box.get(todoId);
    if (todo != null && !todo.tags.contains(tag)) {
      todo.tags = [...todo.tags, tag];
      todo.save();
      notifyListeners();
    }
  }

  // 할일에서 태그 제거
  void removeTagFromTodo(String todoId, String tag) {
    final todo = _box.get(todoId);
    if (todo != null) {
      todo.tags = todo.tags.where((t) => t != tag).toList();
      todo.save();
      notifyListeners();
    }
  }

  // 반복 할일 (습관) 목록 가져오기
  List<Todo> getHabits() {
    return _box.values
        .where((t) => t.recurrence != Recurrence.none)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 특정 날짜 범위의 완료 이력 조회
  Map<DateTime, List<Todo>> getCompletionsByDateRange(DateTime start, DateTime end) {
    final result = <DateTime, List<Todo>>{};
    final habits = getHabits();

    for (final habit in habits) {
      final history = habit.completionHistory ?? [];
      for (final date in history) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (dateOnly.isAfter(start.subtract(const Duration(days: 1))) &&
            dateOnly.isBefore(end.add(const Duration(days: 1)))) {
          result.putIfAbsent(dateOnly, () => []);
          if (!result[dateOnly]!.any((t) => t.id == habit.id)) {
            result[dateOnly]!.add(habit);
          }
        }
      }
    }

    return result;
  }

  // 특정 날짜의 할일 목록 가져오기 (캘린더용)
  List<Todo> getTodosByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _box.values.where((todo) {
      if (todo.parentId != null) return false; // 루트 할일만

      // 마감일이 해당 날짜인 경우
      if (todo.dueDate != null) {
        final dueOnly = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
        if (dueOnly.isAtSameMomentAs(dateOnly)) return true;
      }

      // 시작일이 해당 날짜인 경우
      if (todo.startDate != null) {
        final startOnly = DateTime(todo.startDate!.year, todo.startDate!.month, todo.startDate!.day);
        if (startOnly.isAtSameMomentAs(dateOnly)) return true;
      }

      return false;
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.priority.index.compareTo(a.priority.index);
      });
  }

  // 날짜 범위의 할일 이벤트 맵 가져오기 (캘린더 마커용)
  Map<DateTime, List<Todo>> getTodosForMonth(DateTime month) {
    final result = <DateTime, List<Todo>>{};
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (final todo in _box.values) {
      if (todo.parentId != null) continue;

      // 마감일 기준
      if (todo.dueDate != null) {
        final dueOnly = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
        if (dueOnly.isAfter(firstDay.subtract(const Duration(days: 1))) &&
            dueOnly.isBefore(lastDay.add(const Duration(days: 1)))) {
          result.putIfAbsent(dueOnly, () => []);
          result[dueOnly]!.add(todo);
        }
      }
    }

    return result;
  }
}
