import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'models/achievement.dart';
import 'models/category.dart';
import 'models/doodle.dart';
import 'models/focus_session.dart';
import 'models/plant.dart';
import 'models/template.dart';
import 'models/todo.dart';
import 'features/statistics/presentation/providers/statistics_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/category_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sketchbook_provider.dart';
import 'providers/template_provider.dart';
import 'providers/todo_provider.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'shared/themes/doodle_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 초기화 (캘린더용)
  await initializeDateFormatting('ko_KR', null);

  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(RecurrenceAdapter());
  Hive.registerAdapter(TodoCategoryModelAdapter());
  Hive.registerAdapter(PlantTypeAdapter());
  Hive.registerAdapter(PlantAdapter());
  // Phase 3 모델 어댑터
  Hive.registerAdapter(FocusSessionTypeAdapter());
  Hive.registerAdapter(FocusSessionAdapter());
  Hive.registerAdapter(TodoTemplateAdapter());
  Hive.registerAdapter(TemplateItemAdapter());
  // Phase 4 모델 어댑터
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(AchievementTypeAdapter());
  // 스케치북 모델 어댑터
  Hive.registerAdapter(DoodleCategoryAdapter());
  Hive.registerAdapter(DoodleTypeAdapter());
  Hive.registerAdapter(DoodleAdapter());
  await Hive.openBox<Todo>('todos');

  final categoryProvider = CategoryProvider();
  await categoryProvider.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();
  notificationService.setSettingsProvider(settingsProvider);

  // 스케치북 Provider 초기화
  final sketchbookProvider = SketchbookProvider();
  await sketchbookProvider.init();

  // 집중 모드 Provider 초기화
  final focusProvider = FocusProvider();
  await focusProvider.init();

  // 템플릿 Provider 초기화
  final templateProvider = TemplateProvider();
  await templateProvider.init();

  // 업적 Provider 초기화
  final achievementProvider = AchievementProvider();
  await achievementProvider.init();

  // 낙서 완성 시 업적 체크 연결
  sketchbookProvider.onDoodleCompleted = (totalDoodlesCompleted) {
    achievementProvider.onDoodleCompleted(totalDoodlesCompleted: totalDoodlesCompleted);
  };

  runApp(MyApp(
    categoryProvider: categoryProvider,
    settingsProvider: settingsProvider,
    sketchbookProvider: sketchbookProvider,
    focusProvider: focusProvider,
    templateProvider: templateProvider,
    achievementProvider: achievementProvider,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.categoryProvider,
    required this.settingsProvider,
    required this.sketchbookProvider,
    required this.focusProvider,
    required this.templateProvider,
    required this.achievementProvider,
  });

  final CategoryProvider categoryProvider;
  final SettingsProvider settingsProvider;
  final SketchbookProvider sketchbookProvider;
  final FocusProvider focusProvider;
  final TemplateProvider templateProvider;
  final AchievementProvider achievementProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final todoProvider = TodoProvider();
          todoProvider.setSettingsProvider(settingsProvider);
          todoProvider.setSketchbookProvider(sketchbookProvider);
          todoProvider.setAchievementProvider(achievementProvider);

          // 포모도로 세션 완료 시 할일의 실제 시간 업데이트 및 업적 체크
          focusProvider.onWorkSessionComplete = (todoId, minutes) {
            todoProvider.updateActualMinutes(todoId, minutes);
            // 집중 모드 업적 체크
            final todayStats = focusProvider.getTodayStats();
            achievementProvider.onFocusSessionCompleted(
              totalFocusMinutes: focusProvider.getAllTimeFocusMinutes(),
              todayFocusMinutes: todayStats['totalMinutes'] as int,
            );
          };

          return todoProvider;
        }),
        ChangeNotifierProvider.value(value: categoryProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: sketchbookProvider),
        ChangeNotifierProvider.value(value: focusProvider),
        ChangeNotifierProvider.value(value: templateProvider),
        ChangeNotifierProvider.value(value: achievementProvider),
        // 통계 Provider (다른 Provider들에 의존)
        ProxyProvider5<TodoProvider, FocusProvider, SketchbookProvider,
            AchievementProvider, CategoryProvider, StatisticsProvider>(
          update: (_, todoProvider, focusProvider, sketchbookProvider,
                  achievementProvider, categoryProvider, _) =>
              StatisticsProvider(
            todoProvider: todoProvider,
            focusProvider: focusProvider,
            sketchbookProvider: sketchbookProvider,
            achievementProvider: achievementProvider,
            categoryProvider: categoryProvider,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'todoodle',
        debugShowCheckedModeBanner: false,
        theme: DoodleTheme.light,
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }
    return const MainScreen();
  }
}
