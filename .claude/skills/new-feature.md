---
name: new-feature
description: Clean Architecture + Feature-First 구조로 새 기능 생성
---

# New Feature Skill (Clean Architecture)

Feature-First + Clean Architecture 구조로 새로운 기능을 생성합니다.

## Usage
`/new-feature [FeatureName]` - 새 기능 전체 구조 생성

## Generated Structure
```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   └── [feature]_local_datasource.dart
│   ├── models/
│   │   └── [feature]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/                    # 복잡한 로직 필요시만
│   ├── entities/
│   │   └── [feature]_entity.dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── usecases/
│       └── get_[feature]s.dart
└── presentation/
    ├── providers/
    │   └── [feature]_provider.dart
    ├── pages/
    │   └── [feature]_page.dart
    └── widgets/
        └── [feature]_item.dart
```

## Templates

### 1. Data Layer - Model
```dart
// lib/features/[feature]/data/models/[feature]_model.dart
import 'package:hive/hive.dart';

part '[feature]_model.g.dart';

@HiveType(typeId: [NEXT_ID]) // 10+
class [Feature]Model extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  [Feature]Model({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  [Feature]Model copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return [Feature]Model(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 2. Data Layer - Local DataSource
```dart
// lib/features/[feature]/data/datasources/[feature]_local_datasource.dart
import 'package:hive/hive.dart';
import '../models/[feature]_model.dart';

abstract class [Feature]LocalDataSource {
  Future<List<[Feature]Model>> getAll();
  Future<[Feature]Model?> getById(String id);
  Future<void> save([Feature]Model item);
  Future<void> delete(String id);
}

class [Feature]LocalDataSourceImpl implements [Feature]LocalDataSource {
  static const _boxName = '[feature]s';
  late Box<[Feature]Model> _box;

  Future<void> init() async {
    _box = await Hive.openBox<[Feature]Model>(_boxName);
  }

  @override
  Future<List<[Feature]Model>> getAll() async {
    return _box.values.toList();
  }

  @override
  Future<[Feature]Model?> getById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> save([Feature]Model item) async {
    await _box.put(item.id, item);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
```

### 3. Data Layer - Repository Implementation
```dart
// lib/features/[feature]/data/repositories/[feature]_repository_impl.dart
import '../datasources/[feature]_local_datasource.dart';
import '../models/[feature]_model.dart';

class [Feature]Repository {
  final [Feature]LocalDataSource _localDataSource;

  [Feature]Repository(this._localDataSource);

  Future<List<[Feature]Model>> getAll() => _localDataSource.getAll();

  Future<[Feature]Model?> getById(String id) => _localDataSource.getById(id);

  Future<void> save([Feature]Model item) => _localDataSource.save(item);

  Future<void> delete(String id) => _localDataSource.delete(id);
}
```

### 4. Presentation - Provider
```dart
// lib/features/[feature]/presentation/providers/[feature]_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/[feature]_model.dart';
import '../../data/repositories/[feature]_repository_impl.dart';

class [Feature]Provider extends ChangeNotifier {
  final [Feature]Repository _repository;

  [Feature]Provider(this._repository);

  List<[Feature]Model> _items = [];
  List<[Feature]Model> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem([Feature]Model item) async {
    try {
      await _repository.save(item);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateItem([Feature]Model item) async {
    try {
      await _repository.save(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.delete(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### 5. Presentation - Page
```dart
// lib/features/[feature]/presentation/pages/[feature]_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/[feature]_provider.dart';
import '../widgets/[feature]_item.dart';

class [Feature]Page extends StatefulWidget {
  const [Feature]Page({super.key});

  @override
  State<[Feature]Page> createState() => _[Feature]PageState();
}

class _[Feature]PageState extends State<[Feature]Page> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<[Feature]Provider>().loadItems()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Feature]'),
      ),
      body: Consumer<[Feature]Provider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('오류: ${provider.error}'));
          }

          if (provider.items.isEmpty) {
            return const Center(child: Text('항목이 없습니다'));
          }

          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              return [Feature]Item(item: provider.items[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // TODO: Implement add dialog
  }
}
```

### 6. Presentation - Widget
```dart
// lib/features/[feature]/presentation/widgets/[feature]_item.dart
import 'package:flutter/material.dart';
import '../../data/models/[feature]_model.dart';

class [Feature]Item extends StatelessWidget {
  final [Feature]Model item;

  const [Feature]Item({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('생성: ${item.createdAt.toString().substring(0, 10)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // TODO: Delete action
          },
        ),
      ),
    );
  }
}
```

## Registration in main.dart
```dart
// 1. Import
import 'features/[feature]/data/datasources/[feature]_local_datasource.dart';
import 'features/[feature]/data/repositories/[feature]_repository_impl.dart';
import 'features/[feature]/presentation/providers/[feature]_provider.dart';

// 2. Initialize (in main)
final [feature]DataSource = [Feature]LocalDataSourceImpl();
await [feature]DataSource.init();
final [feature]Repository = [Feature]Repository([feature]DataSource);
final [feature]Provider = [Feature]Provider([feature]Repository);

// 3. Add to MultiProvider
ChangeNotifierProvider.value(value: [feature]Provider),
```

## After Creation
```bash
# Hive adapter 생성
dart run build_runner build --delete-conflicting-outputs
```

## Hive TypeId Registry
| ID | Model | ID | Model |
|----|-------|----|-------|
| 0 | Todo | 5 | Plant |
| 1 | Priority | 6 | FocusSessionType |
| 2 | Recurrence | 7 | FocusSession |
| 3 | TodoCategoryModel | 8 | TodoTemplate |
| 4 | PlantType | 9 | TemplateItem |

**다음 사용 가능: 10+**
