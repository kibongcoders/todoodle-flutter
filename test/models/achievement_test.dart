import 'package:flutter_test/flutter_test.dart';
import 'package:todoodle/models/achievement.dart';

void main() {
  group('Achievement', () {
    group('isUnlocked', () {
      test('unlockedAt이 null이면 false 반환', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.firstTodo,
          unlockedAt: null,
        );

        expect(achievement.isUnlocked, false);
      });

      test('unlockedAt이 설정되면 true 반환', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.firstTodo,
          unlockedAt: DateTime.now(),
        );

        expect(achievement.isUnlocked, true);
      });
    });

    group('progressRatio', () {
      test('진행도가 0이면 0.0 반환', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.complete10,
          currentProgress: 0,
          targetProgress: 10,
        );

        expect(achievement.progressRatio, 0.0);
      });

      test('진행도가 절반이면 0.5 반환', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.complete10,
          currentProgress: 5,
          targetProgress: 10,
        );

        expect(achievement.progressRatio, 0.5);
      });

      test('진행도가 목표와 같으면 1.0 반환', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.complete10,
          currentProgress: 10,
          targetProgress: 10,
        );

        expect(achievement.progressRatio, 1.0);
      });

      test('진행도가 목표를 초과해도 1.0으로 클램프', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.complete10,
          currentProgress: 15,
          targetProgress: 10,
        );

        expect(achievement.progressRatio, 1.0);
      });

      test('목표가 0이면 0.0 반환 (0으로 나누기 방지)', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.firstTodo,
          currentProgress: 5,
          targetProgress: 0,
        );

        expect(achievement.progressRatio, 0.0);
      });
    });

    group('기본값', () {
      test('currentProgress 기본값은 0', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.firstTodo,
        );

        expect(achievement.currentProgress, 0);
      });

      test('targetProgress 기본값은 1', () {
        final achievement = Achievement(
          id: 'test',
          type: AchievementType.firstTodo,
        );

        expect(achievement.targetProgress, 1);
      });
    });
  });

  group('AchievementMeta', () {
    group('getMeta', () {
      test('모든 AchievementType에 대해 메타데이터 존재', () {
        for (final type in AchievementType.values) {
          final meta = AchievementMeta.getMeta(type);
          expect(meta, isNotNull);
          expect(meta.type, type);
          expect(meta.name, isNotEmpty);
          expect(meta.description, isNotEmpty);
          expect(meta.icon, isNotEmpty);
          expect(meta.target, greaterThan(0));
        }
      });

      test('firstTodo 메타데이터 검증', () {
        final meta = AchievementMeta.getMeta(AchievementType.firstTodo);

        expect(meta.name, '첫 발걸음');
        expect(meta.description, '첫 번째 할일을 완료했습니다');
        expect(meta.icon, '🎯');
        expect(meta.target, 1);
      });

      test('streak7 메타데이터 검증', () {
        final meta = AchievementMeta.getMeta(AchievementType.streak7);

        expect(meta.name, '일주일 챔피언');
        expect(meta.description, '7일 연속 할일을 완료했습니다');
        expect(meta.icon, '🏆');
        expect(meta.target, 7);
      });

      test('complete100 메타데이터 검증', () {
        final meta = AchievementMeta.getMeta(AchievementType.complete100);

        expect(meta.name, '백전백승');
        expect(meta.target, 100);
      });

      test('focusHour 메타데이터 검증', () {
        final meta = AchievementMeta.getMeta(AchievementType.focusHour);

        expect(meta.name, '집중력 훈련');
        expect(meta.target, 60); // 60분
      });

      test('focusDay 메타데이터 검증', () {
        final meta = AchievementMeta.getMeta(AchievementType.focusDay);

        expect(meta.name, '몰입의 하루');
        expect(meta.target, 240); // 4시간 = 240분
      });
    });

    group('all map', () {
      test('AchievementMeta.all에 모든 타입 포함', () {
        expect(
          AchievementMeta.all.length,
          AchievementType.values.length,
        );
      });

      test('모든 메타데이터의 type이 키와 일치', () {
        for (final entry in AchievementMeta.all.entries) {
          expect(entry.value.type, entry.key);
        }
      });
    });
  });

  group('AchievementType', () {
    test('총 15개의 업적 타입 존재', () {
      expect(AchievementType.values.length, 15);
    });

    test('완료 마일스톤 타입 존재', () {
      expect(AchievementType.values, contains(AchievementType.firstTodo));
      expect(AchievementType.values, contains(AchievementType.complete10));
      expect(AchievementType.values, contains(AchievementType.complete50));
      expect(AchievementType.values, contains(AchievementType.complete100));
      expect(AchievementType.values, contains(AchievementType.complete500));
    });

    test('스트릭 타입 존재', () {
      expect(AchievementType.values, contains(AchievementType.streak3));
      expect(AchievementType.values, contains(AchievementType.streak7));
      expect(AchievementType.values, contains(AchievementType.streak30));
    });

    test('숲 성장 타입 존재', () {
      expect(AchievementType.values, contains(AchievementType.plantGrown));
      expect(AchievementType.values, contains(AchievementType.forest10));
    });

    test('집중 모드 타입 존재', () {
      expect(AchievementType.values, contains(AchievementType.focusHour));
      expect(AchievementType.values, contains(AchievementType.focusDay));
    });

    test('특별 타입 존재', () {
      expect(AchievementType.values, contains(AchievementType.earlyBird));
      expect(AchievementType.values, contains(AchievementType.nightOwl));
      expect(AchievementType.values, contains(AchievementType.perfectDay));
    });
  });
}
