import 'package:flutter_test/flutter_test.dart';
import 'package:todoodle/services/natural_language_parser.dart';

void main() {
  late NaturalLanguageParser parser;

  setUp(() {
    parser = NaturalLanguageParser();
  });

  group('NaturalLanguageParser', () {
    group('태그 추출', () {
      test('단일 태그를 추출한다', () {
        final result = parser.parse('회의 준비 #업무');

        expect(result.title, '회의 준비');
        expect(result.tags, ['업무']);
      });

      test('여러 태그를 추출한다', () {
        final result = parser.parse('보고서 작성 #업무 #중요');

        expect(result.title, '보고서 작성');
        expect(result.tags, containsAll(['업무', '중요']));
      });

      test('태그가 없으면 빈 리스트를 반환한다', () {
        final result = parser.parse('회의 준비');

        expect(result.tags, isEmpty);
      });
    });

    group('우선순위 추출', () {
      test('!! 를 veryHigh로 변환한다', () {
        final result = parser.parse('보고서 제출!! ');

        expect(result.priority, 4); // veryHigh
      });

      test('[긴급] 태그를 veryHigh로 변환한다', () {
        final result = parser.parse('[긴급] 회의 참석');

        expect(result.priority, 4);
      });

      test('단일 ! 를 high로 변환한다', () {
        final result = parser.parse('과제 제출!');

        expect(result.priority, 3); // high
      });

      test('우선순위 키워드가 없으면 null을 반환한다', () {
        final result = parser.parse('회의 준비');

        expect(result.priority, isNull);
      });
    });

    group('날짜 추출', () {
      test('N일 후 패턴을 파싱한다', () {
        final result = parser.parse('3일 후 보고서 제출');
        final expected = DateTime.now().add(const Duration(days: 3));

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.year, expected.year);
        expect(result.dueDate!.month, expected.month);
        expect(result.dueDate!.day, expected.day);
      });

      test('YYYY-MM-DD 패턴을 파싱한다', () {
        final result = parser.parse('2025-06-15 프로젝트 마감');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.year, 2025);
        expect(result.dueDate!.month, 6);
        expect(result.dueDate!.day, 15);
      });

      test('MM/DD 패턴을 파싱한다', () {
        final result = parser.parse('3/15 회의');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.month, 3);
        expect(result.dueDate!.day, 15);
      });
    });

    group('시간 추출', () {
      test('오후 3시를 15시로 변환한다', () {
        final result = parser.parse('2025-03-01 오후 3시 회의');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 15);
        expect(result.dueDate!.minute, 0);
      });

      test('오전 10시 30분을 파싱한다', () {
        final result = parser.parse('2025-03-01 오전 10시 30분 미팅');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 10);
        expect(result.dueDate!.minute, 30);
      });

      test('14:30 형식을 파싱한다', () {
        final result = parser.parse('2025-03-01 14:30 발표');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 14);
        expect(result.dueDate!.minute, 30);
      });

      test('정오를 12시로 변환한다', () {
        final result = parser.parse('2025-03-01 정오 점심');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 12);
        expect(result.dueDate!.minute, 0);
      });

      test('날짜 없이 시간만 있으면 오늘/내일 날짜를 사용한다', () {
        final result = parser.parse('오후 5시 퇴근');

        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 17);
      });
    });

    group('복합 파싱', () {
      test('날짜, 시간, 태그를 모두 추출한다', () {
        final result = parser.parse('2025-03-01 오후 2시 보고서 제출 #업무');

        expect(result.title.trim(), '보고서 제출');
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 14);
        expect(result.tags, contains('업무'));
      });

      test('제목만 있는 경우 정상 처리한다', () {
        final result = parser.parse('장보기');

        expect(result.title, '장보기');
        expect(result.dueDate, isNull);
        expect(result.priority, isNull);
        expect(result.tags, isEmpty);
      });

      test('hasDate는 날짜가 있을 때 true를 반환한다', () {
        final withDate = parser.parse('2025-03-01 회의');
        final withoutDate = parser.parse('장보기');

        expect(withDate.hasDate, isTrue);
        expect(withoutDate.hasDate, isFalse);
      });

      test('hasPriority는 우선순위가 있을 때 true를 반환한다', () {
        final withPriority = parser.parse('보고서!!');
        final withoutPriority = parser.parse('장보기');

        expect(withPriority.hasPriority, isTrue);
        expect(withoutPriority.hasPriority, isFalse);
      });

      test('hasTags는 태그가 있을 때 true를 반환한다', () {
        final withTags = parser.parse('회의 #업무');
        final withoutTags = parser.parse('장보기');

        expect(withTags.hasTags, isTrue);
        expect(withoutTags.hasTags, isFalse);
      });
    });
  });
}
