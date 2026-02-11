import 'package:hive/hive.dart';

part 'doodle.g.dart';

/// 낙서 카테고리 (복잡도에 따른 분류)
@HiveType(typeId: 12)
enum DoodleCategory {
  @HiveField(0)
  simple, // 3획 - 간단한 도형

  @HiveField(1)
  medium, // 5획 - 중간 복잡도

  @HiveField(2)
  complex, // 8획 - 복잡한 그림
}

/// 낙서 종류
@HiveType(typeId: 13)
enum DoodleType {
  // Simple (3획)
  @HiveField(0)
  star, // 별

  @HiveField(1)
  heart, // 하트

  @HiveField(2)
  cloud, // 구름

  @HiveField(3)
  moon, // 달

  // Medium (5획)
  @HiveField(4)
  house, // 집

  @HiveField(5)
  flower, // 꽃

  @HiveField(6)
  boat, // 배

  @HiveField(7)
  balloon, // 풍선

  // Complex (8획)
  @HiveField(8)
  tree, // 나무

  @HiveField(9)
  bicycle, // 자전거

  @HiveField(10)
  rocket, // 로켓

  @HiveField(11)
  cat, // 고양이
}

/// 스케치북의 낙서 모델
@HiveType(typeId: 14)
class Doodle extends HiveObject {
  Doodle({
    required this.id,
    required this.type,
    this.currentStroke = 0,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
    required this.pageIndex,
    this.positionIndex = 0,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DoodleType type;

  @HiveField(2)
  int currentStroke; // 현재 획 수

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime? completedAt; // 완성 시간

  @HiveField(5)
  bool isCompleted; // 완성 여부

  @HiveField(6)
  int pageIndex; // 스케치북 페이지 번호 (0부터 시작)

  @HiveField(7)
  int positionIndex; // 페이지 내 위치 (0-3, 한 페이지에 4개)

  /// 낙서 카테고리 반환
  DoodleCategory get category {
    switch (type) {
      case DoodleType.star:
      case DoodleType.heart:
      case DoodleType.cloud:
      case DoodleType.moon:
        return DoodleCategory.simple;
      case DoodleType.house:
      case DoodleType.flower:
      case DoodleType.boat:
      case DoodleType.balloon:
        return DoodleCategory.medium;
      case DoodleType.tree:
      case DoodleType.bicycle:
      case DoodleType.rocket:
      case DoodleType.cat:
        return DoodleCategory.complex;
    }
  }

  /// 최대 획 수 (카테고리별)
  int get maxStrokes {
    switch (category) {
      case DoodleCategory.simple:
        return 3;
      case DoodleCategory.medium:
        return 5;
      case DoodleCategory.complex:
        return 8;
    }
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress => currentStroke / maxStrokes;

  /// 낙서 타입 한글 이름
  String get typeName {
    switch (type) {
      case DoodleType.star:
        return '별';
      case DoodleType.heart:
        return '하트';
      case DoodleType.cloud:
        return '구름';
      case DoodleType.moon:
        return '달';
      case DoodleType.house:
        return '집';
      case DoodleType.flower:
        return '꽃';
      case DoodleType.boat:
        return '배';
      case DoodleType.balloon:
        return '풍선';
      case DoodleType.tree:
        return '나무';
      case DoodleType.bicycle:
        return '자전거';
      case DoodleType.rocket:
        return '로켓';
      case DoodleType.cat:
        return '고양이';
    }
  }

  /// 카테고리 한글 이름
  String get categoryName {
    switch (category) {
      case DoodleCategory.simple:
        return '간단';
      case DoodleCategory.medium:
        return '보통';
      case DoodleCategory.complex:
        return '복잡';
    }
  }

  /// 현재 상태 설명
  String get statusDescription {
    if (isCompleted) {
      return '$typeName 완성!';
    }
    return '$typeName 그리는 중 ($currentStroke/$maxStrokes획)';
  }
}

/// DoodleType 확장 메서드
extension DoodleTypeExtension on DoodleType {
  /// 해당 타입의 카테고리 반환
  DoodleCategory get category {
    switch (this) {
      case DoodleType.star:
      case DoodleType.heart:
      case DoodleType.cloud:
      case DoodleType.moon:
        return DoodleCategory.simple;
      case DoodleType.house:
      case DoodleType.flower:
      case DoodleType.boat:
      case DoodleType.balloon:
        return DoodleCategory.medium;
      case DoodleType.tree:
      case DoodleType.bicycle:
      case DoodleType.rocket:
      case DoodleType.cat:
        return DoodleCategory.complex;
    }
  }

  /// 최대 획 수
  int get maxStrokes {
    switch (category) {
      case DoodleCategory.simple:
        return 3;
      case DoodleCategory.medium:
        return 5;
      case DoodleCategory.complex:
        return 8;
    }
  }
}
