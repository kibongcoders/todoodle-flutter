import 'dart:ui' show Color;

import 'package:hive/hive.dart';

import '../core/constants/doodle_colors.dart';

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

  @HiveField(3)
  rare, // 희귀 낙서 (레벨 해금)
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

  // Rare (희귀 - 레벨 해금)
  @HiveField(12)
  rainbowStar, // 무지개 별 (레벨 10)

  @HiveField(13)
  crown, // 왕관 (레벨 20)

  @HiveField(14)
  diamond, // 다이아몬드 (레벨 30)
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
    this.colorIndex,
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

  @HiveField(8)
  int? colorIndex; // 크레파스 색상 인덱스 (null = 기본 연필)

  /// 크레파스 색상 반환 (null이면 기본 연필색)
  Color? get crayonColor =>
      colorIndex != null ? DoodleColors.crayonPalette[colorIndex!] : null;

  /// 낙서 카테고리 반환 (DoodleTypeExtension에 위임)
  DoodleCategory get category => type.category;

  /// 최대 획 수 (DoodleTypeExtension에 위임)
  int get maxStrokes => type.maxStrokes;

  /// 진행률 (0.0 ~ 1.0)
  double get progress => currentStroke / maxStrokes;

  /// 낙서 타입 한글 이름 (DoodleTypeExtension에 위임)
  String get typeName => type.typeName;

  /// 카테고리 한글 이름 (DoodleCategoryExtension에 위임)
  String get categoryName => category.displayName;

  /// 희귀 낙서 여부
  bool get isRare => type.isRare;

  /// 현재 상태 설명
  String get statusDescription {
    if (isCompleted) {
      return '$typeName 완성!';
    }
    return '$typeName 그리는 중 ($currentStroke/$maxStrokes획)';
  }
}

/// DoodleCategory 확장 메서드
extension DoodleCategoryExtension on DoodleCategory {
  /// 카테고리 한글 이름
  String get displayName {
    switch (this) {
      case DoodleCategory.simple:
        return '간단';
      case DoodleCategory.medium:
        return '보통';
      case DoodleCategory.complex:
        return '복잡';
      case DoodleCategory.rare:
        return '희귀';
    }
  }
}

/// DoodleType 확장 메서드 (단일 소스)
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
      case DoodleType.rainbowStar:
      case DoodleType.crown:
      case DoodleType.diamond:
        return DoodleCategory.rare;
    }
  }

  /// 최대 획 수
  int get maxStrokes {
    switch (this) {
      case DoodleType.star:
      case DoodleType.heart:
      case DoodleType.cloud:
      case DoodleType.moon:
        return 3;
      case DoodleType.house:
      case DoodleType.flower:
      case DoodleType.boat:
      case DoodleType.balloon:
      case DoodleType.rainbowStar:
        return 5;
      case DoodleType.crown:
        return 6;
      case DoodleType.diamond:
        return 7;
      case DoodleType.tree:
      case DoodleType.bicycle:
      case DoodleType.rocket:
      case DoodleType.cat:
        return 8;
    }
  }

  /// 낙서 타입 한글 이름
  String get typeName {
    switch (this) {
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
      case DoodleType.rainbowStar:
        return '무지개 별';
      case DoodleType.crown:
        return '왕관';
      case DoodleType.diamond:
        return '다이아몬드';
    }
  }

  /// 카테고리 한글 이름
  String get categoryName => category.displayName;

  /// 희귀 낙서 여부
  bool get isRare => category == DoodleCategory.rare;

  /// 희귀 낙서 해금에 필요한 레벨 (일반 낙서는 null)
  int? get requiredLevel {
    switch (this) {
      case DoodleType.rainbowStar:
        return 10;
      case DoodleType.crown:
        return 20;
      case DoodleType.diamond:
        return 30;
      default:
        return null;
    }
  }
}
