import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/plant.dart';

class ForestProvider extends ChangeNotifier {
  static const String _plantsBoxName = 'plants';
  static const String _statsBoxName = 'forest_stats';
  static const String _currentPlantKey = 'current_plant_id';

  late Box<Plant> _plantsBox;
  late Box _statsBox;
  final _uuid = const Uuid();
  final _random = Random();

  Plant? _currentPlant;
  bool _initialized = false;

  /// 식물이 다 자랐을 때 호출되는 콜백
  Function(int totalPlantsGrown)? onPlantFullyGrown;

  // Getters
  Plant? get currentPlant => _currentPlant;
  bool get initialized => _initialized;

  // 다 자란 식물들 (숲에 표시할 것들)
  List<Plant> get forestPlants => _plantsBox.values
      .where((p) => p.isFullyGrown)
      .toList()
    ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

  // 통계
  int get totalPlantsGrown => _statsBox.get('totalPlantsGrown', defaultValue: 0);
  int get totalTodosCompleted =>
      _statsBox.get('totalTodosCompleted', defaultValue: 0);
  int get currentStreak => _statsBox.get('currentStreak', defaultValue: 0);
  DateTime? get lastGrowthDate => _statsBox.get('lastGrowthDate');

  // 초기화
  Future<void> init() async {
    _plantsBox = await Hive.openBox<Plant>(_plantsBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);

    _loadCurrentPlant();

    // 현재 식물이 없으면 새로 생성
    if (_currentPlant == null) {
      _startNewPlant();
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadCurrentPlant() {
    final currentId = _statsBox.get(_currentPlantKey);
    if (currentId != null) {
      _currentPlant = _plantsBox.get(currentId);
      // 이미 다 자란 경우 새 식물 필요
      if (_currentPlant?.isFullyGrown == true) {
        _currentPlant = null;
      }
    }
  }

  // 새 식물 시작 (랜덤 종류)
  void _startNewPlant() {
    const types = PlantType.values;
    final randomType = types[_random.nextInt(types.length)];

    // 랜덤 위치 생성 (기존 식물과 겹치지 않게)
    final position = _generateUniquePosition();

    final plant = Plant(
      id: _uuid.v4(),
      type: randomType,
      createdAt: DateTime.now(),
      positionX: position.$1,
      positionY: position.$2,
    );

    _plantsBox.put(plant.id, plant);
    _statsBox.put(_currentPlantKey, plant.id);
    _currentPlant = plant;
  }

  (int, int) _generateUniquePosition() {
    const minDistance = 15;
    const maxAttempts = 50;

    for (int i = 0; i < maxAttempts; i++) {
      final x = _random.nextInt(80) + 10; // 10-90 범위
      final y = _random.nextInt(40) + 30; // 30-70 범위 (땅 영역)

      bool valid = true;
      for (final plant in forestPlants) {
        final dx = (plant.positionX - x).abs();
        final dy = (plant.positionY - y).abs();
        if (dx < minDistance && dy < minDistance) {
          valid = false;
          break;
        }
      }

      if (valid) return (x, y);
    }

    // 모든 시도 실패시 랜덤 위치
    return (_random.nextInt(80) + 10, _random.nextInt(40) + 30);
  }

  // 할일 완료시 호출 - 식물 성장
  Future<bool> growPlant() async {
    if (_currentPlant == null) {
      _startNewPlant();
    }

    final plant = _currentPlant!;
    plant.growthStage++;

    // 통계 업데이트
    await _statsBox.put(
        'totalTodosCompleted', totalTodosCompleted + 1);
    await _updateStreak();

    // 다 자랐는지 확인
    if (plant.growthStage >= plant.maxGrowthStage) {
      plant.isFullyGrown = true;
      plant.completedAt = DateTime.now();
      final newTotal = totalPlantsGrown + 1;
      await _statsBox.put('totalPlantsGrown', newTotal);
      await plant.save();

      // 콜백 호출 (업적 체크용)
      onPlantFullyGrown?.call(newTotal);

      // 새 식물 시작
      _startNewPlant();
      notifyListeners();
      return true; // 식물이 다 자람
    }

    await plant.save();
    notifyListeners();
    return false; // 아직 성장 중
  }

  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = lastGrowthDate;

    if (lastDate != null) {
      final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(lastDateOnly).inDays;

      if (diff == 1) {
        // 어제 성장했으면 연속 증가
        await _statsBox.put('currentStreak', currentStreak + 1);
      } else if (diff > 1) {
        // 하루 이상 건너뛰면 리셋
        await _statsBox.put('currentStreak', 1);
      }
      // diff == 0 이면 같은 날이므로 streak 유지
    } else {
      // 첫 성장
      await _statsBox.put('currentStreak', 1);
    }

    await _statsBox.put('lastGrowthDate', now);
  }

  // 풀 개수
  int get grassCount =>
      forestPlants.where((p) => p.type == PlantType.grass).length;

  // 꽃 개수
  int get flowerCount =>
      forestPlants.where((p) => p.type == PlantType.flower).length;

  // 나무 개수
  int get treeCount =>
      forestPlants.where((p) => p.type == PlantType.tree).length;
}
