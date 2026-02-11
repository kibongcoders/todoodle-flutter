import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todoodle/models/achievement.dart';
import 'package:todoodle/providers/achievement_provider.dart';

void main() {
  late AchievementProvider provider;
  late Directory tempDir;

  setUpAll(() async {
    // Hive 어댑터 등록
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(AchievementTypeAdapter());
  });

  setUp(() async {
    // 각 테스트마다 임시 디렉토리 생성
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    provider = AchievementProvider();
    await provider.init();
  });

  tearDown(() async {
    await Hive.close();
    // 임시 디렉토리 삭제
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AchievementProvider', () {
    group('초기화', () {
      test('init() 호출 후 initialized는 true', () {
        expect(provider.initialized, true);
      });

      test('init() 후 모든 업적 타입에 대해 Achievement 생성됨', () {
        expect(provider.achievements.length, AchievementType.values.length);
      });

      test('초기 상태에서 모든 업적은 잠김 상태', () {
        expect(provider.unlockedCount, 0);
        expect(provider.lockedAchievements.length, AchievementType.values.length);
      });

      test('totalCount는 AchievementType 개수와 동일', () {
        expect(provider.totalCount, AchievementType.values.length);
        expect(provider.totalCount, 15);
      });
    });

    group('getAchievement', () {
      test('존재하는 업적 타입으로 Achievement 조회', () {
        final achievement = provider.getAchievement(AchievementType.firstTodo);

        expect(achievement, isNotNull);
        expect(achievement!.type, AchievementType.firstTodo);
        expect(achievement.isUnlocked, false);
      });

      test('모든 타입에 대해 getAchievement 동작', () {
        for (final type in AchievementType.values) {
          final achievement = provider.getAchievement(type);
          expect(achievement, isNotNull);
          expect(achievement!.type, type);
        }
      });
    });

    group('onTodoCompleted - 완료 마일스톤', () {
      test('1개 완료 시 firstTodo 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.firstTodo);
        expect(achievement!.isUnlocked, true);
      });

      test('10개 완료 시 complete10 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 10,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.complete10);
        expect(achievement!.isUnlocked, true);
      });

      test('50개 완료 시 complete50 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 50,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.complete50);
        expect(achievement!.isUnlocked, true);
      });

      test('100개 완료 시 complete100 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 100,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.complete100);
        expect(achievement!.isUnlocked, true);
      });

      test('500개 완료 시 complete500 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 500,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.complete500);
        expect(achievement!.isUnlocked, true);
      });

      test('진행도 업데이트 확인', () async {
        await provider.onTodoCompleted(
          totalCompleted: 5,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final complete10 = provider.getAchievement(AchievementType.complete10);
        expect(complete10!.currentProgress, 5);
        expect(complete10.isUnlocked, false);
      });
    });

    group('onTodoCompleted - 스트릭', () {
      test('3일 스트릭 시 streak3 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 3,
          currentStreak: 3,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.streak3);
        expect(achievement!.isUnlocked, true);
      });

      test('7일 스트릭 시 streak7 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 7,
          currentStreak: 7,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.streak7);
        expect(achievement!.isUnlocked, true);
      });

      test('30일 스트릭 시 streak30 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 30,
          currentStreak: 30,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.streak30);
        expect(achievement!.isUnlocked, true);
      });

      test('스트릭 진행도 업데이트 확인', () async {
        await provider.onTodoCompleted(
          totalCompleted: 5,
          currentStreak: 5,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final streak7 = provider.getAchievement(AchievementType.streak7);
        expect(streak7!.currentProgress, 5);
        expect(streak7.isUnlocked, false);
      });
    });

    group('onTodoCompleted - 시간대 업적', () {
      test('오전 5시에 완료 시 earlyBird 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 5, 30),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.earlyBird);
        expect(achievement!.isUnlocked, true);
      });

      test('오전 6시 이후 완료 시 earlyBird 업적 미해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 6, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.earlyBird);
        expect(achievement!.isUnlocked, false);
      });

      test('새벽 2시에 완료 시 nightOwl 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 2, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.nightOwl);
        expect(achievement!.isUnlocked, true);
      });

      test('새벽 2시 완료 시 earlyBird와 nightOwl 둘 다 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 2, 0),
          isTodayAllCompleted: false,
        );

        final earlyBird = provider.getAchievement(AchievementType.earlyBird);
        final nightOwl = provider.getAchievement(AchievementType.nightOwl);

        expect(earlyBird!.isUnlocked, true);
        expect(nightOwl!.isUnlocked, true);
      });

      test('오전 4시 이후는 nightOwl 미해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 4, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.nightOwl);
        expect(achievement!.isUnlocked, false);
      });
    });

    group('onTodoCompleted - 완벽한 하루', () {
      test('오늘 모든 할일 완료 시 perfectDay 업적 해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: true,
        );

        final achievement = provider.getAchievement(AchievementType.perfectDay);
        expect(achievement!.isUnlocked, true);
      });

      test('오늘 할일이 남아있으면 perfectDay 업적 미해제', () async {
        await provider.onTodoCompleted(
          totalCompleted: 5,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final achievement = provider.getAchievement(AchievementType.perfectDay);
        expect(achievement!.isUnlocked, false);
      });
    });

    group('onDoodleCompleted', () {
      test('첫 낙서 완성 시 plantGrown 업적 해제', () async {
        await provider.onDoodleCompleted(totalDoodlesCompleted: 1);

        final achievement = provider.getAchievement(AchievementType.plantGrown);
        expect(achievement!.isUnlocked, true);
      });

      test('10개 낙서 완성 시 forest10 업적 해제', () async {
        await provider.onDoodleCompleted(totalDoodlesCompleted: 10);

        final achievement = provider.getAchievement(AchievementType.forest10);
        expect(achievement!.isUnlocked, true);
      });

      test('5개 낙서 완성 시 forest10 업적 미해제', () async {
        await provider.onDoodleCompleted(totalDoodlesCompleted: 5);

        final achievement = provider.getAchievement(AchievementType.forest10);
        expect(achievement!.isUnlocked, false);
      });
    });

    group('onFocusSessionCompleted', () {
      test('총 60분 집중 시 focusHour 업적 해제', () async {
        await provider.onFocusSessionCompleted(
          totalFocusMinutes: 60,
          todayFocusMinutes: 60,
        );

        final achievement = provider.getAchievement(AchievementType.focusHour);
        expect(achievement!.isUnlocked, true);
      });

      test('총 30분 집중 시 focusHour 업적 미해제', () async {
        await provider.onFocusSessionCompleted(
          totalFocusMinutes: 30,
          todayFocusMinutes: 30,
        );

        final achievement = provider.getAchievement(AchievementType.focusHour);
        expect(achievement!.isUnlocked, false);
        expect(achievement.currentProgress, 30);
      });

      test('오늘 240분 집중 시 focusDay 업적 해제', () async {
        await provider.onFocusSessionCompleted(
          totalFocusMinutes: 240,
          todayFocusMinutes: 240,
        );

        final achievement = provider.getAchievement(AchievementType.focusDay);
        expect(achievement!.isUnlocked, true);
      });

      test('오늘 120분만 집중 시 focusDay 업적 미해제', () async {
        await provider.onFocusSessionCompleted(
          totalFocusMinutes: 240,
          todayFocusMinutes: 120,
        );

        final achievement = provider.getAchievement(AchievementType.focusDay);
        expect(achievement!.isUnlocked, false);
      });
    });

    group('onAchievementUnlocked 콜백', () {
      test('업적 해제 시 콜백이 호출됨', () async {
        Achievement? unlockedAchievement;
        provider.onAchievementUnlocked = (achievement) {
          unlockedAchievement = achievement;
        };

        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        expect(unlockedAchievement, isNotNull);
        expect(unlockedAchievement!.type, AchievementType.firstTodo);
      });

      test('이미 해제된 업적은 콜백이 호출되지 않음', () async {
        int callCount = 0;
        provider.onAchievementUnlocked = (_) {
          callCount++;
        };

        // 첫 번째 호출
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        final firstCallCount = callCount;

        // 두 번째 호출 (같은 조건)
        await provider.onTodoCompleted(
          totalCompleted: 1,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        // 이미 해제된 firstTodo에 대해 다시 호출되지 않음
        expect(callCount, firstCallCount);
      });
    });

    group('resetAllAchievements', () {
      test('모든 업적 초기화', () async {
        // 먼저 일부 업적 해제
        await provider.onTodoCompleted(
          totalCompleted: 10,
          currentStreak: 7,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: true,
        );

        expect(provider.unlockedCount, greaterThan(0));

        // 초기화
        await provider.resetAllAchievements();

        // 모든 업적이 잠김 상태로 복구
        expect(provider.unlockedCount, 0);
        expect(provider.achievements.length, AchievementType.values.length);
      });
    });

    group('unlockedAchievements / lockedAchievements', () {
      test('해제된 업적만 unlockedAchievements에 포함', () async {
        await provider.onTodoCompleted(
          totalCompleted: 10,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        // firstTodo, complete10이 해제됨
        expect(provider.unlockedAchievements.length, 2);
        expect(
          provider.unlockedAchievements.any((a) => a.type == AchievementType.firstTodo),
          true,
        );
        expect(
          provider.unlockedAchievements.any((a) => a.type == AchievementType.complete10),
          true,
        );
      });

      test('잠긴 업적만 lockedAchievements에 포함', () async {
        await provider.onTodoCompleted(
          totalCompleted: 10,
          currentStreak: 0,
          completedAt: DateTime(2024, 1, 1, 12, 0),
          isTodayAllCompleted: false,
        );

        // 2개 해제됨 -> 13개 잠김
        expect(provider.lockedAchievements.length, 13);
        expect(
          provider.lockedAchievements.any((a) => a.type == AchievementType.firstTodo),
          false,
        );
      });
    });
  });
}
