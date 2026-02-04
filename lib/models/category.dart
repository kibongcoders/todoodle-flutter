import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class TodoCategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  bool isDefault;

  TodoCategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    this.isDefault = false,
  });

  TodoCategoryModel copyWith({
    String? id,
    String? name,
    String? emoji,
    bool? isDefault,
  }) {
    return TodoCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static List<TodoCategoryModel> get defaultCategories => [
        TodoCategoryModel(id: 'work', name: '업무', emoji: '💼', isDefault: true),
        TodoCategoryModel(id: 'personal', name: '개인', emoji: '🏠', isDefault: true),
        TodoCategoryModel(id: 'shopping', name: '쇼핑', emoji: '🛒', isDefault: true),
        TodoCategoryModel(id: 'health', name: '건강', emoji: '💪', isDefault: true),
        TodoCategoryModel(id: 'study', name: '공부', emoji: '📚', isDefault: true),
        TodoCategoryModel(id: 'finance', name: '금융', emoji: '💰', isDefault: true),
        TodoCategoryModel(id: 'travel', name: '여행', emoji: '✈️', isDefault: true),
        TodoCategoryModel(id: 'food', name: '음식', emoji: '🍽️', isDefault: true),
        TodoCategoryModel(id: 'entertainment', name: '오락', emoji: '🎬', isDefault: true),
        TodoCategoryModel(id: 'family', name: '가족', emoji: '👨‍👩‍👧', isDefault: true),
        TodoCategoryModel(id: 'friends', name: '친구', emoji: '👫', isDefault: true),
        TodoCategoryModel(id: 'hobby', name: '취미', emoji: '🎨', isDefault: true),
        TodoCategoryModel(id: 'exercise', name: '운동', emoji: '🏃', isDefault: true),
        TodoCategoryModel(id: 'meeting', name: '미팅', emoji: '🤝', isDefault: true),
        TodoCategoryModel(id: 'project', name: '프로젝트', emoji: '📋', isDefault: true),
        TodoCategoryModel(id: 'deadline', name: '마감', emoji: '⏰', isDefault: true),
        TodoCategoryModel(id: 'appointment', name: '약속', emoji: '📅', isDefault: true),
        TodoCategoryModel(id: 'reminder', name: '알림', emoji: '🔔', isDefault: true),
        TodoCategoryModel(id: 'goal', name: '목표', emoji: '🎯', isDefault: true),
        TodoCategoryModel(id: 'other', name: '기타', emoji: '📌', isDefault: true),
      ];
}
