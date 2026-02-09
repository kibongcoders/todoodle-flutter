import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/category_provider.dart';
import '../providers/forest_provider.dart';
import '../providers/todo_provider.dart' show TodoProvider, DateFilter;
import '../services/natural_language_parser.dart';
import '../services/speech_service.dart';
import '../widgets/todo_list_item.dart';
import 'category_screen.dart';
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
          backgroundColor: Colors.white,
          body: SafeArea(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '할일 검색...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TodoProvider>().clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        style: const TextStyle(fontSize: 14),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          // 템플릿 버튼
          IconButton(
            icon: Icon(
              Icons.dashboard_customize_outlined,
              color: Colors.grey[400],
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
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => _submitQuickInput(context),
            ),
          ),
          // 음성 입력 버튼
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none_outlined,
              color: _isListening ? const Color(0xFFE53935) : Colors.grey[400],
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
                  color: Color(0xFF2E7D32),
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
              ? const Color(0xFF2E7D32)
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isSearching ? Icons.close : Icons.search,
          color: _isSearching ? Colors.white : const Color(0xFF2E7D32),
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
            backgroundColor: const Color(0xFF2E7D32),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.filter_list,
                color: Color(0xFF2E7D32),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 날짜 필터 섹션
                    const Text(
                      '날짜 필터',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
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
                        const Text(
                          '카테고리',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
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
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
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

    // 섹션 정의 (순서, 이름, 이모지, 색상)
    final sections = [
      ('overdue', '지연됨', '🚨', const Color(0xFFE53935)),
      ('today', '오늘', '📅', const Color(0xFF2E7D32)),
      ('tomorrow', '내일', '🌅', const Color(0xFFFFA726)),
      ('thisWeek', '이번 주', '📆', const Color(0xFF42A5F5)),
      ('later', '나중에', '🗓️', Colors.grey[600]!),
      ('noDueDate', '마감일 없음', '📌', Colors.grey[500]!),
      ('completed', '완료됨', '✅', Colors.grey[400]!),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
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
    final forestProvider = context.watch<ForestProvider>();
    final currentStreak = forestProvider.currentStreak;

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
        color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          // 스트릭 표시
          if (currentStreak > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$currentStreak일',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (estimatedMinutes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTotalTime(estimatedMinutes),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
                color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '오른쪽 아래 + 버튼을 눌러주세요!',
                textAlign: TextAlign.center,
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
