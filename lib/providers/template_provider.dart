import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/template.dart';
import '../models/todo.dart';

class TemplateProvider extends ChangeNotifier {
  static const _boxName = 'templates';

  late Box<TodoTemplate> _box;
  final _uuid = const Uuid();

  List<TodoTemplate> get templates {
    return _box.values.toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
  }

  Future<void> init() async {
    _box = await Hive.openBox<TodoTemplate>(_boxName);
  }

  Future<void> addTemplate({
    required String name,
    String? description,
    String emoji = '📋',
    required List<TemplateItem> items,
  }) async {
    final template = TodoTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      emoji: emoji,
      items: items,
      createdAt: DateTime.now(),
    );
    await _box.put(template.id, template);
    notifyListeners();
  }

  Future<void> updateTemplate({
    required String id,
    String? name,
    String? description,
    String? emoji,
    List<TemplateItem>? items,
  }) async {
    final template = _box.get(id);
    if (template != null) {
      if (name != null) template.name = name;
      if (description != null) template.description = description;
      if (emoji != null) template.emoji = emoji;
      if (items != null) template.items = items;
      await template.save();
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  TodoTemplate? getTemplate(String id) => _box.get(id);

  // 템플릿 사용 시 useCount 증가
  Future<void> incrementUseCount(String id) async {
    final template = _box.get(id);
    if (template != null) {
      template.useCount++;
      await template.save();
      notifyListeners();
    }
  }

  // 템플릿으로부터 할일 생성 데이터 반환
  List<Map<String, dynamic>> getTodosFromTemplate(String templateId) {
    final template = _box.get(templateId);
    if (template == null) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return template.items.map((item) {
      return {
        'title': item.title,
        'description': item.description,
        'priority': item.priority,
        'categoryIds': item.categoryIds,
        'estimatedMinutes': item.estimatedMinutes,
        'tags': item.tags,
        'dueDate': item.dueDayOffset != null
            ? today.add(Duration(days: item.dueDayOffset!))
            : null,
      };
    }).toList();
  }

  // 현재 할일들로부터 템플릿 생성
  Future<void> createTemplateFromTodos({
    required String name,
    String? description,
    String emoji = '📋',
    required List<Todo> todos,
  }) async {
    final items = todos.map((todo) {
      return TemplateItem(
        title: todo.title,
        description: todo.description,
        priority: todo.priority,
        categoryIds: todo.categoryIds,
        estimatedMinutes: todo.estimatedMinutes,
        tags: todo.tags,
      );
    }).toList();

    await addTemplate(
      name: name,
      description: description,
      emoji: emoji,
      items: items,
    );
  }
}
