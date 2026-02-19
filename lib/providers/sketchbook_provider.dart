import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/sketchbook_theme.dart';
import '../models/doodle.dart';
import 'level_provider.dart';

/// 스케치북 상태 관리 Provider
///
/// 할일 완료 시 낙서에 획을 추가하고,
/// 완성된 낙서들을 스케치북 갤러리로 관리합니다.
class SketchbookProvider extends ChangeNotifier {
  static const String _doodlesBoxName = 'doodles';
  static const String _statsBoxName = 'sketchbook_stats';
  static const String _currentDoodleKey = 'current_doodle_id';
  static const int _doodlesPerPage = 4; // 페이지당 낙서 수

  late Box<Doodle> _doodlesBox;
  late Box _statsBox;
  final _uuid = const Uuid();
  final _random = Random();

  Doodle? _currentDoodle;
  bool _initialized = false;

  /// 낙서가 완성되었을 때 호출되는 콜백
  Function(int totalDoodlesCompleted)? onDoodleCompleted;

  /// 레벨 Provider (희귀 낙서 해금용)
  LevelProvider? _levelProvider;
  void setLevelProvider(LevelProvider provider) {
    _levelProvider = provider;
  }

  // Getters
  Doodle? get currentDoodle => _currentDoodle;
  bool get initialized => _initialized;

  /// 완성된 낙서 목록 (스케치북에 표시)
  List<Doodle> get completedDoodles => _doodlesBox.values
      .where((d) => d.isCompleted)
      .toList()
    ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

  /// 페이지별 낙서 그룹
  Map<int, List<Doodle>> get doodlesByPage {
    final map = <int, List<Doodle>>{};
    for (final doodle in completedDoodles) {
      map.putIfAbsent(doodle.pageIndex, () => []).add(doodle);
    }
    return map;
  }

  /// 현재 총 페이지 수
  int get totalPages {
    if (completedDoodles.isEmpty) return 1;
    return completedDoodles.map((d) => d.pageIndex).reduce(max) + 1;
  }

  // 통계
  int get totalDoodlesCompleted =>
      _statsBox.get('totalDoodlesCompleted', defaultValue: 0);
  int get totalTodosCompleted =>
      _statsBox.get('totalTodosCompleted', defaultValue: 0);
  int get currentStreak => _statsBox.get('currentStreak', defaultValue: 0);
  DateTime? get lastDrawDate => _statsBox.get('lastDrawDate');

  /// 현재 스케치북 테마
  SketchbookTheme get currentTheme {
    final themeStr = _statsBox.get('sketchbook_theme', defaultValue: 'plain');
    return SketchbookTheme.values.firstWhere(
      (t) => t.name == themeStr,
      orElse: () => SketchbookTheme.plain,
    );
  }

  /// 테마 변경
  Future<void> setTheme(SketchbookTheme theme) async {
    await _statsBox.put('sketchbook_theme', theme.name);
    notifyListeners();
  }

