import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/focus_session.dart';
import '../services/notification_service.dart';

enum PomodoroState {
  idle,     // 대기 중
  running,  // 실행 중
  paused,   // 일시 정지
  break_,   // 휴식 중
}

class FocusProvider extends ChangeNotifier {
  static const _boxName = 'focus_sessions';
  static const _settingsBoxName = 'focus_settings';
  static const _focusTodosBoxName = 'focus_todos';

  late Box<FocusSession> _sessionsBox;
  late Box _settingsBox;
  late Box<String> _focusTodosBox;

  final _uuid = const Uuid();
  final _notificationService = NotificationService();

  // 포모도로 설정
  int _workDuration = 25 * 60; // 25분 (초)
  int _shortBreakDuration = 5 * 60; // 5분
  int _longBreakDuration = 15 * 60; // 15분
  int _sessionsUntilLongBreak = 4; // 긴 휴식까지 세션 수

  // 포모도로 상태
  PomodoroState _state = PomodoroState.idle;
  int _remainingSeconds = 0;
  int _completedSessions = 0;
  Timer? _timer;
  String? _currentTodoId;
  FocusSession? _currentSession;

  // 오늘의 집중 할일 (최대 3개)
  List<String> _focusTodoIds = [];

  /// 작업 세션 완료 시 호출되는 콜백 (todoId, 완료된 분)
  Function(String todoId, int minutes)? onWorkSessionComplete;

  // Getters
  int get workDuration => _workDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get sessionsUntilLongBreak => _sessionsUntilLongBreak;
  PomodoroState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get completedSessions => _completedSessions;
  String? get currentTodoId => _currentTodoId;
  List<String> get focusTodoIds => List.unmodifiable(_focusTodoIds);
  bool get isRunning => _state == PomodoroState.running;
  bool get isPaused => _state == PomodoroState.paused;
  bool get isBreak => _state == PomodoroState.break_;
  bool get isIdle => _state == PomodoroState.idle;

  // 진행률 (0.0 ~ 1.0)
  double get progress {
    if (_state == PomodoroState.idle) return 0;
    final total = _state == PomodoroState.break_
        ? (_completedSessions % _sessionsUntilLongBreak == 0
            ? _longBreakDuration
            : _shortBreakDuration)
        : _workDuration;
    return 1 - (_remainingSeconds / total);
  }

  Future<void> init() async {
    _sessionsBox = await Hive.openBox<FocusSession>(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _focusTodosBox = await Hive.openBox<String>(_focusTodosBoxName);

    // 설정 로드
    _workDuration = _settingsBox.get('workDuration', defaultValue: 25 * 60);
    _shortBreakDuration = _settingsBox.get('shortBreakDuration', defaultValue: 5 * 60);
    _longBreakDuration = _settingsBox.get('longBreakDuration', defaultValue: 15 * 60);
    _sessionsUntilLongBreak = _settingsBox.get('sessionsUntilLongBreak', defaultValue: 4);

    // 오늘의 집중 할일 로드
    _loadTodaysFocusTodos();

    _remainingSeconds = _workDuration;
  }

  void _loadTodaysFocusTodos() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final savedDate = _settingsBox.get('focusTodosDate');

    if (savedDate == todayKey) {
      _focusTodoIds = _focusTodosBox.values.toList();
    } else {
      // 날짜가 바뀌면 초기화
      _focusTodosBox.clear();
      _focusTodoIds = [];
      _settingsBox.put('focusTodosDate', todayKey);
    }
  }

  // 오늘의 집중 할일 추가/제거
  Future<void> toggleFocusTodo(String todoId) async {
    if (_focusTodoIds.contains(todoId)) {
      _focusTodoIds.remove(todoId);
      await _focusTodosBox.delete(todoId);
    } else if (_focusTodoIds.length < 3) {
      _focusTodoIds.add(todoId);
      await _focusTodosBox.put(todoId, todoId);
    }
    notifyListeners();
  }

  bool isFocusTodo(String todoId) => _focusTodoIds.contains(todoId);

  // 포모도로 시작
  void startPomodoro({String? todoId}) {
    if (_state == PomodoroState.running) return;

    _currentTodoId = todoId;
    _remainingSeconds = _workDuration;
    _state = PomodoroState.running;

    // 세션 생성
    _currentSession = FocusSession(
      id: _uuid.v4(),
      todoId: todoId,
      type: FocusSessionType.work,
      startTime: DateTime.now(),
      plannedDuration: _workDuration,
    );

    _startTimer();
    notifyListeners();
  }

  // 포모도로 일시정지
  void pausePomodoro() {
    if (_state != PomodoroState.running) return;

    _timer?.cancel();
    _state = PomodoroState.paused;
    notifyListeners();
  }

