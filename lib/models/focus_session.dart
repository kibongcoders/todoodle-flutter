import 'package:hive/hive.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 6)
enum FocusSessionType {
  @HiveField(0)
  work,     // 집중 시간
  @HiveField(1)
  shortBreak,  // 짧은 휴식
  @HiveField(2)
  longBreak,   // 긴 휴식
}

@HiveType(typeId: 7)
class FocusSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? todoId; // 관련 할일 (선택적)

  @HiveField(2)
  final FocusSessionType type;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  final int plannedDuration; // 계획된 시간 (초)

  @HiveField(6)
  int actualDuration; // 실제 집중 시간 (초)

  @HiveField(7)
  bool wasCompleted; // 정상 완료 여부

  @HiveField(8)
  bool wasInterrupted; // 중단 여부

  FocusSession({
    required this.id,
    this.todoId,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration = 0,
    this.wasCompleted = false,
    this.wasInterrupted = false,
  });

  FocusSession copyWith({
    String? id,
    String? todoId,
    FocusSessionType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDuration,
    int? actualDuration,
    bool? wasCompleted,
    bool? wasInterrupted,
  }) {
    return FocusSession(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      wasInterrupted: wasInterrupted ?? this.wasInterrupted,
    );
  }
}
