# Flutter 최신 개발 방법론 가이드

Todoodle 프로젝트에 적용 가능한 최신 Flutter 개발 방법론입니다.

## 1. Clean Architecture

Uncle Bob의 Clean Architecture를 Flutter에 적용한 구조입니다.

### 계층 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  - Pages/Screens (UI)                                        │
│  - Providers/BLoC (상태 관리)                                │
│  - Widgets (재사용 컴포넌트)                                 │
├─────────────────────────────────────────────────────────────┤
│                      Domain Layer                            │
│  - Entities (비즈니스 객체)                                  │
│  - UseCases (비즈니스 로직)                                  │
│  - Repository Interfaces (추상화)                            │
├─────────────────────────────────────────────────────────────┤
│                       Data Layer                             │
│  - Models (DTO, Hive 모델)                                   │
│  - DataSources (Local/Remote)                                │
│  - Repository Implementations                                │
└─────────────────────────────────────────────────────────────┘
```

### 의존성 규칙

> 안쪽 레이어는 바깥쪽 레이어를 절대 알면 안 된다.

```
Presentation → Domain → Data
     ↓            ↓
  Widgets    Repository Interface
```

### 예시: UseCase 패턴

```dart
// domain/usecases/complete_todo.dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class CompleteTodo implements UseCase<Todo, CompleteTodoParams> {
  final TodoRepository repository;

  CompleteTodo(this.repository);

  @override
  Future<Either<Failure, Todo>> call(CompleteTodoParams params) async {
    return await repository.completeTodo(params.todoId);
  }
}

class CompleteTodoParams extends Equatable {
  final String todoId;
  const CompleteTodoParams({required this.todoId});

  @override
  List<Object> get props => [todoId];
}
```

## 2. MVVM (Model-View-ViewModel)

현재 프로젝트에 적용된 패턴입니다.

### 구조

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    Model     │ ←→ │  ViewModel   │ ←→ │    View      │
│  (Hive DB)   │    │  (Provider)  │    │  (Screen)    │
└──────────────┘    └──────────────┘    └──────────────┘
```

### ViewModel 패턴 (Provider + ChangeNotifier)

```dart
// providers/todo_view_model.dart
class TodoViewModel extends ChangeNotifier {
  // 상태
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  // Getters (View가 읽는 상태)
  List<Todo> get todos => UnmodifiableListView(_todos);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Commands (View가 호출하는 액션)
  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todos = await _repository.getAllTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeTodo(String id) async {
    // 낙관적 업데이트 (Optimistic Update)
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final original = _todos[index];
    _todos[index] = original.copyWith(isCompleted: true);
    notifyListeners();

    try {
      await _repository.updateTodo(_todos[index]);
    } catch (e) {
      // 롤백
      _todos[index] = original;
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

## 3. SOLID 원칙

### S - Single Responsibility (단일 책임)

```dart
// ❌ Bad: 하나의 클래스가 너무 많은 책임
class TodoManager {
  void saveTodo() { }
  void sendNotification() { }
  void formatDate() { }
  void validateInput() { }
}

// ✅ Good: 각 클래스가 하나의 책임
class TodoRepository { void save() { } }
class NotificationService { void send() { } }
class DateFormatter { String format() { } }
class TodoValidator { bool validate() { } }
```

### O - Open/Closed (개방/폐쇄)

```dart
// ❌ Bad: 새 필터 추가 시 클래스 수정 필요
class TodoFilter {
  List<Todo> filter(List<Todo> todos, String type) {
    switch (type) {
      case 'completed': return todos.where((t) => t.isCompleted).toList();
      case 'today': return todos.where((t) => t.isToday).toList();
      // 새 타입 추가 시 여기 수정...
    }
  }
}

// ✅ Good: 새 필터 추가 시 확장만 필요
abstract class TodoFilterStrategy {
  List<Todo> filter(List<Todo> todos);
}

class CompletedFilter implements TodoFilterStrategy {
  @override
  List<Todo> filter(List<Todo> todos) => todos.where((t) => t.isCompleted).toList();
}

class TodayFilter implements TodoFilterStrategy {
  @override
  List<Todo> filter(List<Todo> todos) => todos.where((t) => t.isToday).toList();
}
```

### L - Liskov Substitution (리스코프 치환)

```dart
// 서브클래스는 부모 클래스를 대체할 수 있어야 함
abstract class DataSource {
  Future<List<Todo>> getTodos();
}

class HiveDataSource implements DataSource {
  @override
  Future<List<Todo>> getTodos() async => _box.values.toList();
}

class ApiDataSource implements DataSource {
  @override
  Future<List<Todo>> getTodos() async => await _api.fetchTodos();
}