  // 포모도로 재개
  void resumePomodoro() {
    if (_state != PomodoroState.paused) return;

    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  // 포모도로 중단
  Future<void> stopPomodoro() async {
    _timer?.cancel();

    // 현재 세션 저장 (중단됨으로)
    if (_currentSession != null) {
      _currentSession!.endTime = DateTime.now();
      _currentSession!.actualDuration =
          _currentSession!.plannedDuration - _remainingSeconds;
      _currentSession!.wasInterrupted = true;
      await _sessionsBox.put(_currentSession!.id, _currentSession!);
    }

    _state = PomodoroState.idle;
    _remainingSeconds = _workDuration;
    _currentSession = null;
    _currentTodoId = null;
    notifyListeners();
  }

  // 휴식 건너뛰기
  void skipBreak() {
    if (_state != PomodoroState.break_) return;

    _timer?.cancel();
    _state = PomodoroState.idle;
    _remainingSeconds = _workDuration;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();

    if (_state == PomodoroState.running) {
      // 작업 완료
      _completedSessions++;

      // 세션 저장
      if (_currentSession != null) {
        _currentSession!.endTime = DateTime.now();
        _currentSession!.actualDuration = _currentSession!.plannedDuration;
        _currentSession!.wasCompleted = true;
        await _sessionsBox.put(_currentSession!.id, _currentSession!);

        // 할일의 실제 시간 업데이트 콜백 호출
        final todoId = _currentSession!.todoId;
        final completedMinutes = _currentSession!.actualDuration ~/ 60;
        if (todoId != null && completedMinutes > 0) {
          onWorkSessionComplete?.call(todoId, completedMinutes);
        }

        _currentSession = null;
      }

      // 알림
      _notificationService.showFocusCompleteNotification(
        isBreak: false,
        sessionsCompleted: _completedSessions,
      );

      // 휴식 시작
      _state = PomodoroState.break_;
      _remainingSeconds = _completedSessions % _sessionsUntilLongBreak == 0
          ? _longBreakDuration
          : _shortBreakDuration;
      _startTimer();
    } else if (_state == PomodoroState.break_) {
      // 휴식 완료
      _notificationService.showFocusCompleteNotification(
        isBreak: true,
        sessionsCompleted: _completedSessions,
      );

      _state = PomodoroState.idle;
      _remainingSeconds = _workDuration;
    }

    notifyListeners();
  }

  // 설정 변경
  Future<void> setWorkDuration(int seconds) async {
    _workDuration = seconds;
    await _settingsBox.put('workDuration', seconds);
    if (_state == PomodoroState.idle) {
      _remainingSeconds = seconds;
    }
    notifyListeners();
  }

  Future<void> setShortBreakDuration(int seconds) async {
    _shortBreakDuration = seconds;
    await _settingsBox.put('shortBreakDuration', seconds);
    notifyListeners();
  }

  Future<void> setLongBreakDuration(int seconds) async {
    _longBreakDuration = seconds;
    await _settingsBox.put('longBreakDuration', seconds);
    notifyListeners();
  }

  Future<void> setSessionsUntilLongBreak(int count) async {
    _sessionsUntilLongBreak = count;
    await _settingsBox.put('sessionsUntilLongBreak', count);
    notifyListeners();
  }

  // 오늘 집중 통계
  Map<String, dynamic> getTodayStats() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todaySessions = _sessionsBox.values.where((s) =>
        s.type == FocusSessionType.work &&
        s.startTime.isAfter(todayStart) &&
        s.wasCompleted);

    int totalSeconds = 0;
    int completedCount = 0;

    for (final session in todaySessions) {
      totalSeconds += session.actualDuration;
      completedCount++;
    }

    return {
      'totalMinutes': totalSeconds ~/ 60,
      'completedSessions': completedCount,
      'currentStreak': _completedSessions,
    };
  }

  // 일별 집중 통계 (최근 7일)
  List<Map<String, dynamic>> getWeeklyStats() {
    final result = <Map<String, dynamic>>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final daySessions = _sessionsBox.values.where((s) =>
          s.type == FocusSessionType.work &&
          s.startTime.isAfter(dayStart) &&
          s.startTime.isBefore(dayEnd) &&
          s.wasCompleted);

      int totalMinutes = 0;
      for (final session in daySessions) {
        totalMinutes += session.actualDuration ~/ 60;
      }

      result.add({
        'date': date,
        'minutes': totalMinutes,
        'sessions': daySessions.length,
      });
    }

    return result;
  }

  // 특정 할일의 총 집중 시간
  int getTotalFocusMinutesForTodo(String todoId) {
    final sessions = _sessionsBox.values.where((s) =>
        s.todoId == todoId && s.wasCompleted);

    int totalSeconds = 0;
    for (final session in sessions) {
      totalSeconds += session.actualDuration;
    }

    return totalSeconds ~/ 60;
  }

  /// 전체 누적 집중 시간 (분)
  int getAllTimeFocusMinutes() {
    final sessions = _sessionsBox.values.where((s) =>
        s.type == FocusSessionType.work && s.wasCompleted);

    int totalSeconds = 0;
    for (final session in sessions) {
      totalSeconds += session.actualDuration;
    }

    return totalSeconds ~/ 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