  /// 초기화
  Future<void> init() async {
    _doodlesBox = await Hive.openBox<Doodle>(_doodlesBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);

    _loadCurrentDoodle();

    // 현재 낙서가 없으면 새로 생성
    if (_currentDoodle == null) {
      _startNewDoodle();
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadCurrentDoodle() {
    final currentId = _statsBox.get(_currentDoodleKey);
    if (currentId != null) {
      _currentDoodle = _doodlesBox.get(currentId);
      // 이미 완성된 경우 새 낙서 필요
      if (_currentDoodle?.isCompleted == true) {
        _currentDoodle = null;
      }
    }
  }

  /// 새 낙서 시작 (랜덤 종류, 레벨에 따라 희귀 낙서 출현)
  void _startNewDoodle() {
    final randomType = _getRandomType();

    // 페이지와 위치 계산
    final (pageIndex, positionIndex) = _getNextPosition();

    final doodle = Doodle(
      id: _uuid.v4(),
      type: randomType,
      createdAt: DateTime.now(),
      pageIndex: pageIndex,
      positionIndex: positionIndex,
    );

    _doodlesBox.put(doodle.id, doodle);
    _statsBox.put(_currentDoodleKey, doodle.id);
    _currentDoodle = doodle;
  }

  /// 랜덤 낙서 타입 선택 (레벨에 따라 희귀 낙서 포함)
  DoodleType _getRandomType() {
    // 일반 낙서 타입 (12종)
    final normalTypes = DoodleType.values
        .where((t) => Doodle.requiredLevel(t) == null)
        .toList();

    // 레벨 기반 희귀 낙서 후보
    final currentLevel = _levelProvider?.currentLevel ?? 1;
    final eligibleRareTypes = DoodleType.values
        .where((t) {
          final req = Doodle.requiredLevel(t);
          return req != null && currentLevel >= req;
        })
        .toList();

    // 10% 확률로 희귀 낙서 선택
    if (eligibleRareTypes.isNotEmpty && _random.nextDouble() < 0.1) {
      return eligibleRareTypes[_random.nextInt(eligibleRareTypes.length)];
    }

    return normalTypes[_random.nextInt(normalTypes.length)];
  }

  /// 다음 낙서 위치 계산 (페이지, 위치 인덱스)
  (int, int) _getNextPosition() {
    if (completedDoodles.isEmpty) {
      return (0, 0);
    }

    // 마지막 완성된 낙서 기준으로 다음 위치
    final lastDoodle = completedDoodles.last;
    final nextPositionIndex = lastDoodle.positionIndex + 1;

    if (nextPositionIndex >= _doodlesPerPage) {
      // 새 페이지로
      return (lastDoodle.pageIndex + 1, 0);
    } else {
      // 같은 페이지의 다음 위치
      return (lastDoodle.pageIndex, nextPositionIndex);
    }
  }

  /// 할일 완료 시 호출 - 획 추가
  Future<bool> drawStroke() async {
    if (_currentDoodle == null) {
      _startNewDoodle();
    }

    final doodle = _currentDoodle!;
    doodle.currentStroke++;

    // 통계 업데이트
    await _statsBox.put('totalTodosCompleted', totalTodosCompleted + 1);
    await _updateStreak();

    // 완성 확인
    if (doodle.currentStroke >= doodle.maxStrokes) {
      doodle.isCompleted = true;
      doodle.completedAt = DateTime.now();
      final newTotal = totalDoodlesCompleted + 1;
      await _statsBox.put('totalDoodlesCompleted', newTotal);
      await doodle.save();

      // 콜백 호출 (업적 체크용)
      onDoodleCompleted?.call(newTotal);

      // 새 낙서 시작
      _startNewDoodle();
      notifyListeners();
      return true; // 낙서 완성
    }

    await doodle.save();
    notifyListeners();
    return false; // 아직 그리는 중
  }

  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = lastDrawDate;

    if (lastDate != null) {
      final lastDateOnly =
          DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(lastDateOnly).inDays;

      if (diff == 1) {
        // 어제 그렸으면 연속 증가
        await _statsBox.put('currentStreak', currentStreak + 1);
      } else if (diff > 1) {
        // 하루 이상 건너뛰면 리셋
        await _statsBox.put('currentStreak', 1);
      }
      // diff == 0 이면 같은 날이므로 streak 유지
    } else {
      // 첫 획
      await _statsBox.put('currentStreak', 1);
    }

    await _statsBox.put('lastDrawDate', now);
  }

  /// 낙서에 크레파스 색상 적용
  Future<void> colorDoodle(String doodleId, int? colorIndex) async {
    final doodle = _doodlesBox.get(doodleId);
    if (doodle == null || !doodle.isCompleted) return;
    doodle.colorIndex = colorIndex;
    await doodle.save();
    notifyListeners();
  }

  /// 해금된 낙서 타입 목록
  Set<DoodleType> get unlockedTypes {
    return completedDoodles.map((d) => d.type).toSet();
  }

  /// 해금된 타입 수
  int get totalUnlockedTypes => unlockedTypes.length;

  /// 특정 타입의 가장 최근 완성 낙서
  Doodle? getLatestDoodleOfType(DoodleType type) {
    final doodles = completedDoodles.where((d) => d.type == type).toList();
    if (doodles.isEmpty) return null;
    return doodles.last;
  }

  // 카테고리별 완성 낙서 수
  int get simpleCount => completedDoodles
      .where((d) => d.category == DoodleCategory.simple)
      .length;

  int get mediumCount => completedDoodles
      .where((d) => d.category == DoodleCategory.medium)
      .length;

  int get complexCount => completedDoodles
      .where((d) => d.category == DoodleCategory.complex)
      .length;

  // 타입별 완성 낙서 수
  int getCountByType(DoodleType type) =>
      completedDoodles.where((d) => d.type == type).length;

  /// 특정 페이지의 낙서 목록
  List<Doodle> getDoodlesForPage(int pageIndex) {
    return completedDoodles
        .where((d) => d.pageIndex == pageIndex)
        .toList()
      ..sort((a, b) => a.positionIndex.compareTo(b.positionIndex));
  }
}
