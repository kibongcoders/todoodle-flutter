import 'package:hive/hive.dart';

part 'plant.g.dart';

@HiveType(typeId: 4)
enum PlantType {
  @HiveField(0)
  grass, // 풀 (3단계)
  @HiveField(1)
  flower, // 꽃 (4단계)
  @HiveField(2)
  tree, // 나무 (5단계)
}

@HiveType(typeId: 5)
class Plant extends HiveObject {
  Plant({
    required this.id,
    required this.type,
    this.growthStage = 0,
    required this.createdAt,
    this.completedAt,
    this.isFullyGrown = false,
    required this.positionX,
    required this.positionY,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final PlantType type;

  @HiveField(2)
  int growthStage; // 현재 성장 단계 (0부터 시작)

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime? completedAt; // 다 자란 시간

  @HiveField(5)
  bool isFullyGrown; // 다 자랐는지 여부

  @HiveField(6)
  int positionX; // 숲에서의 X 위치 (0-100%)

  @HiveField(7)
  int positionY; // 숲에서의 Y 위치 (0-100%)

  // 최대 성장 단계 (식물 종류별로 다름)
  int get maxGrowthStage {
    switch (type) {
      case PlantType.grass:
        return 3; // 씨앗 -> 새싹 -> 풀 -> 무성한 풀
      case PlantType.flower:
        return 4; // 씨앗 -> 새싹 -> 줄기 -> 봉오리 -> 꽃
      case PlantType.tree:
        return 5; // 씨앗 -> 새싹 -> 묘목 -> 어린나무 -> 나무 -> 거목
    }
  }

  // 현재 성장 상태 이름
  String get growthStageName {
    if (growthStage == 0) return '씨앗';

    switch (type) {
      case PlantType.grass:
        return _getGrassStageName();
      case PlantType.flower:
        return _getFlowerStageName();
      case PlantType.tree:
        return _getTreeStageName();
    }
  }

  String _getGrassStageName() {
    switch (growthStage) {
      case 1:
        return '새싹';
      case 2:
        return '풀';
      case 3:
        return '무성한 풀';
      default:
        return '씨앗';
    }
  }

  String _getFlowerStageName() {
    switch (growthStage) {
      case 1:
        return '새싹';
      case 2:
        return '줄기';
      case 3:
        return '봉오리';
      case 4:
        return '만개한 꽃';
      default:
        return '씨앗';
    }
  }

  String _getTreeStageName() {
    switch (growthStage) {
      case 1:
        return '새싹';
      case 2:
        return '묘목';
      case 3:
        return '어린 나무';
      case 4:
        return '나무';
      case 5:
        return '거목';
      default:
        return '씨앗';
    }
  }

  // 식물 종류 이름
  String get typeName {
    switch (type) {
      case PlantType.grass:
        return '풀';
      case PlantType.flower:
        return '꽃';
      case PlantType.tree:
        return '나무';
    }
  }

  // 성장 진행률 (0.0 ~ 1.0)
  double get growthProgress => growthStage / maxGrowthStage;
}
