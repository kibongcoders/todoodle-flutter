import 'package:flutter_test/flutter_test.dart';
import 'package:todorest/models/todo.dart';

void main() {
  group('Todo', () {
    group('생성', () {
      test('필수 필드로 생성된다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트 할일',
          createdAt: DateTime.now(),
        );

        expect(todo.id, 'test-1');
        expect(todo.title, '테스트 할일');
        expect(todo.isCompleted, false);
        expect(todo.priority, Priority.medium);
        expect(todo.recurrence, Recurrence.none);
      });

      test('기본 카테고리는 personal이다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        expect(todo.categoryIds, contains('personal'));
      });

      test('기본 태그는 빈 리스트다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        expect(todo.tags, isEmpty);
      });
    });

    group('copyWith', () {
      test('title만 변경한다', () {
        final original = Todo(
          id: 'test-1',
          title: '원본',
          createdAt: DateTime.now(),
          priority: Priority.high,
        );

        final copied = original.copyWith(title: '수정됨');

        expect(copied.id, original.id);
        expect(copied.title, '수정됨');
        expect(copied.priority, Priority.high);
      });

      test('isCompleted를 변경한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        final completed = todo.copyWith(isCompleted: true);

        expect(completed.isCompleted, true);
        expect(todo.isCompleted, false); // 원본 불변
      });

      test('priority를 변경한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        final urgent = todo.copyWith(priority: Priority.veryHigh);

        expect(urgent.priority, Priority.veryHigh);
      });
    });

    group('currentStreak', () {
      test('완료 이력이 없으면 0을 반환한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        expect(todo.currentStreak, 0);
      });

      test('오늘 완료하면 1을 반환한다', () {
        final today = DateTime.now();
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today,
          completionHistory: [today],
        );

        expect(todo.currentStreak, 1);
      });

      test('연속 3일 완료하면 3을 반환한다', () {
        final today = DateTime.now();
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today.subtract(const Duration(days: 5)),
          completionHistory: [
            today.subtract(const Duration(days: 2)),
            today.subtract(const Duration(days: 1)),
            today,
          ],
        );

        expect(todo.currentStreak, 3);
      });

      test('어제까지만 완료하면 어제부터 카운트한다', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today.subtract(const Duration(days: 5)),
          completionHistory: [
            yesterday.subtract(const Duration(days: 1)),
            yesterday,
          ],
        );

        expect(todo.currentStreak, 2);
      });

      test('연속이 끊기면 끊긴 이후부터 카운트한다', () {
        final today = DateTime.now();
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today.subtract(const Duration(days: 10)),
          completionHistory: [
            today.subtract(const Duration(days: 5)), // 끊김
            today.subtract(const Duration(days: 1)),
            today,
          ],
        );

        expect(todo.currentStreak, 2);
      });
    });

    group('longestStreak', () {
      test('완료 이력이 없으면 0을 반환한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        expect(todo.longestStreak, 0);
      });

      test('단일 완료는 1을 반환한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
          completionHistory: [DateTime.now()],
        );

        expect(todo.longestStreak, 1);
      });

      test('과거의 긴 연속을 찾는다', () {
        final today = DateTime.now();
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today.subtract(const Duration(days: 20)),
          completionHistory: [
            // 과거 5일 연속
            today.subtract(const Duration(days: 15)),
            today.subtract(const Duration(days: 14)),
            today.subtract(const Duration(days: 13)),
            today.subtract(const Duration(days: 12)),
            today.subtract(const Duration(days: 11)),
            // 끊김 후 2일 연속
            today.subtract(const Duration(days: 1)),
            today,
          ],
        );

        expect(todo.longestStreak, 5);
      });
    });

    group('wasCompletedOn', () {
      test('완료 이력이 없으면 false를 반환한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        expect(todo.wasCompletedOn(DateTime.now()), false);
      });

      test('해당 날짜에 완료했으면 true를 반환한다', () {
        final today = DateTime.now();
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today,
          completionHistory: [today],
        );

        expect(todo.wasCompletedOn(today), true);
      });

      test('다른 날짜면 false를 반환한다', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today,
          completionHistory: [today],
        );

        expect(todo.wasCompletedOn(yesterday), false);
      });

      test('시간이 달라도 같은 날이면 true를 반환한다', () {
        final date = DateTime(2024, 6, 15, 10, 30);
        final sameDateDifferentTime = DateTime(2024, 6, 15, 18, 0);
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: date,
          completionHistory: [date],
        );

        expect(todo.wasCompletedOn(sameDateDifferentTime), true);
      });
    });

    group('totalCompletions', () {
      test('완료 이력이 없으면 0을 반환한다', () {
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: DateTime.now(),
        );

        expect(todo.totalCompletions, 0);
      });

      test('완료 횟수를 정확히 반환한다', () {
        final today = DateTime.now();
        final todo = Todo(
          id: 'test-1',
          title: '테스트',
          createdAt: today,
          completionHistory: [
            today.subtract(const Duration(days: 2)),
            today.subtract(const Duration(days: 1)),
            today,
          ],
        );

        expect(todo.totalCompletions, 3);
      });
    });

    group('Priority enum', () {
      test('모든 우선순위 값이 존재한다', () {
        expect(Priority.values.length, 5);
        expect(Priority.values, contains(Priority.veryLow));
        expect(Priority.values, contains(Priority.low));
        expect(Priority.values, contains(Priority.medium));
        expect(Priority.values, contains(Priority.high));
        expect(Priority.values, contains(Priority.veryHigh));
      });
    });

    group('Recurrence enum', () {
      test('모든 반복 타입이 존재한다', () {
        expect(Recurrence.values.length, 5);
        expect(Recurrence.values, contains(Recurrence.none));
        expect(Recurrence.values, contains(Recurrence.daily));
        expect(Recurrence.values, contains(Recurrence.weekly));
        expect(Recurrence.values, contains(Recurrence.monthly));
        expect(Recurrence.values, contains(Recurrence.custom));
      });
    });
  });
}
