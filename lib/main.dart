import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'models/achievement.dart';
import 'models/category.dart';
import 'models/focus_session.dart';
import 'models/plant.dart';
import 'models/template.dart';
import 'models/todo.dart';
import 'providers/achievement_provider.dart';
import 'providers/category_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/forest_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/template_provider.dart';
import 'providers/todo_provider.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

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

  // 숲 Provider 초기화
  final forestProvider = ForestProvider();
  await forestProvider.init();

  // 집중 모드 Provider 초기화
  final focusProvider = FocusProvider();
  await focusProvider.init();

  // 템플릿 Provider 초기화
  final templateProvider = TemplateProvider();
  await templateProvider.init();

  // 업적 Provider 초기화
  final achievementProvider = AchievementProvider();
  await achievementProvider.init();

  // 숲 성장 시 업적 체크 연결
  forestProvider.onPlantFullyGrown = (totalPlantsGrown) {
    achievementProvider.onPlantGrown(totalPlantsGrown: totalPlantsGrown);
  };

  runApp(MyApp(
    categoryProvider: categoryProvider,
    settingsProvider: settingsProvider,
    forestProvider: forestProvider,
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
    required this.forestProvider,
    required this.focusProvider,
    required this.templateProvider,
    required this.achievementProvider,
  });

  final CategoryProvider categoryProvider;
  final SettingsProvider settingsProvider;
  final ForestProvider forestProvider;
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
          todoProvider.setForestProvider(forestProvider);
          todoProvider.setAchievementProvider(achievementProvider);

          // 포모도로 세션 완료 시 할일의 실제 시간 업데이트 및 업적 체크
          focusProvider.onWorkSessionComplete = (todoId, minutes) {
            todoProvider.updateActualMinutes(todoId, minutes);
            // 집중 모드 업적 체크
            final stats = focusProvider.getTodayStats();
            achievementProvider.onFocusSessionCompleted(
              totalFocusMinutes: stats['totalMinutes'] as int,
              todayFocusMinutes: stats['totalMinutes'] as int,
            );
          };

          return todoProvider;
        }),
        ChangeNotifierProvider.value(value: categoryProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: forestProvider),
        ChangeNotifierProvider.value(value: focusProvider),
        ChangeNotifierProvider.value(value: templateProvider),
        ChangeNotifierProvider.value(value: achievementProvider),
      ],
      child: MaterialApp(
        title: 'todorest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFA8E6CF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF0FFF4),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE8F5E9),
            foregroundColor: Color(0xFF2E7D32),
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 3,
            shadowColor: const Color(0xFFA8E6CF).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFA8E6CF),
            foregroundColor: Color(0xFF2E7D32),
            elevation: 4,
            shape: CircleBorder(),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFE8F5E9),
            selectedColor: const Color(0xFFA8E6CF),
            labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB2DFDB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB2DFDB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFA8E6CF), width: 2),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA8E6CF),
              foregroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFA8E6CF);
              }
              return Colors.white;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
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
