import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Priority;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../models/todo.dart';
import '../providers/settings_provider.dart';

/// 알림 채널 정의 (마감일/반복/긴급/요약/포모도로)
class NotificationChannels {
  static const String deadline = 'deadline_channel';
  static const String recurring = 'recurring_channel';
  static const String urgent = 'urgent_channel';
  static const String summary = 'summary_channel';
  static const String focus = 'focus_channel';

  static const String deadlineName = '마감일 알림';
  static const String recurringName = '반복 할일 알림';
  static const String urgentName = '긴급 알림';
  static const String summaryName = '일일 요약';
}

/// 알림 액션 정의
class NotificationActions {
  static const String complete = 'COMPLETE_ACTION';
  static const String snooze10 = 'SNOOZE_10_ACTION';
  static const String snooze30 = 'SNOOZE_30_ACTION';
  static const String snooze60 = 'SNOOZE_60_ACTION';
}

/// 알림 페이로드 (알림 데이터 전달용)
class NotificationPayload {
  final String todoId;
  final String action;
  final int? snoozeMinutes;

  NotificationPayload({
    required this.todoId,
    this.action = '',
    this.snoozeMinutes,
  });

  String encode() => jsonEncode({
    'todoId': todoId,
    'action': action,
    'snoozeMinutes': snoozeMinutes,
  });

  static NotificationPayload? decode(String? payload) {
    if (payload == null) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return NotificationPayload(
        todoId: map['todoId'] as String,
        action: map['action'] as String? ?? '',
        snoozeMinutes: map['snoozeMinutes'] as int?,
      );
    } catch (e) {
      return null;
    }
  }
}

