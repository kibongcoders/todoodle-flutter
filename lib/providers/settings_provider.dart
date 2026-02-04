import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _notificationKey = 'notificationEnabled';
  static const _dndEnabledKey = 'dndEnabled';
  static const _dndStartHourKey = 'dndStartHour';
  static const _dndStartMinuteKey = 'dndStartMinute';
  static const _dndEndHourKey = 'dndEndHour';
  static const _dndEndMinuteKey = 'dndEndMinute';
  static const _dailySummaryEnabledKey = 'dailySummaryEnabled';
  static const _dailySummaryHourKey = 'dailySummaryHour';
  static const _dailySummaryMinuteKey = 'dailySummaryMinute';

  late Box _box;
  bool _notificationEnabled = true;
  bool _dndEnabled = false;
  TimeOfDay _dndStartTime = const TimeOfDay(hour: 22, minute: 0); // 밤 10시
  TimeOfDay _dndEndTime = const TimeOfDay(hour: 8, minute: 0);    // 아침 8시
  bool _dailySummaryEnabled = false;
  TimeOfDay _dailySummaryTime = const TimeOfDay(hour: 21, minute: 0); // 밤 9시

  bool get notificationEnabled => _notificationEnabled;
  bool get dndEnabled => _dndEnabled;
  TimeOfDay get dndStartTime => _dndStartTime;
  TimeOfDay get dndEndTime => _dndEndTime;
  bool get dailySummaryEnabled => _dailySummaryEnabled;
  TimeOfDay get dailySummaryTime => _dailySummaryTime;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _notificationEnabled = _box.get(_notificationKey, defaultValue: true);
    _dndEnabled = _box.get(_dndEnabledKey, defaultValue: false);
    _dndStartTime = TimeOfDay(
      hour: _box.get(_dndStartHourKey, defaultValue: 22),
      minute: _box.get(_dndStartMinuteKey, defaultValue: 0),
    );
    _dndEndTime = TimeOfDay(
      hour: _box.get(_dndEndHourKey, defaultValue: 8),
      minute: _box.get(_dndEndMinuteKey, defaultValue: 0),
    );
    _dailySummaryEnabled = _box.get(_dailySummaryEnabledKey, defaultValue: false);
    _dailySummaryTime = TimeOfDay(
      hour: _box.get(_dailySummaryHourKey, defaultValue: 21),
      minute: _box.get(_dailySummaryMinuteKey, defaultValue: 0),
    );
  }

  Future<void> setNotificationEnabled(bool value) async {
    _notificationEnabled = value;
    await _box.put(_notificationKey, value);
    notifyListeners();
  }

  Future<void> setDndEnabled(bool value) async {
    _dndEnabled = value;
    await _box.put(_dndEnabledKey, value);
    notifyListeners();
  }

  Future<void> setDndStartTime(TimeOfDay time) async {
    _dndStartTime = time;
    await _box.put(_dndStartHourKey, time.hour);
    await _box.put(_dndStartMinuteKey, time.minute);
    notifyListeners();
  }

  Future<void> setDndEndTime(TimeOfDay time) async {
    _dndEndTime = time;
    await _box.put(_dndEndHourKey, time.hour);
    await _box.put(_dndEndMinuteKey, time.minute);
    notifyListeners();
  }

  Future<void> setDailySummaryEnabled(bool value) async {
    _dailySummaryEnabled = value;
    await _box.put(_dailySummaryEnabledKey, value);
    notifyListeners();
  }

  Future<void> setDailySummaryTime(TimeOfDay time) async {
    _dailySummaryTime = time;
    await _box.put(_dailySummaryHourKey, time.hour);
    await _box.put(_dailySummaryMinuteKey, time.minute);
    notifyListeners();
  }

  // 현재 시간이 방해금지 시간대인지 확인
  bool isInDndPeriod([DateTime? dateTime]) {
    if (!_dndEnabled) return false;

    final now = dateTime ?? DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = _dndStartTime.hour * 60 + _dndStartTime.minute;
    final endMinutes = _dndEndTime.hour * 60 + _dndEndTime.minute;

    if (startMinutes <= endMinutes) {
      // 같은 날 내 범위 (예: 09:00 ~ 17:00)
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // 자정을 넘는 범위 (예: 22:00 ~ 08:00)
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  // 방해금지 시간 문자열 표시
  String get dndTimeRangeText {
    String formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${formatTime(_dndStartTime)} ~ ${formatTime(_dndEndTime)}';
  }
}
