import 'package:flutter_test/flutter_test.dart';
import 'package:todoodle/models/focus_session.dart';

void main() {
  group('FocusSession', () {
    group('생성', () {
      test('필수 필드로 생성된다', () {
        final session = FocusSession(
          id: 'test-id',
          type: FocusSessionType.work,
          startTime: DateTime(2025, 3, 1, 10, 0),
          plannedDuration: 1500, // 25분
        );

        expect(session.id, 'test-id');
        expect(session.type, FocusSessionType.work);
        expect(session.plannedDuration, 1500);
        expect(session.actualDuration, 0);
        expect(session.wasCompleted, false);
        expect(session.wasInterrupted, false);
        expect(session.todoId, isNull);
        expect(session.endTime, isNull);
      });

      test('todoId를 포함하여 생성할 수 있다', () {
        final session = FocusSession(
          id: 'test-id',
          todoId: 'todo-123',
          type: FocusSessionType.work,
          startTime: DateTime.now(),
          plannedDuration: 1500,
        );

        expect(session.todoId, 'todo-123');
      });
    });

    group('copyWith', () {
      test('endTime을 변경한다', () {
        final session = FocusSession(
          id: 'test-id',
          type: FocusSessionType.work,
          startTime: DateTime(2025, 3, 1, 10, 0),
          plannedDuration: 1500,
        );

        final endTime = DateTime(2025, 3, 1, 10, 25);
        final updated = session.copyWith(endTime: endTime);

        expect(updated.endTime, endTime);
        expect(updated.id, session.id);
      });

      test('wasCompleted를 true로 변경한다', () {
        final session = FocusSession(
          id: 'test-id',
          type: FocusSessionType.work,
          startTime: DateTime.now(),
          plannedDuration: 1500,
        );

        final updated = session.copyWith(
          wasCompleted: true,
          actualDuration: 1500,
        );

        expect(updated.wasCompleted, true);
        expect(updated.actualDuration, 1500);
      });

      test('wasInterrupted를 true로 변경한다', () {
        final session = FocusSession(
          id: 'test-id',
          type: FocusSessionType.work,
          startTime: DateTime.now(),
          plannedDuration: 1500,
        );

        final updated = session.copyWith(
          wasInterrupted: true,
          actualDuration: 600, // 10분만 집중
        );

        expect(updated.wasInterrupted, true);
        expect(updated.actualDuration, 600);
      });
    });

    group('FocusSessionType enum', () {
      test('모든 세션 타입이 존재한다', () {
        expect(FocusSessionType.values.length, 3);
        expect(FocusSessionType.values, contains(FocusSessionType.work));
        expect(FocusSessionType.values, contains(FocusSessionType.shortBreak));
        expect(FocusSessionType.values, contains(FocusSessionType.longBreak));
      });
    });
  });
}
