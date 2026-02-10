# Feature: Phase 3.3 - 예상 시간 기능

## Overview

할일에 예상 소요 시간을 입력하고, 하루 총 예상 시간을 확인하며, 포모도로 완료 시 실제 시간을 자동 기록하는 기능입니다.

## Current State (현재 상태)

### 이미 구현된 것
- `Todo.estimatedMinutes` - 예상 소요 시간 필드 (HiveField 19)
- `Todo.actualMinutes` - 실제 소요 시간 필드 (HiveField 20)
- `FocusProvider.getTotalFocusMinutesForTodo()` - 할일별 집중 시간 조회

### 미구현
- 예상 시간 입력 UI
- 하루 총 예상 시간 계산/표시
- 포모도로 완료 시 `actualMinutes` 자동 업데이트

---

## Implementation Plan (구현 계획)

### Step 1: 예상 시간 입력 UI 추가

**파일:** `lib/screens/todo_form_screen.dart`

**변경 사항:**
1. State 변수 추가: `int? _estimatedMinutes`
2. initState에서 초기화: `_estimatedMinutes = widget.todo?.estimatedMinutes`
3. UI 위젯 추가 (우선순위 아래 또는 태그 위)
4. 저장 시 값 전달

**UI 디자인:**
```dart
// 예상 시간 선택기
_buildEstimatedTimeSection()
├── Row
│   ├── Icon(Icons.timer_outlined)
│   ├── Text('예상 시간')
│   └── Chip (선택된 시간 표시)
└── Wrap (빠른 선택 버튼)
    ├── [15분] [30분] [1시간] [2시간] [직접 입력]
```

**빠른 선택 옵션:**
| 버튼 | 값 (분) |
|------|--------|
| 15분 | 15 |
| 30분 | 30 |
| 1시간 | 60 |
| 2시간 | 120 |
| 직접 입력 | NumberPicker Dialog |

---

### Step 2: TodoProvider 메서드 추가

**파일:** `lib/providers/todo_provider.dart`

**추가할 메서드:**
```dart
/// 오늘 할일의 총 예상 시간 (분)
int getTodayTotalEstimatedMinutes() {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  return _box.values
    .where((t) =>
      !t.isCompleted &&
      !t.isArchived &&
      t.deletedAt == null &&
      t.dueDate != null &&
      t.dueDate!.isAfter(todayStart) &&
      t.dueDate!.isBefore(todayEnd))
    .fold(0, (sum, t) => sum + (t.estimatedMinutes ?? 0));
}

/// 오늘 완료된 할일의 총 시간 (분)
int getTodayCompletedMinutes() {
  // 실제 소요 시간 또는 예상 시간 사용
}

/// 할일의 실제 시간 업데이트
Future<void> updateActualMinutes(String todoId, int minutes) async {
  final todo = _box.get(todoId);
  if (todo != null) {
    final updated = todo.copyWith(
      actualMinutes: (todo.actualMinutes ?? 0) + minutes,
    );
    await _box.put(todoId, updated);
    notifyListeners();
  }
}
```

---

### Step 3: 홈 화면에 총 예상 시간 표시

**파일:** `lib/screens/home_screen.dart`

**추가 위치:** 상단 헤더 또는 필터 탭 영역

**UI 디자인:**
```
┌─────────────────────────────────────┐
│ 오늘의 할일                      📊 │
│ 3개 남음 · 예상 2시간 30분          │
└─────────────────────────────────────┘
```

**코드:**
```dart
Widget _buildTodayEstimatedTime() {
  final todoProvider = context.watch<TodoProvider>();
  final minutes = todoProvider.getTodayTotalEstimatedMinutes();

  if (minutes == 0) return const SizedBox.shrink();

  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  final text = hours > 0
    ? '예상 ${hours}시간 ${mins > 0 ? '${mins}분' : ''}'
    : '예상 ${mins}분';

  return Text(text, style: TextStyle(color: Colors.grey[600]));
}
```