/// 알림 콜백 타입 정의
typedef NotificationActionCallback = void Function(String todoId, String action);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  SettingsProvider? _settingsProvider;

  /// 알림 액션 콜백 (완료/스누즈 처리용)
  NotificationActionCallback? onActionReceived;

  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
  }

  // 특정 시간이 DND 시간대인지 확인
  bool _isInDndPeriod(DateTime dateTime) {
    return _settingsProvider?.isInDndPeriod(dateTime) ?? false;
  }

  // DND 시간대를 피해 알림 시간 조정
  tz.TZDateTime _adjustForDnd(tz.TZDateTime scheduledDate) {
    if (_settingsProvider == null || !_settingsProvider!.dndEnabled) {
      return scheduledDate;
    }

    final dateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    if (_isInDndPeriod(dateTime)) {
      // DND 종료 시간으로 조정
      final endTime = _settingsProvider!.dndEndTime;
      var adjustedDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        endTime.hour,
        endTime.minute,
      );

      // DND 종료 시간이 원래 시간보다 이전이면 다음 날로
      if (adjustedDate.isBefore(scheduledDate)) {
        adjustedDate = adjustedDate.add(const Duration(days: 1));
      }

      return adjustedDate;
    }

    return scheduledDate;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    // Darwin(iOS/macOS) 알림 카테고리 설정 (액션 버튼 포함)
    final darwinCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'todo_actions',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            NotificationActions.complete,
            '완료',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            NotificationActions.snooze10,
            '10분 후',
          ),
          DarwinNotificationAction.plain(
            NotificationActions.snooze30,
            '30분 후',
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
      DarwinNotificationCategory(
        'urgent_actions',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            NotificationActions.complete,
            '완료',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            NotificationActions.snooze10,
            '10분 후',
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ];

    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: darwinCategories,
    );

    final initSettings = InitializationSettings(
      macOS: darwinSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  /// 알림 응답 처리 (탭 또는 액션 버튼)
  void _onNotificationResponse(NotificationResponse response) {
    final payload = NotificationPayload.decode(response.payload);
    if (payload == null) return;

    final actionId = response.actionId;

    if (actionId == NotificationActions.complete) {
      // 완료 액션
      onActionReceived?.call(payload.todoId, 'complete');
    } else if (actionId == NotificationActions.snooze10) {
      // 10분 후 스누즈
      _scheduleSnooze(payload.todoId, 10);
    } else if (actionId == NotificationActions.snooze30) {
      // 30분 후 스누즈
      _scheduleSnooze(payload.todoId, 30);
    } else if (actionId == NotificationActions.snooze60) {
      // 1시간 후 스누즈
      _scheduleSnooze(payload.todoId, 60);
    } else {
      // 일반 탭 - 앱 열기
      onActionReceived?.call(payload.todoId, 'open');
    }
  }

  /// 스누즈 알림 스케줄링
  Future<void> _scheduleSnooze(String todoId, int minutes) async {
    final snoozeTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    final payload = NotificationPayload(todoId: todoId);

    final details = _getNotificationDetails(
      channel: NotificationChannels.deadline,
      category: 'todo_actions',
    );

    await _notifications.zonedSchedule(
      'snooze_$todoId'.hashCode,
      '스누즈 알림',
      '$minutes분 후 다시 알립니다',
      snoozeTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload.encode(),
    );
  }

  /// 스누즈 알림 (외부에서 호출용)
  Future<void> scheduleSnoozeNotification(Todo todo, int minutes) async {
    final snoozeTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    final payload = NotificationPayload(todoId: todo.id);

    final details = _getNotificationDetails(
      channel: NotificationChannels.deadline,
      category: 'todo_actions',
      priority: todo.priority,
    );

    await _notifications.zonedSchedule(
      'snooze_${todo.id}'.hashCode,
      _getSnoozeTitle(minutes),
      todo.title,
      snoozeTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload.encode(),
    );
  }

  String _getSnoozeTitle(int minutes) {
    if (minutes >= 60) {
      return '${minutes ~/ 60}시간 후 알림';
    }
    return '$minutes분 후 알림';
  }

  Future<bool> requestPermission() async {
    final macOS = _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

    if (macOS != null) {
      final granted = await macOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// 채널 및 우선순위에 따른 알림 상세 설정
  NotificationDetails _getNotificationDetails({
    required String channel,
    String? category,
    Priority priority = Priority.medium,
  }) {
    // 우선순위에 따른 알림 설정
    final bool critical = priority == Priority.veryHigh || priority == Priority.high;

    return NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: critical ? 'urgent_sound.aiff' : null, // 커스텀 사운드 (있을 경우)
        threadIdentifier: channel,
        categoryIdentifier: category ?? 'todo_actions',
        interruptionLevel: critical
            ? InterruptionLevel.critical
            : InterruptionLevel.active,
      ),
    );
  }

  Future<void> scheduleTodoNotification(Todo todo) async {
    if (todo.dueDate == null) return;

    // 기존 알림 취소
    await cancelTodoNotification(todo.id);

    var scheduledDate = tz.TZDateTime.from(todo.dueDate!, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    // 이미 지난 시간이면 스킵
    if (scheduledDate.isBefore(now)) return;

    // DND 시간대 체크 및 조정
    scheduledDate = _adjustForDnd(scheduledDate);

    // 채널 및 카테고리 결정
    final channel = _getChannelForTodo(todo);
    final category = todo.priority == Priority.veryHigh || todo.priority == Priority.high
        ? 'urgent_actions'
        : 'todo_actions';

    final notificationDetails = _getNotificationDetails(
      channel: channel,
      category: category,
      priority: todo.priority,
    );

    final payload = NotificationPayload(todoId: todo.id);

    // 사전 알림 스케줄링
    final reminderOffsets = todo.reminderOffsets ?? [];
    for (final offsetMinutes in reminderOffsets) {
      var reminderDate = scheduledDate.subtract(Duration(minutes: offsetMinutes));
      if (reminderDate.isAfter(now)) {
        // 사전 알림도 DND 체크
        reminderDate = _adjustForDnd(reminderDate);
        await _scheduleReminder(todo, reminderDate, offsetMinutes, notificationDetails, payload);
      }
    }

    // 반복 설정에 따른 알림 스케줄링
    switch (todo.recurrence) {
      case Recurrence.none:
        await _scheduleOnce(todo, scheduledDate, notificationDetails, payload);
        break;
      case Recurrence.daily:
        await _scheduleDaily(todo, scheduledDate, notificationDetails, payload);
        break;
      case Recurrence.weekly:
        await _scheduleWeekly(todo, scheduledDate, notificationDetails, payload);
        break;
      case Recurrence.monthly:
        await _scheduleMonthly(todo, scheduledDate, notificationDetails, payload);
        break;
      case Recurrence.custom:
        await _scheduleCustomDays(todo, scheduledDate, notificationDetails, payload);
        break;
    }
  }

  /// Todo에 맞는 알림 채널 반환
  String _getChannelForTodo(Todo todo) {
    if (todo.priority == Priority.veryHigh || todo.priority == Priority.high) {
      return NotificationChannels.urgent;
    }
    if (todo.recurrence != Recurrence.none) {
      return NotificationChannels.recurring;
    }
    return NotificationChannels.deadline;
  }

  // 사전 알림 스케줄링
  Future<void> _scheduleReminder(
    Todo todo,
    tz.TZDateTime reminderDate,
    int offsetMinutes,
    NotificationDetails details,
    NotificationPayload payload,
  ) async {
    final reminderText = _getReminderText(offsetMinutes);
    await _notifications.zonedSchedule(
      '${todo.id}_reminder_$offsetMinutes'.hashCode,
      '$reminderText 후 마감',
      todo.title,
      reminderDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: payload.encode(),
    );
  }

  String _getReminderText(int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return '$days일';
    } else if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return '$hours시간';
    } else {
      return '$minutes분';
    }
  }

  Future<void> _scheduleOnce(
    Todo todo,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    NotificationPayload payload,
  ) async {
    await _notifications.zonedSchedule(
      todo.id.hashCode,
      _getTitleForPriority(todo.priority),
      todo.title,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: payload.encode(),
    );
  }

  /// 우선순위에 따른 알림 제목
  String _getTitleForPriority(Priority priority) {
    switch (priority) {
      case Priority.veryHigh:
        return '🔴 긴급 할일';
      case Priority.high:
        return '🟠 중요 할일';
      case Priority.medium:
      case Priority.low:
      case Priority.veryLow:
        return '할 일 알림';
    }
  }

  Future<void> _scheduleDaily(
    Todo todo,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    NotificationPayload payload,
  ) async {
    await _notifications.zonedSchedule(
      todo.id.hashCode,
      '📅 매일 할 일',
      todo.title,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload.encode(),
    );
  }

  Future<void> _scheduleWeekly(
    Todo todo,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    NotificationPayload payload,
  ) async {
    await _notifications.zonedSchedule(
      todo.id.hashCode,
      '📅 매주 할 일',
      todo.title,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload.encode(),
    );
  }

  Future<void> _scheduleMonthly(
    Todo todo,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    NotificationPayload payload,
  ) async {
    await _notifications.zonedSchedule(
      todo.id.hashCode,
      '📅 매월 할 일',
      todo.title,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: payload.encode(),
    );
  }

  Future<void> _scheduleCustomDays(
    Todo todo,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    NotificationPayload payload,
  ) async {
    final recurrenceDays = todo.recurrenceDays ?? [];
    if (recurrenceDays.isEmpty) return;

    // 각 요일별로 알림 스케줄링
    for (int i = 0; i < recurrenceDays.length; i++) {
      final dayOfWeek = recurrenceDays[i];
      final nextDate = _getNextDayOfWeek(scheduledDate, dayOfWeek);

      await _notifications.zonedSchedule(
        '${todo.id}_$dayOfWeek'.hashCode,
        '📅 할 일 알림',
        todo.title,
        nextDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload.encode(),
      );
    }
  }

  tz.TZDateTime _getNextDayOfWeek(tz.TZDateTime from, int targetDay) {
    // targetDay: 0=월, 1=화, ..., 6=일
    // DateTime.weekday: 1=월, 2=화, ..., 7=일
    final targetWeekday = targetDay + 1;
    var date = from;

    while (date.weekday != targetWeekday) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }

  Future<void> cancelTodoNotification(String todoId) async {
    await _notifications.cancel(todoId.hashCode);

    // 스누즈 알림 취소
    await _notifications.cancel('snooze_$todoId'.hashCode);

    // 커스텀 요일 알림도 취소
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel('${todoId}_$i'.hashCode);
    }

    // 사전 알림도 취소 (10분, 30분, 1시간, 1일)
    final reminderOffsets = [10, 30, 60, 1440];
    for (final offset in reminderOffsets) {
      await _notifications.cancel('${todoId}_reminder_$offset'.hashCode);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 일일 미완료 요약 알림 스케줄링
  Future<void> scheduleDailySummary({
    required int hour,
    required int minute,
    required int incompleteCount,
  }) async {
    if (incompleteCount == 0) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 지난 시간이면 다음 날로
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final details = _getNotificationDetails(
      channel: NotificationChannels.summary,
      category: null,
    );

    await _notifications.zonedSchedule(
      'daily_summary'.hashCode,
      '📋 오늘의 미완료 할일',
      '$incompleteCount개의 할일이 남아있습니다',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 일일 요약 알림 취소
  Future<void> cancelDailySummary() async {
    await _notifications.cancel('daily_summary'.hashCode);
  }

  // 즉시 알림 테스트용
  Future<void> showTestNotification() async {
    // 권한 상태 확인
    final macOS = _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

    if (macOS != null) {
      await macOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final payload = NotificationPayload(todoId: 'test');

    final details = _getNotificationDetails(
      channel: NotificationChannels.deadline,
      category: 'todo_actions',
    );

    await _notifications.show(
      0,
      '테스트 알림',
      '알림이 정상적으로 작동합니다!',
      details,
      payload: payload.encode(),
    );
  }

  /// 긴급 알림 테스트
  Future<void> showUrgentTestNotification() async {
    final payload = NotificationPayload(todoId: 'test_urgent');

    final details = _getNotificationDetails(
      channel: NotificationChannels.urgent,
      category: 'urgent_actions',
      priority: Priority.veryHigh,
    );

    await _notifications.show(
      1,
      '🔴 긴급 테스트 알림',
      '긴급 알림이 정상적으로 작동합니다!',
      details,
      payload: payload.encode(),
    );
  }

  /// 포모도로 완료 알림
  Future<void> showFocusCompleteNotification({
    required bool isBreak,
    required int sessionsCompleted,
  }) async {
    final details = NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: NotificationChannels.focus,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    if (isBreak) {
      await _notifications.show(
        'focus_break'.hashCode,
        '☕ 휴식 끝!',
        '다시 집중할 준비가 되셨나요?',
        details,
      );
    } else {
      final emoji = sessionsCompleted >= 4 ? '🏆' : '🍅';
      await _notifications.show(
        'focus_work'.hashCode,
        '$emoji 집중 완료!',
        '$sessionsCompleted번째 세션 완료! 잠시 휴식하세요.',
        details,
      );
    }
  }
}
