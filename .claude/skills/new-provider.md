---
name: new-provider
description: Clean Architecture 구조에 맞는 새 Provider 생성
---

# New Provider Skill (Clean Architecture)

Feature-First 구조에 맞는 Provider를 생성합니다.

## Usage
`/new-provider [FeatureName]` - 새 Provider 생성

## File Location
```
lib/features/[feature]/presentation/providers/[feature]_provider.dart
```

## Templates

### Basic Provider (CRUD)
```dart
// lib/features/[feature]/presentation/providers/[feature]_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/[feature]_model.dart';
import '../../data/repositories/[feature]_repository_impl.dart';

class [Feature]Provider extends ChangeNotifier {
  final [Feature]Repository _repository;

  [Feature]Provider(this._repository);

  // State
  List<[Feature]Model> _items = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<[Feature]Model> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  int get itemCount => _items.length;
  bool get hasItems => _items.isNotEmpty;

  // CRUD Operations
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getAll();
    } catch (e) {
      _error = '데이터를 불러오는데 실패했습니다: ${e.toString()}';
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
      _error = '추가에 실패했습니다: ${e.toString()}';
      notifyListeners();
      rethrow;
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
      _error = '수정에 실패했습니다: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.delete(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _error = '삭제에 실패했습니다: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  [Feature]Model? getById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### Provider with Filtering/Sorting
```dart
class [Feature]Provider extends ChangeNotifier {
  final [Feature]Repository _repository;

  [Feature]Provider(this._repository);

  // State
  List<[Feature]Model> _items = [];
  List<[Feature]Model> _filteredItems = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  String _searchQuery = '';
  [Feature]Filter _currentFilter = [Feature]Filter.all;
  [Feature]Sort _currentSort = [Feature]Sort.dateDesc;

  // Getters
  List<[Feature]Model> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  [Feature]Filter get currentFilter => _currentFilter;
  [Feature]Sort get currentSort => _currentSort;

  // Filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setFilter([Feature]Filter filter) {
    _currentFilter = filter;
    _applyFilters();
  }

  void setSort([Feature]Sort sort) {
    _currentSort = sort;
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<[Feature]Model>.from(_items);

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result.where((item) =>
        item.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filter
    switch (_currentFilter) {
      case [Feature]Filter.all:
        break;
      case [Feature]Filter.active:
        result = result.where((item) => item.isActive).toList();
        break;
      case [Feature]Filter.completed:
        result = result.where((item) => item.isCompleted).toList();
        break;
    }

    // Sort
    switch (_currentSort) {
      case [Feature]Sort.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case [Feature]Sort.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case [Feature]Sort.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    _filteredItems = result;
    notifyListeners();
  }

  // ... CRUD methods same as above
}

// Enums (별도 파일 또는 같은 파일)
enum [Feature]Filter { all, active, completed }
enum [Feature]Sort { dateAsc, dateDesc, nameAsc }
```

### Provider with Selection
```dart
class [Feature]Provider extends ChangeNotifier {
  final [Feature]Repository _repository;

  [Feature]Provider(this._repository);

  // State
  List<[Feature]Model> _items = [];
  Set<String> _selectedIds = {};
  bool _isLoading = false;
  bool _isSelectionMode = false;

  // Getters
  List<[Feature]Model> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedIds.length;
  bool get hasSelection => _selectedIds.isNotEmpty;
  List<[Feature]Model> get selectedItems =>
    _items.where((i) => _selectedIds.contains(i.id)).toList();

  // Selection methods
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds = _items.map((i) => i.id).toSet();
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  bool isSelected(String id) => _selectedIds.contains(id);

  Future<void> deleteSelected() async {
    for (final id in _selectedIds.toList()) {
      await _repository.delete(id);
      _items.removeWhere((i) => i.id == id);
    }
    _selectedIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // ... CRUD methods same as above
}
```

## Registration in main.dart

### Manual Setup
```dart
// 1. Import
import 'features/[feature]/data/datasources/[feature]_local_datasource.dart';
import 'features/[feature]/data/repositories/[feature]_repository_impl.dart';
import 'features/[feature]/presentation/providers/[feature]_provider.dart';

// 2. Initialize (in main)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DataSource
  final [feature]DataSource = [Feature]LocalDataSourceImpl();
  await [feature]DataSource.init();

  // Repository
  final [feature]Repository = [Feature]Repository([feature]DataSource);

  // Provider
  final [feature]Provider = [Feature]Provider([feature]Repository);

  runApp(MyApp([feature]Provider: [feature]Provider));
}

// 3. Add to MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: [feature]Provider),
  ],
  child: const App(),
)
```

### With get_it (Recommended for large apps)
```dart
// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - [Feature]
  // Provider
  sl.registerFactory(() => [Feature]Provider(sl()));

  // Repository
  sl.registerLazySingleton<[Feature]Repository>(
    () => [Feature]RepositoryImpl(sl()),
  );

  // DataSource
  sl.registerLazySingleton<[Feature]LocalDataSource>(
    () => [Feature]LocalDataSourceImpl(),
  );
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection.init();
  runApp(const MyApp());
}
```

## Best Practices

### DO
- Repository를 통해서만 데이터 접근
- try-catch로 에러 처리
- 상태 변경 후 항상 notifyListeners() 호출
- Computed properties 활용

### DON'T
- Provider에서 직접 Hive Box 접근
- UI 코드 포함
- 다른 Provider 직접 참조 (필요시 ProxyProvider 사용)

## Checklist
- [ ] Provider 파일 생성
- [ ] Repository 주입 설정
- [ ] CRUD 메서드 구현
- [ ] 에러 처리 구현
- [ ] main.dart에 등록
