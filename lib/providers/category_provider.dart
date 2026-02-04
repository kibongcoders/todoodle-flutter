import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  static const String _boxName = 'categories';
  late Box<TodoCategoryModel> _box;
  final _uuid = const Uuid();

  List<TodoCategoryModel> _categories = [];
  List<TodoCategoryModel> get categories => _categories;

  TodoCategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    _box = await Hive.openBox<TodoCategoryModel>(_boxName);

    if (_box.isEmpty) {
      for (final category in TodoCategoryModel.defaultCategories) {
        await _box.put(category.id, category);
      }
    }

    _loadCategories();
  }

  void _loadCategories() {
    _categories = _box.values.toList();
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required String emoji,
  }) async {
    final category = TodoCategoryModel(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      isDefault: false,
    );

    await _box.put(category.id, category);
    _loadCategories();
  }

  Future<void> updateCategory({
    required String id,
    String? name,
    String? emoji,
  }) async {
    final category = _box.get(id);
    if (category != null) {
      category.name = name ?? category.name;
      category.emoji = emoji ?? category.emoji;
      await category.save();
      _loadCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    // "기타" 카테고리는 삭제 불가 (삭제된 카테고리의 할 일이 이동할 곳)
    if (id == 'other') return;

    final category = _box.get(id);
    if (category != null) {
      await _box.delete(id);
      _loadCategories();
    }
  }

  bool canDelete(String id) {
    // "기타" 카테고리만 삭제 불가
    return id != 'other';
  }
}
