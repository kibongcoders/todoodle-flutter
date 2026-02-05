import 'package:hive/hive.dart';

import 'todo.dart';

part 'template.g.dart';

@HiveType(typeId: 8)
class TodoTemplate extends HiveObject {
  TodoTemplate({
    required this.id,
    required this.name,
    this.description,
    this.emoji = '📋',
    required this.items,
    required this.createdAt,
    this.useCount = 0,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String name; // 템플릿 이름

  @HiveField(2)
  String? description; // 템플릿 설명

  @HiveField(3)
  String emoji; // 템플릿 아이콘

  @HiveField(4)
  List<TemplateItem> items; // 할일 목록

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  int useCount; // 사용 횟수

  TodoTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    List<TemplateItem>? items,
    DateTime? createdAt,
    int? useCount,
  }) {
    return TodoTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      useCount: useCount ?? this.useCount,
    );
  }
}

@HiveType(typeId: 9)
class TemplateItem extends HiveObject {
  TemplateItem({
    required this.title,
    this.description,
    this.priority = Priority.medium,
    List<String>? categoryIds,
    this.estimatedMinutes,
    List<String>? tags,
    this.dueDayOffset,
  })  : categoryIds = categoryIds ?? ['personal'],
        tags = tags ?? [];

  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  Priority priority;

  @HiveField(3)
  List<String> categoryIds;

  @HiveField(4)
  int? estimatedMinutes; // 예상 소요 시간 (분)

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  int? dueDayOffset; // 생성일 기준 마감일 오프셋 (일 단위)

  TemplateItem copyWith({
    String? title,
    String? description,
    Priority? priority,
    List<String>? categoryIds,
    int? estimatedMinutes,
    List<String>? tags,
    int? dueDayOffset,
  }) {
    return TemplateItem(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      categoryIds: categoryIds ?? this.categoryIds,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      tags: tags ?? this.tags,
      dueDayOffset: dueDayOffset ?? this.dueDayOffset,
    );
  }
}
