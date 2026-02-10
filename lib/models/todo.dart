import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  veryLow,   // 여유롭게
  @HiveField(1)
  low,       // 천천히
  @HiveField(2)
  medium,    // 보통
  @HiveField(3)
  high,      // 서두르자
  @HiveField(4)
  veryHigh,  // 비상!
}

@HiveType(typeId: 2)
enum Recurrence {
  @HiveField(0)
  none,      // 반복 없음
  @HiveField(1)
  daily,     // 매일
  @HiveField(2)
  weekly,    // 매주
  @HiveField(3)
  monthly,   // 매월
  @HiveField(4)
  custom,    // 특정 요일 (recurrenceDays와 함께 사용)
}

@HiveType(typeId: 0)
class Todo extends HiveObject {
  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = Priority.medium,
    List<String>? categoryIds,
    required this.createdAt,
    this.dueDate,
    this.startDate,
    this.parentId,
    this.recurrence = Recurrence.none,
    this.recurrenceDays,
    this.notificationEnabled = true,
    this.reminderOffsets,
    this.completionHistory,
    this.sortOrder = 0,
    this.isArchived = false,
    this.deletedAt,
    List<String>? tags,
    this.estimatedMinutes,
    this.actualMinutes,
  })  : categoryIds = categoryIds ?? ['personal'],
        tags = tags ?? [];

  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  Priority priority;

  @HiveField(5)
  List<String> categoryIds;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? dueDate;

  @HiveField(8)
  DateTime? startDate;

  @HiveField(9)
  String? parentId;

  @HiveField(10)
  Recurrence recurrence;

  @HiveField(11)
  List<int>? recurrenceDays; // 0=월, 1=화, 2=수, 3=목, 4=금, 5=토, 6=일

  @HiveField(12)
  bool notificationEnabled;

  @HiveField(13)
  List<int>? reminderOffsets; // 사전 알림 (분 단위): [10, 30, 60, 1440] = 10분, 30분, 1시간, 1일 전

  @HiveField(14)
  List<DateTime>? completionHistory; // 완료 이력 (습관 트래커용)

  @HiveField(15, defaultValue: 0)
  int sortOrder; // 수동 정렬 순서

  @HiveField(16, defaultValue: false)
  bool isArchived; // 아카이브 여부

  @HiveField(17)
  DateTime? deletedAt; // 삭제 시간 (휴지통용)

  @HiveField(18)
  List<String> tags; // 태그 목록

  @HiveField(19)
  int? estimatedMinutes; // 예상 소요 시간 (분)

  @HiveField(20)
  int? actualMinutes; // 실제 소요 시간 (분)

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    List<String>? categoryIds,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? startDate,
    String? parentId,
    Recurrence? recurrence,
    List<int>? recurrenceDays,
    bool? notificationEnabled,
    List<int>? reminderOffsets,
    List<DateTime>? completionHistory,
    int? sortOrder,
    bool? isArchived,
    DateTime? deletedAt,
    List<String>? tags,
    int? estimatedMinutes,
    int? actualMinutes,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      categoryIds: categoryIds ?? this.categoryIds,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      parentId: parentId ?? this.parentId,
      recurrence: recurrence ?? this.recurrence,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      completionHistory: completionHistory ?? this.completionHistory,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
    );
  }

  // 연속 달성 일수 계산
  int get currentStreak {
    if (completionHistory == null || completionHistory!.isEmpty) return 0;

    final sortedHistory = List<DateTime>.from(completionHistory!)
      ..sort((a, b) => b.compareTo(a)); // 최신순 정렬

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime? expectedDate = todayOnly;

    for (final date in sortedHistory) {
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly.isAtSameMomentAs(expectedDate!)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (dateOnly.isBefore(expectedDate)) {
        // 오늘이 아직 완료 안 됐으면 어제부터 체크
        if (streak == 0 && dateOnly.isAtSameMomentAs(todayOnly.subtract(const Duration(days: 1)))) {
          streak++;
          expectedDate = dateOnly.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  // 최장 연속 달성 일수 계산
  int get longestStreak {
    if (completionHistory == null || completionHistory!.isEmpty) return 0;

    final sortedHistory = List<DateTime>.from(completionHistory!)
      ..sort((a, b) => a.compareTo(b)); // 오래된 순 정렬

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedHistory.length; i++) {
      final prevDate = DateTime(
        sortedHistory[i - 1].year,
        sortedHistory[i - 1].month,
        sortedHistory[i - 1].day,
      );
      final currDate = DateTime(
        sortedHistory[i].year,
        sortedHistory[i].month,
        sortedHistory[i].day,
      );

      final diff = currDate.difference(prevDate).inDays;

      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
      // diff == 0 이면 같은 날 중복 완료 - 무시
    }

    return maxStreak;
  }

  // 특정 날짜에 완료했는지 확인
  bool wasCompletedOn(DateTime date) {
    if (completionHistory == null) return false;
    final dateOnly = DateTime(date.year, date.month, date.day);
    return completionHistory!.any((d) {
      final dOnly = DateTime(d.year, d.month, d.day);
      return dOnly.isAtSameMomentAs(dateOnly);
    });
  }

  // 총 완료 횟수
  int get totalCompletions => completionHistory?.length ?? 0;
}