---

### Step 4: 포모도로 완료 시 실제 시간 기록

**파일:** `lib/providers/focus_provider.dart`

**변경 사항:**
1. `_onTimerComplete()`에서 세션 완료 시 TodoProvider 호출
2. 실제 집중 시간을 할일에 기록

**코드 변경:**
```dart
// FocusProvider에 TodoProvider 참조 추가
TodoProvider? _todoProvider;

void setTodoProvider(TodoProvider provider) {
  _todoProvider = provider;
}

// _onTimerComplete() 수정
Future<void> _onTimerComplete() async {
  // ... 기존 코드 ...

  if (_state == PomodoroState.running) {
    // 세션 저장 후, 할일에 실제 시간 기록
    if (_currentTodoId != null && _todoProvider != null) {
      final actualMinutes = _currentSession!.actualDuration ~/ 60;
      await _todoProvider!.updateActualMinutes(_currentTodoId!, actualMinutes);
    }

    // ... 나머지 코드 ...
  }
}
```

**파일:** `lib/main.dart`

**변경:** Provider 연결
```dart
// FocusProvider 초기화 후
focusProvider.setTodoProvider(todoProvider);
```

---

### Step 5: 할일 목록에 예상 시간 표시

**파일:** `lib/widgets/todo_list_item.dart`

**추가:** 할일 항목에 예상 시간 뱃지 표시

```dart
if (todo.estimatedMinutes != null)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: 12, color: Colors.blue),
        SizedBox(width: 2),
        Text(
          _formatMinutes(todo.estimatedMinutes!),
          style: TextStyle(fontSize: 11, color: Colors.blue),
        ),
      ],
    ),
  ),
```

---

## File Changes Summary

### Create (새 파일)
없음 - 기존 파일 수정으로 충분

### Modify (수정할 파일)

| 파일 | 변경 내용 |
|------|----------|
| `lib/screens/todo_form_screen.dart` | 예상 시간 입력 UI 추가 |
| `lib/providers/todo_provider.dart` | 시간 계산 메서드 추가 |
| `lib/providers/focus_provider.dart` | TodoProvider 연동, 실제 시간 기록 |
| `lib/screens/home_screen.dart` | 총 예상 시간 표시 |
| `lib/widgets/todo_list_item.dart` | 예상 시간 뱃지 표시 |
| `lib/main.dart` | Provider 연결 |

---

## Testing Plan

### Unit Tests
```dart
// test/providers/todo_provider_test.dart
group('예상 시간', () {
  test('getTodayTotalEstimatedMinutes 오늘 할일의 총 예상 시간을 반환한다', () {});
  test('updateActualMinutes 실제 시간을 누적한다', () {});
});
```

### Widget Tests
```dart
// test/screens/todo_form_screen_test.dart
testWidgets('예상 시간 선택 UI가 표시된다', (tester) async {});
testWidgets('빠른 선택 버튼 클릭 시 시간이 설정된다', (tester) async {});
```

---

## Implementation Order (구현 순서)

1. [ ] `todo_provider.dart` - 메서드 추가
2. [ ] `todo_form_screen.dart` - 입력 UI 추가
3. [ ] `home_screen.dart` - 총 시간 표시
4. [ ] `todo_list_item.dart` - 뱃지 표시
5. [ ] `focus_provider.dart` - 실제 시간 기록 연동
6. [ ] `main.dart` - Provider 연결
7. [ ] 테스트 작성 및 실행
8. [ ] ROADMAP.md 업데이트

---

## Estimated Effort

| 작업 | 예상 |
|------|------|
| Step 1-2 (입력 UI + Provider) | 중간 |
| Step 3 (홈 화면 표시) | 작음 |
| Step 4 (포모도로 연동) | 중간 |
| Step 5 (목록 뱃지) | 작음 |
| 테스트 | 작음 |

**총 예상:** 중간 규모 작업

---

*작성일: 2026-02-08*
