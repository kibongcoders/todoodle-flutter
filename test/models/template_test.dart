import 'package:flutter_test/flutter_test.dart';
import 'package:todorest/models/template.dart';
import 'package:todorest/models/todo.dart';

void main() {
  group('TodoTemplate', () {
    group('생성', () {
      test('필수 필드로 생성된다', () {
        final template = TodoTemplate(
          id: 'template-1',
          name: '아침 루틴',
          items: [],
          createdAt: DateTime(2025, 3, 1),
        );

        expect(template.id, 'template-1');
        expect(template.name, '아침 루틴');
        expect(template.emoji, '📋'); // 기본값
        expect(template.useCount, 0);
        expect(template.description, isNull);
      });

      test('모든 필드를 포함하여 생성할 수 있다', () {
        final items = [
          TemplateItem(title: '물 마시기'),
          TemplateItem(title: '스트레칭'),
        ];

        final template = TodoTemplate(
          id: 'template-1',
          name: '아침 루틴',
          description: '건강한 아침 시작',
          emoji: '🌅',
          items: items,
          createdAt: DateTime(2025, 3, 1),
          useCount: 5,
        );

        expect(template.description, '건강한 아침 시작');
        expect(template.emoji, '🌅');
        expect(template.items.length, 2);
        expect(template.useCount, 5);
      });
    });

    group('copyWith', () {
      test('name만 변경한다', () {
        final template = TodoTemplate(
          id: 'template-1',
          name: '아침 루틴',
          items: [],
          createdAt: DateTime(2025, 3, 1),
        );

        final updated = template.copyWith(name: '저녁 루틴');

        expect(updated.name, '저녁 루틴');
        expect(updated.id, template.id);
      });

      test('useCount를 증가시킨다', () {
        final template = TodoTemplate(
          id: 'template-1',
          name: '아침 루틴',
          items: [],
          createdAt: DateTime(2025, 3, 1),
          useCount: 3,
        );

        final updated = template.copyWith(useCount: template.useCount + 1);

        expect(updated.useCount, 4);
      });
    });
  });

  group('TemplateItem', () {
    group('생성', () {
      test('필수 필드로 생성된다', () {
        final item = TemplateItem(title: '물 마시기');

        expect(item.title, '물 마시기');
        expect(item.priority, Priority.medium); // 기본값
        expect(item.categoryIds, ['personal']); // 기본값
        expect(item.tags, isEmpty);
        expect(item.description, isNull);
        expect(item.estimatedMinutes, isNull);
        expect(item.dueDayOffset, isNull);
      });

      test('모든 필드를 포함하여 생성할 수 있다', () {
        final item = TemplateItem(
          title: '보고서 작성',
          description: '주간 보고서 작성',
          priority: Priority.high,
          categoryIds: ['work'],
          estimatedMinutes: 60,
          tags: ['업무', '문서'],
          dueDayOffset: 7,
        );

        expect(item.description, '주간 보고서 작성');
        expect(item.priority, Priority.high);
        expect(item.categoryIds, ['work']);
        expect(item.estimatedMinutes, 60);
        expect(item.tags, containsAll(['업무', '문서']));
        expect(item.dueDayOffset, 7);
      });
    });

    group('copyWith', () {
      test('priority를 변경한다', () {
        final item = TemplateItem(title: '할일');

        final updated = item.copyWith(priority: Priority.veryHigh);

        expect(updated.priority, Priority.veryHigh);
        expect(updated.title, item.title);
      });

      test('tags를 변경한다', () {
        final item = TemplateItem(title: '할일', tags: ['태그1']);

        final updated = item.copyWith(tags: ['태그1', '태그2', '태그3']);

        expect(updated.tags.length, 3);
        expect(updated.tags, contains('태그3'));
      });

      test('dueDayOffset을 설정한다', () {
        final item = TemplateItem(title: '마감 있는 할일');

        final updated = item.copyWith(dueDayOffset: 3);

        expect(updated.dueDayOffset, 3);
      });
    });
  });
}
