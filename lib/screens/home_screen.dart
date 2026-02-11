import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/doodle_colors.dart';
import '../core/constants/doodle_typography.dart';
import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/sketchbook_provider.dart';
import '../providers/todo_provider.dart' show TodoProvider, DateFilter;
import '../services/natural_language_parser.dart';
import '../services/speech_service.dart';
import '../shared/widgets/doodle_background.dart';
import '../widgets/todo_list_item.dart';
import 'category_screen.dart';
import 'sketchbook_screen.dart';
import 'template_screen.dart';
import 'todo_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _quickInputController = TextEditingController();
  final _quickInputFocusNode = FocusNode();
  final _speechService = SpeechService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _quickInputController.addListener(() {
      setState(() {});
    });
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // macOS에서는 TCC 정책으로 인해 음성 인식 초기화 건너뜀
    if (Platform.isMacOS) return;

    await _speechService.init();
    _speechService.onResult = (text) {
      setState(() {
        _quickInputController.text = text;
      });
    };
    _speechService.onListeningStateChanged = () {
      setState(() {
        _isListening = _speechService.isListening;
      });
    };
    _speechService.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('음성 인식 오류: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _quickInputController.dispose();
    _quickInputFocusNode.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<TodoProvider>().clearSearch();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final isVeryWide = constraints.maxWidth >= 1240;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            title: _isSearching ? _buildSearchField() : null,
            actions: [
              _buildSearchButton(),
              _buildFilterButton(context),
              const SizedBox(width: 8),
            ],
          ),
          backgroundColor: DoodleColors.paperCream,
          body: DoodleLinedBackground(
            lineSpacing: 28,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isVeryWide ? 1200 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      // 빠른 입력창
                      _buildQuickInput(context),
                      // 할일 목록
                      Expanded(
                        child: _buildTodoList(context, isWide, isVeryWide),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'home_fab',
            onPressed: () => _openFormScreen(context, null),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: DoodleColors.pencilLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: DoodleColors.paperShadow,
            blurRadius: 2,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '할일 검색...',
          hintStyle: DoodleTypography.hint,
          prefixIcon: const Icon(Icons.search, color: DoodleColors.pencilLight, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: DoodleColors.pencilLight, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TodoProvider>().clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        style: DoodleTypography.bodyMedium,
        onChanged: (value) {
          context.read<TodoProvider>().setSearchQuery(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildQuickInput(BuildContext context) {
    final hasText = _quickInputController.text.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: DoodleColors.paperWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: DoodleColors.pencilLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: DoodleColors.paperShadow,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          // 템플릿 버튼
          IconButton(
            icon: const Icon(
              Icons.dashboard_customize_outlined,
              color: DoodleColors.pencilLight,
              size: 22,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplateScreen()),
            ),
            tooltip: '템플릿',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Expanded(
            child: TextField(
              controller: _quickInputController,
              focusNode: _quickInputFocusNode,
              decoration: InputDecoration(
                hintText: '"내일 3시 회의" 또는 "긴급 보고서 작성"',
                hintStyle: DoodleTypography.hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
              style: DoodleTypography.bodyMedium,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => _submitQuickInput(context),
            ),
          ),
          // 음성 입력 버튼
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none_outlined,
              color: _isListening ? DoodleColors.crayonRed : DoodleColors.pencilLight,
              size: 22,
            ),
            onPressed: () => _speechService.startListening(),
            tooltip: '음성 입력',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          if (hasText)
            GestureDetector(
              onTap: () => _submitQuickInput(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: DoodleColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
              ),
            )
          else
            const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _submitQuickInput(BuildContext context) {
    final input = _quickInputController.text.trim();
    if (input.isEmpty) return;

    // 자연어 파싱
    final parser = NaturalLanguageParser();
    final parsed = parser.parse(input);

    // 우선순위 변환
    Priority? priority;
    if (parsed.priority != null) {
      priority = Priority.values[parsed.priority!];
    }

    context.read<TodoProvider>().addTodo(
      title: parsed.title,
      dueDate: parsed.dueDate,
      priority: priority ?? Priority.medium,
      tags: parsed.tags,
    );
    _quickInputController.clear();
    _quickInputFocusNode.unfocus();

    // 파싱된 정보 표시
    String message = '"${parsed.title}" 추가됨';
    if (parsed.hasAnyExtraction) {
      final extras = <String>[];
      if (parsed.hasDate) {
        final date = parsed.dueDate!;
        extras.add('${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}');
      }
      if (parsed.hasPriority) extras.add('우선순위 설정됨');
      if (parsed.hasTags) extras.add('#${parsed.tags.join(' #')}');
      message += ' (${extras.join(', ')})';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      onPressed: _toggleSearch,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isSearching
              ? DoodleColors.primary
              : DoodleColors.paperWhite,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _isSearching
                ? DoodleColors.primary
                : DoodleColors.pencilLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: DoodleColors.paperShadow,
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Icon(
          _isSearching ? Icons.close : Icons.search,
          color: _isSearching ? Colors.white : DoodleColors.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Consumer2<TodoProvider, CategoryProvider>(
      builder: (context, todoProvider, categoryProvider, _) {
        // 필터가 적용되어 있는지 확인
        final hasFilter = todoProvider.dateFilter != DateFilter.all ||
            todoProvider.selectedCategoryId != null;

        return IconButton(
          onPressed: () => _showFilterBottomSheet(context),
          icon: Badge(
            isLabelVisible: hasFilter,
            backgroundColor: DoodleColors.primary,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DoodleColors.paperWhite,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: DoodleColors.pencilLight.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: DoodleColors.paperShadow,
                    blurRadius: 1,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.filter_list,
                color: DoodleColors.primary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          color: DoodleColors.paperWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: DoodleColors.pencilLight.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: SafeArea(
          child: Consumer2<TodoProvider, CategoryProvider>(
            builder: (context, todoProvider, categoryProvider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 핸들 바
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: DoodleColors.pencilLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 날짜 필터 섹션
                    Text(
                      '날짜 필터',
                      style: DoodleTypography.titleMedium.copyWith(
                        color: DoodleColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          context,
                          label: '전체',
                          emoji: '📋',
                          isSelected: todoProvider.dateFilter == DateFilter.all,
                          onTap: () {
                            todoProvider.setDateFilter(DateFilter.all);
                          },
                        ),
                        _buildFilterChip(
                          context,
                          label: '오늘',
                          emoji: '📅',
                          isSelected: todoProvider.dateFilter == DateFilter.today,
                          onTap: () {
                            todoProvider.setDateFilter(DateFilter.today);
                          },
                        ),
                        _buildFilterChip(
                          context,
                          label: '예정됨',
                          emoji: '📆',
                          isSelected: todoProvider.dateFilter == DateFilter.upcoming,
                          onTap: () {
                            todoProvider.setDateFilter(DateFilter.upcoming);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 카테고리 필터 섹션
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '카테고리',
                          style: DoodleTypography.titleMedium.copyWith(
                            color: DoodleColors.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CategoryScreen()),
                            );
                          },
                          child: const Text('관리'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          context,
                          label: '전체',
                          emoji: '✨',
                          isSelected: todoProvider.selectedCategoryId == null,
                          onTap: () {
                            todoProvider.setCategory(null);
                          },
                        ),
                        ...categoryProvider.categories.map(
                          (category) => _buildFilterChip(
                            context,
                            label: category.name,
                            emoji: category.emoji,
                            isSelected: todoProvider.selectedCategoryId == category.id,
                            onTap: () {
                              todoProvider.setCategory(
                                todoProvider.selectedCategoryId == category.id
                                    ? null
                                    : category.id,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? DoodleColors.highlightYellow
              : DoodleColors.paperWhite,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? DoodleColors.pencilDark
                : DoodleColors.pencilLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: DoodleTypography.labelMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? DoodleColors.pencilDark : DoodleColors.pencilLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, bool isWide, bool isVeryWide) {
    return Consumer2<TodoProvider, CategoryProvider>(
      builder: (context, todoProvider, categoryProvider, _) {
        final rootTodos = todoProvider.getRootTodos();

        if (rootTodos.isEmpty) {
          return _buildEmptyState(
            todoProvider.dateFilter,
            searchQuery: todoProvider.searchQuery,
          );
        }

        // 날짜 필터가 "전체"일 때만 섹션별 그룹핑 사용
        if (todoProvider.dateFilter == DateFilter.all && todoProvider.searchQuery.isEmpty) {
          return _buildGroupedTodoList(context, todoProvider, categoryProvider);
        }

        // 오늘 필터일 때 상단에 요약 표시
        final showSummary = todoProvider.dateFilter == DateFilter.today;

        // 필터가 있으면 기존 리스트 사용
        return Column(
          children: [
            if (showSummary) _buildTodaySummary(todoProvider),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: rootTodos.length,
                onReorder: (oldIndex, newIndex) {
                  todoProvider.reorderTodo(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final elevation = Tween<double>(begin: 0, end: 8).animate(animation).value;
                      return Material(
                        elevation: elevation,
                        borderRadius: BorderRadius.circular(16),
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final todo = rootTodos[index];
                  final category = todo.categoryIds.isNotEmpty
                      ? categoryProvider.getCategoryById(todo.categoryIds.first)
                      : null;
                  return TodoListItem(
                    key: ValueKey(todo.id),
                    todo: todo,
                    categoryEmoji: category?.emoji ?? '📌',
                    onToggle: () => todoProvider.toggleComplete(todo.id),
                    onTap: () => _openFormScreen(context, todo),
                    onDelete: () => todoProvider.softDeleteTodo(todo.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupedTodoList(
    BuildContext context,
    TodoProvider todoProvider,
    CategoryProvider categoryProvider,
  ) {
    final grouped = todoProvider.getGroupedTodos();

    // Doodle 스타일 섹션 정의 (순서, 이름, 이모지, 색상)
    final sections = [
      ('overdue', '지연됨', '🚨', DoodleColors.crayonRed),
      ('today', '오늘', '📅', DoodleColors.primary),
      ('tomorrow', '내일', '🌅', DoodleColors.crayonOrange),
      ('thisWeek', '이번 주', '📆', DoodleColors.inkBlue),
      ('later', '나중에', '🗓️', DoodleColors.pencilLight),
      ('noDueDate', '마감일 없음', '📌', DoodleColors.pencilLight),
      ('completed', '완료됨', '✅', DoodleColors.pencilLight),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: sections.fold<int>(0, (sum, section) {
        final items = grouped[section.$1] ?? [];
        return sum + (items.isEmpty ? 0 : items.length + 1); // +1 for header
      }),
      itemBuilder: (context, index) {
        int currentIndex = 0;
        for (final section in sections) {
          final items = grouped[section.$1] ?? [];
          if (items.isEmpty) continue;

          // 헤더 체크
          if (index == currentIndex) {
            return _buildSectionHeader(section.$2, section.$3, section.$4, items.length);
          }
          currentIndex++;

          // 아이템 체크
          if (index < currentIndex + items.length) {
            final todo = items[index - currentIndex];
            final category = todo.categoryIds.isNotEmpty
                ? categoryProvider.getCategoryById(todo.categoryIds.first)
                : null;
            return TodoListItem(
              key: ValueKey(todo.id),
              todo: todo,
              categoryEmoji: category?.emoji ?? '📌',
              onToggle: () => todoProvider.toggleComplete(todo.id),
              onTap: () => _openFormScreen(context, todo),
              onDelete: () => todoProvider.softDeleteTodo(todo.id),
            );
          }
          currentIndex += items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(String title, String emoji, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: DoodleTypography.titleMedium.copyWith(
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: DoodleTypography.badge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(TodoProvider todoProvider) {
    final incompleteCount = todoProvider.getTodayIncompleteCount();
    final estimatedMinutes = todoProvider.getTodayTotalEstimatedMinutes();
    final sketchbookProvider = context.watch<SketchbookProvider>();
    final currentStreak = sketchbookProvider.currentStreak;

    // 아무 정보도 없으면 표시하지 않음
    if (estimatedMinutes == 0 && incompleteCount == 0 && currentStreak == 0) {
      return const SizedBox.shrink();
    }

    String timeText = '';
    if (estimatedMinutes > 0) {
      final hours = estimatedMinutes ~/ 60;
      final mins = estimatedMinutes % 60;
      if (hours > 0 && mins > 0) {
        timeText = '예상 $hours시간 $mins분';
      } else if (hours > 0) {
        timeText = '예상 $hours시간';
      } else {
        timeText = '예상 $mins분';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DoodleColors.highlightGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: DoodleColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 할 일 $incompleteCount개',
                  style: DoodleTypography.titleSmall.copyWith(
                    color: DoodleColors.primary,
                  ),
                ),
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: DoodleTypography.bodySmall.copyWith(
                      color: DoodleColors.pencilDark.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          // 스트릭 표시 (탭하면 스케치북으로 이동)
          if (currentStreak > 0) ...[
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SketchbookScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DoodleColors.crayonOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak일',
                      style: DoodleTypography.badge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DoodleColors.crayonOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (estimatedMinutes > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DoodleColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: DoodleColors.pencilDark.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTotalTime(estimatedMinutes),
                    style: DoodleTypography.badge.copyWith(
                      color: DoodleColors.pencilDark.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          // 스케치북 버튼
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SketchbookScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DoodleColors.highlightYellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('📓', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTotalTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  Widget _buildEmptyState(DateFilter filter, {String searchQuery = ''}) {
    String emoji;
    String title;
    String subtitle;

    // 검색 중일 때
    if (searchQuery.isNotEmpty) {
      emoji = '🔍';
      title = '검색 결과가 없어요';
      subtitle = '"$searchQuery"에 해당하는 할일이 없습니다';
    } else {
      switch (filter) {
        case DateFilter.today:
          emoji = '🎉';
          title = '오늘 할 일이 없어요!';
          subtitle = '오늘은 여유로운 하루네요';
        case DateFilter.upcoming:
          emoji = '📭';
          title = '예정된 할 일이 없어요';
          subtitle = '마감일이 있는 할 일을 추가해보세요';
        case DateFilter.all:
          emoji = '🌱';
          title = '아직 할 일이 없어요';
          subtitle = '새로운 할 일을 추가해볼까요?';
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: DoodleTypography.headlineSmall.copyWith(
              color: DoodleColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: DoodleTypography.bodyMedium.copyWith(
              color: DoodleColors.pencilLight,
            ),
          ),
          if (filter == DateFilter.all && searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: DoodleColors.highlightYellow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: DoodleColors.pencilLight.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '오른쪽 아래 + 버튼을 눌러주세요!',
                textAlign: TextAlign.center,
                style: DoodleTypography.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openFormScreen(BuildContext context, Todo? todo) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: TodoFormScreen(todo: todo, isDialog: true),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TodoFormScreen(todo: todo)),
      );
    }
  }
}
