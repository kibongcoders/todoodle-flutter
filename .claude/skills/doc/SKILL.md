---
name: doc
description: 코드 문서화 (dartdoc 주석)
argument-hint: [file_path]
---

# Code Documentation

Dart/Flutter 코드에 dartdoc 주석을 추가합니다.

## Instructions

1. **대상 파일 확인**
   - $ARGUMENTS로 지정된 파일 읽기
   - 문서화가 필요한 항목 식별

2. **문서화 대상**
   - public 클래스
   - public 메서드
   - public 프로퍼티
   - 복잡한 로직

3. **dartdoc 주석 작성**
   - 한국어로 작성
   - 예시 코드 포함 (필요시)

4. **검증**
   ```bash
   dart doc --dry-run
   ```

## Documentation Format

### Class Documentation

```dart
/// 할일 항목을 관리하는 Provider.
///
/// [TodoProvider]는 할일의 CRUD 작업과 상태 관리를 담당합니다.
///
/// 사용 예시:
/// ```dart
/// final provider = context.read<TodoProvider>();
/// provider.addTodo(Todo(title: '새 할일'));
/// ```
class TodoProvider extends ChangeNotifier {
  // ...
}
```

### Method Documentation

```dart
/// 새로운 할일을 추가합니다.
///
/// [todo]는 추가할 할일 객체입니다.
/// 추가 후 리스너에게 변경을 알립니다.
///
/// Throws [HiveError] if the box is not open.
Future<void> addTodo(Todo todo) async {
  // ...
}
```

### Property Documentation

```dart
/// 현재 선택된 날짜의 할일 목록.
///
/// 날짜가 변경되면 자동으로 필터링됩니다.
List<Todo> get todosForSelectedDate => _filteredTodos;
```

## Documentation Checklist

- [ ] 클래스 설명
- [ ] 생성자 파라미터 설명
- [ ] public 메서드 설명
- [ ] 반환값 설명
- [ ] 예외 상황 문서화
- [ ] 사용 예시 (복잡한 경우)

## Arguments

$ARGUMENTS

- 빈 값: 최근 변경 파일 문서화
- `lib/providers/todo_provider.dart`: 특정 파일 문서화
