---
name: hive-model
description: Clean Architecture 구조에 맞는 새 Hive Model 생성
---

# Hive Model Skill (Clean Architecture)

Feature-First 구조에 맞는 Hive 데이터 모델을 생성합니다.

## Usage
`/hive-model [FeatureName] [ModelName]` - 새 모델 생성

## File Location
```
lib/features/[feature]/data/models/[model_name]_model.dart
```

## Current TypeId Registry

| ID | Model | ID | Model |
|----|-------|----|-------|
| 0 | Todo | 5 | Plant |
| 1 | Priority | 6 | FocusSessionType |
| 2 | Recurrence | 7 | FocusSession |
| 3 | TodoCategoryModel | 8 | TodoTemplate |
| 4 | PlantType | 9 | TemplateItem |

**다음 사용 가능: 10+**

## Templates

### Basic Model
```dart
// lib/features/[feature]/data/models/[model_name]_model.dart
import 'package:hive/hive.dart';

part '[model_name]_model.g.dart';

@HiveType(typeId: [NEXT_ID]) // 10부터 시작
class [ModelName]Model extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime? updatedAt;

  [ModelName]Model({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });

  [ModelName]Model copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return [ModelName]Model(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is [ModelName]Model &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '[ModelName]Model(id: $id, name: $name)';
}
```

### Model with Enum Field
```dart
import 'package:hive/hive.dart';

part '[model_name]_model.g.dart';

// Enum은 별도 TypeId 필요
@HiveType(typeId: [NEXT_ID])
enum [ModelName]Status {
  @HiveField(0)
  pending,

  @HiveField(1)
  active,

  @HiveField(2)
  completed,

  @HiveField(3)
  cancelled,
}

@HiveType(typeId: [NEXT_ID + 1])
class [ModelName]Model extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  [ModelName]Status status;

  @HiveField(3)
  final DateTime createdAt;

  [ModelName]Model({
    required this.id,
    required this.name,
    this.status = [ModelName]Status.pending,
    required this.createdAt,
  });

  bool get isPending => status == [ModelName]Status.pending;
  bool get isActive => status == [ModelName]Status.active;
  bool get isCompleted => status == [ModelName]Status.completed;

  [ModelName]Model copyWith({
    String? id,
    String? name,
    [ModelName]Status? status,
    DateTime? createdAt,
  }) {
    return [ModelName]Model(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### Model with Nested Object
```dart
import 'package:hive/hive.dart';

part '[model_name]_model.g.dart';

// 중첩 객체도 별도 TypeId 필요
@HiveType(typeId: [NEXT_ID])
class [Child]Model extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String value;

  [Child]Model({required this.id, required this.value});
}

@HiveType(typeId: [NEXT_ID + 1])
class [Parent]Model extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<[Child]Model> children;

  [Parent]Model({
    required this.id,
    required this.name,
    this.children = const [],
  });

  [Parent]Model copyWith({
    String? id,
    String? name,
    List<[Child]Model>? children,
  }) {
    return [Parent]Model(
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
    );
  }
}
```

### Model with Entity Conversion (Clean Architecture)
```dart
import 'package:hive/hive.dart';
import '../../domain/entities/[model_name]_entity.dart';

part '[model_name]_model.g.dart';

@HiveType(typeId: [NEXT_ID])
class [ModelName]Model extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  [ModelName]Model({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // Entity로 변환 (Data → Domain)
  [ModelName]Entity toEntity() {
    return [ModelName]Entity(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }

  // Entity에서 생성 (Domain → Data)
  factory [ModelName]Model.fromEntity([ModelName]Entity entity) {
    return [ModelName]Model(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }

  // JSON 변환 (API 연동용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory [ModelName]Model.fromJson(Map<String, dynamic> json) {
    return [ModelName]Model(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
```

## Registration

### 1. Register Adapter in main.dart
```dart
import 'features/[feature]/data/models/[model_name]_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  // Adapter 등록 (중복 등록 방지)
  if (!Hive.isAdapterRegistered([NEXT_ID])) {
    Hive.registerAdapter([ModelName]ModelAdapter());
  }
  // Enum이 있는 경우
  if (!Hive.isAdapterRegistered([NEXT_ID - 1])) {
    Hive.registerAdapter([ModelName]StatusAdapter());
  }

  runApp(const MyApp());
}
```

### 2. Generate Adapter
```bash
dart run build_runner build --delete-conflicting-outputs
```

## TypeId 관리 가이드

### 규칙
1. **절대 기존 TypeId 재사용 금지** - 데이터 손상 위험
2. **순차적으로 할당** - 관리 용이
3. **Enum도 별도 TypeId 필요**
4. **중첩 객체도 별도 TypeId 필요**

### TypeId 할당 예시
```
Feature: Shopping Cart
- CartItemStatus (enum): 10
- CartItem (model): 11
- Cart (model): 12

Feature: Notification
- NotificationType (enum): 13
- Notification (model): 14
```

## Common Issues & Fixes

### HiveError: TypeAdapter already exists
```dart
// 문제: 중복 TypeId
// 해결: TypeId Registry 확인 후 고유한 ID 사용
@HiveType(typeId: 15) // 새로운 고유 ID
```

### HiveError: Cannot read, unknown typeId
```dart
// 문제: Adapter 미등록
// 해결: main.dart에서 Adapter 등록
Hive.registerAdapter([ModelName]ModelAdapter());
```

### Field order matters for migration
```dart
// 기존 모델에 필드 추가 시 마지막에 추가
@HiveField(4) // 새 필드는 마지막 인덱스 + 1
String? newField;
```

## Checklist
- [ ] Model 파일 생성
- [ ] TypeId 고유성 확인
- [ ] HiveField 인덱스 순차적 확인
- [ ] copyWith 메서드 구현
- [ ] build_runner 실행
- [ ] main.dart에 Adapter 등록
- [ ] TypeId Registry 업데이트 (CLAUDE.md)