// 어떤 DataSource든 동일하게 사용 가능
class TodoRepository {
  final DataSource dataSource;
  TodoRepository(this.dataSource);
}
```

### I - Interface Segregation (인터페이스 분리)

```dart
// ❌ Bad: 거대한 인터페이스
abstract class TodoOperations {
  void create();
  void read();
  void update();
  void delete();
  void archive();
  void restore();
  void export();
  void import();
}

// ✅ Good: 작은 인터페이스로 분리
abstract class CrudOperations<T> {
  Future<T> create(T item);
  Future<T?> read(String id);
  Future<void> update(T item);
  Future<void> delete(String id);
}

abstract class ArchiveOperations<T> {
  Future<void> archive(String id);
  Future<void> restore(String id);
}
```

### D - Dependency Inversion (의존성 역전)

```dart
// ❌ Bad: 구체 클래스에 의존
class TodoProvider {
  final HiveBox _box = HiveBox();  // 구체 클래스 직접 생성
}

// ✅ Good: 추상화에 의존 + 의존성 주입
abstract class TodoRepository {
  Future<List<Todo>> getAll();
}

class TodoProvider {
  final TodoRepository _repository;  // 추상화에 의존

  TodoProvider(this._repository);    // 외부에서 주입
}

// main.dart에서 주입
final provider = TodoProvider(HiveTodoRepository());
```

## 4. 최신 Flutter 패턴

### Result 패턴 (Either 대안)

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Failure(this.message, [this.exception]);
}

// 사용
Future<Result<Todo>> getTodo(String id) async {
  try {
    final todo = await _repository.getTodo(id);
    return Success(todo);
  } catch (e) {
    return Failure('할일을 찾을 수 없습니다', e as Exception);
  }
}

// 패턴 매칭 (Dart 3.0+)
final result = await getTodo('123');
switch (result) {
  case Success(:final data):
    print('성공: ${data.title}');
  case Failure(:final message):
    print('실패: $message');
}
```

### Command 패턴 (ViewModel 액션)

```dart
class Command<T> {
  final Future<T> Function() _action;

  bool _running = false;
  T? _result;
  Exception? _error;

  bool get running => _running;
  T? get result => _result;
  Exception? get error => _error;
  bool get completed => _result != null;
  bool get failed => _error != null;

  Command(this._action);

  Future<void> execute() async {
    if (_running) return;

    _running = true;
    _error = null;

    try {
      _result = await _action();
    } catch (e) {
      _error = e as Exception;
    } finally {
      _running = false;
    }
  }
}

// ViewModel에서 사용
class TodoViewModel extends ChangeNotifier {
  late final loadCommand = Command(() async {
    return await _repository.getAllTodos();
  });

  Future<void> load() async {
    await loadCommand.execute();
    notifyListeners();
  }
}
```

### 상태 클래스 패턴 (Sealed Class)

```dart
// Dart 3.0+ sealed class
sealed class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  TodoLoaded(this.todos);
}

class TodoError extends TodoState {
  final String message;
  TodoError(this.message);
}

// View에서 패턴 매칭
Widget build(BuildContext context) {
  return switch (state) {
    TodoInitial() => const SizedBox.shrink(),
    TodoLoading() => const CircularProgressIndicator(),
    TodoLoaded(:final todos) => TodoListView(todos: todos),
    TodoError(:final message) => ErrorView(message: message),
  };
}
```

## 5. 권장 프로젝트 구조

```
lib/
├── core/                     # 공통 유틸리티
│   ├── constants/
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── utils/
│   └── extensions/
│
├── features/                 # Feature-First 구조
│   ├── todo/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── todo_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── todo_model.dart
│   │   │   └── repositories/
│   │   │       └── todo_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── todo.dart
│   │   │   ├── repositories/
│   │   │   │   └── todo_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_todos.dart
│   │   │       └── complete_todo.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── todo_provider.dart
│   │       ├── pages/
│   │       │   └── todo_page.dart
│   │       └── widgets/
│   │           └── todo_list_item.dart
│   │
│   ├── focus/
│   └── habits/
│
├── shared/                   # 공유 컴포넌트
│   ├── widgets/
│   └── themes/
│
└── main.dart
```

## 6. 테스트 전략

### 테스트 피라미드

```
        ┌─────────┐
        │   E2E   │  ← 통합 테스트 (적음)
       ┌┴─────────┴┐
       │  Widget   │  ← 위젯 테스트 (중간)
      ┌┴───────────┴┐
      │    Unit     │  ← 단위 테스트 (많음)
      └─────────────┘
```

### 단위 테스트 우선순위

1. **비즈니스 로직** (UseCases, Providers)
2. **데이터 변환** (Models, Repositories)
3. **유틸리티** (Formatters, Validators)

## 참고 자료

- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter Architecture Samples](https://fluttersamples.com)
- [Reso Coder - Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd)
- [Very Good Ventures - Engineering](https://verygood.ventures/blog)
