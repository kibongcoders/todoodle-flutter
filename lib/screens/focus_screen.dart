import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/focus_provider.dart';
import '../providers/todo_provider.dart';
import '../shared/widgets/doodle_icon.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text(
          '집중 모드',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const DoodleIcon(type: DoodleIconType.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Consumer<FocusProvider>(
        builder: (context, focusProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 포모도로 타이머
                _buildPomodoroTimer(context, focusProvider),
                const SizedBox(height: 24),

                // 오늘의 집중 할일
                _buildFocusTodos(context, focusProvider),
                const SizedBox(height: 24),

                // 오늘 통계
                _buildTodayStats(focusProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPomodoroTimer(BuildContext context, FocusProvider focusProvider) {
    final minutes = focusProvider.remainingSeconds ~/ 60;
    final seconds = focusProvider.remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final isBreak = focusProvider.isBreak;
    final isRunning = focusProvider.isRunning;
    final isPaused = focusProvider.isPaused;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8E6CF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상태 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isBreak
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isBreak ? '☕' : '🍅',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  isBreak ? '휴식 시간' : '집중 시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isBreak
                        ? const Color(0xFF1976D2)
                        : const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 타이머
          Stack(
            alignment: Alignment.center,
            children: [
              // 진행률 원형 표시
              SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _TimerPainter(
                        progress: focusProvider.progress,
                        isBreak: isBreak,
                        isRunning: isRunning || isPaused,
                        animation: _animationController.value,
                      ),
                    );
                  },
                ),
              ),
              // 시간 텍스트
              Column(
                children: [
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: isBreak
                          ? const Color(0xFF1976D2)
                          : const Color(0xFF2E7D32),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '세션 ${focusProvider.completedSessions}회 완료',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 컨트롤 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (focusProvider.isIdle) ...[
                // 시작 버튼
                _buildControlButton(
                  iconType: DoodleIconType.play,
                  label: '시작',
                  color: const Color(0xFF2E7D32),
                  onTap: () => _startPomodoro(context, focusProvider),
                ),
              ] else if (isRunning) ...[
                // 일시정지 버튼
                _buildControlButton(
                  iconType: DoodleIconType.pause,
                  label: '일시정지',
                  color: const Color(0xFFFFA726),
                  onTap: focusProvider.pausePomodoro,
                ),
                const SizedBox(width: 16),
                // 중단 버튼
                _buildControlButton(
                  iconType: DoodleIconType.stop,
                  label: '중단',
                  color: const Color(0xFFE53935),
                  onTap: focusProvider.stopPomodoro,
                  isOutlined: true,
                ),
              ] else if (isPaused) ...[
                // 재개 버튼
                _buildControlButton(
                  iconType: DoodleIconType.play,
                  label: '재개',
                  color: const Color(0xFF2E7D32),
                  onTap: focusProvider.resumePomodoro,
                ),
                const SizedBox(width: 16),
                // 중단 버튼
                _buildControlButton(
                  iconType: DoodleIconType.stop,
                  label: '중단',
                  color: const Color(0xFFE53935),
                  onTap: focusProvider.stopPomodoro,
                  isOutlined: true,
                ),
              ] else if (isBreak) ...[
                // 휴식 건너뛰기
                _buildControlButton(
                  iconType: DoodleIconType.skipNext,
                  label: '건너뛰기',
                  color: const Color(0xFF1976D2),
                  onTap: focusProvider.skipBreak,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required DoodleIconType iconType,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(30),
          border: isOutlined ? Border.all(color: color, width: 2) : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            DoodleIcon(type: iconType, color: isOutlined ? color : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOutlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusTodos(BuildContext context, FocusProvider focusProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8E6CF).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                '오늘의 집중',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const Spacer(),
              Text(
                '${focusProvider.focusTodoIds.length}/3',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '오늘 꼭 완료할 3가지를 선택하세요',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          _buildFocusTodosList(context, focusProvider),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showTodoSelector(context, focusProvider),
            icon: const DoodleIcon(type: DoodleIconType.add, size: 20),
            label: const Text('할일 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTodosList(
    BuildContext context,
    FocusProvider focusProvider,
  ) {
    final todoProvider = context.read<TodoProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final focusTodoIds = focusProvider.focusTodoIds;

    if (focusTodoIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                '🎯',
                style: TextStyle(fontSize: 32, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                '오늘 집중할 할일을 선택해주세요',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: focusTodoIds.map((todoId) {
        final todo = todoProvider.getTodo(todoId);
        if (todo == null) return const SizedBox.shrink();

        final category = todo.categoryIds.isNotEmpty
            ? categoryProvider.getCategoryById(todo.categoryIds.first)
            : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: todo.isCompleted
                  ? const Color(0xFFA8E6CF).withValues(alpha: 0.2)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: todo.isCompleted
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                    : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => todoProvider.toggleComplete(todo.id),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: todo.isCompleted
                          ? const Color(0xFF2E7D32)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.isCompleted
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: todo.isCompleted
                        ? const DoodleIcon(type: DoodleIconType.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category?.emoji ?? '📌',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 15,
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                      color: todo.isCompleted ? Colors.grey[500] : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 집중 시작 버튼
                if (!todo.isCompleted && focusProvider.isIdle)
                  IconButton(
                    icon: const DoodleIcon(type: DoodleIconType.play),
                    color: const Color(0xFF2E7D32),
                    onPressed: () =>
                        focusProvider.startPomodoro(todoId: todo.id),
                    tooltip: '이 할일에 집중하기',
                  ),
                // 제거 버튼
                IconButton(
                  icon: DoodleIcon(type: DoodleIconType.close, color: Colors.grey[400]!, size: 20),
                  onPressed: () => focusProvider.toggleFocusTodo(todo.id),
                  tooltip: '목록에서 제거',
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodayStats(FocusProvider focusProvider) {
    final stats = focusProvider.getTodayStats();
    final weeklyStats = focusProvider.getWeeklyStats();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8E6CF).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '집중 통계',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 오늘 통계
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  emoji: '⏱️',
                  value: '${stats['totalMinutes']}분',
                  label: '오늘 집중',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  emoji: '🍅',
                  value: '${stats['completedSessions']}회',
                  label: '완료 세션',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  emoji: '🔥',
                  value: '${stats['currentStreak']}회',
                  label: '현재 연속',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 주간 그래프
          Text(
            '최근 7일',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyStats.map((day) {
                final maxMinutes = weeklyStats
                    .map((d) => d['minutes'] as int)
                    .fold(0, (a, b) => a > b ? a : b);
                final height = maxMinutes > 0
                    ? (day['minutes'] as int) / maxMinutes * 60
                    : 0.0;

                final date = day['date'] as DateTime;
                final isToday = DateTime.now().day == date.day;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day['minutes'] > 0)
                          Text(
                            '${day['minutes']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(4.0, 60.0),
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFA8E6CF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getWeekdayLabel(date.weekday),
                          style: TextStyle(
                            fontSize: 11,
                            color: isToday
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[600],
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getWeekdayLabel(int weekday) {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return labels[weekday - 1];
  }

  void _startPomodoro(BuildContext context, FocusProvider focusProvider) {
    if (focusProvider.focusTodoIds.isNotEmpty) {
      // 첫 번째 미완료 할일로 시작
      final todoProvider = context.read<TodoProvider>();
      for (final todoId in focusProvider.focusTodoIds) {
        final todo = todoProvider.getTodo(todoId);
        if (todo != null && !todo.isCompleted) {
          focusProvider.startPomodoro(todoId: todoId);
          return;
        }
      }
    }
    // 할일 없이 시작
    focusProvider.startPomodoro();
  }

  void _showTodoSelector(BuildContext context, FocusProvider focusProvider) {
    final todoProvider = context.read<TodoProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final todos = todoProvider.getRootTodos().where((t) => !t.isCompleted).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    '오늘의 집중 할일 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: todos.isEmpty
                  ? Center(
                      child: Text(
                        '미완료 할일이 없습니다',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        final isSelected =
                            focusProvider.isFocusTodo(todo.id);
                        final category = todo.categoryIds.isNotEmpty
                            ? categoryProvider
                                .getCategoryById(todo.categoryIds.first)
                            : null;

                        return ListTile(
                          leading: Text(
                            category?.emoji ?? '📌',
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(
                            todo.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                )
                              : focusProvider.focusTodoIds.length >= 3
                                  ? Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey[300],
                                    )
                                  : const Icon(
                                      Icons.circle_outlined,
                                      color: Color(0xFFA8E6CF),
                                    ),
                          onTap: () {
                            if (!isSelected &&
                                focusProvider.focusTodoIds.length >= 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('최대 3개까지만 선택할 수 있습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            focusProvider.toggleFocusTodo(todo.id);
                          },
                        );
                      },
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('완료'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final focusProvider = context.read<FocusProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('⚙️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('포모도로 설정'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingSlider(
              label: '집중 시간',
              value: focusProvider.workDuration ~/ 60,
              min: 5,
              max: 60,
              suffix: '분',
              onChanged: (value) {
                focusProvider.setWorkDuration(value.toInt() * 60);
              },
            ),
            const SizedBox(height: 16),
            _buildSettingSlider(
              label: '짧은 휴식',
              value: focusProvider.shortBreakDuration ~/ 60,
              min: 1,
              max: 15,
              suffix: '분',
              onChanged: (value) {
                focusProvider.setShortBreakDuration(value.toInt() * 60);
              },
            ),
            const SizedBox(height: 16),
            _buildSettingSlider(
              label: '긴 휴식',
              value: focusProvider.longBreakDuration ~/ 60,
              min: 5,
              max: 30,
              suffix: '분',
              onChanged: (value) {
                focusProvider.setLongBreakDuration(value.toInt() * 60);
              },
            ),
            const SizedBox(height: 16),
            _buildSettingSlider(
              label: '긴 휴식까지',
              value: focusProvider.sessionsUntilLongBreak,
              min: 2,
              max: 8,
              suffix: '회',
              onChanged: (value) {
                focusProvider.setSessionsUntilLongBreak(value.toInt());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSlider({
    required String label,
    required int value,
    required int min,
    required int max,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                Text(
                  '$value$suffix',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              activeColor: const Color(0xFF2E7D32),
              onChanged: (newValue) {
                setState(() {});
                onChanged(newValue);
              },
            ),
          ],
        );
      },
    );
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.progress,
    required this.isBreak,
    required this.isRunning,
    required this.animation,
  });

  final double progress;
  final bool isBreak;
  final bool isRunning;
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // 배경 원
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 진행률 원호
    final progressPaint = Paint()
      ..color = isBreak ? const Color(0xFF42A5F5) : const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // 실행 중일 때 글로우 효과
    if (isRunning && progress > 0) {
      final glowPaint = Paint()
        ..color = (isBreak ? const Color(0xFF42A5F5) : const Color(0xFF2E7D32))
            .withValues(alpha: 0.3 + 0.2 * math.sin(animation * 2 * math.pi))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isBreak != isBreak ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.animation != animation;
  }
}
