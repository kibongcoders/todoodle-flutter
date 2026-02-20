import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';
import '../shared/widgets/doodle_icon.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보관함'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: const Color(0xFF2E7D32),
      ),
      backgroundColor: Colors.white,
      body: Consumer2<TodoProvider, CategoryProvider>(
        builder: (context, todoProvider, categoryProvider, _) {
          final archivedTodos = todoProvider.getArchivedTodos();

          if (archivedTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📦', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    '보관함이 비어있어요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '완료된 할일을 보관하면 여기에 표시됩니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: archivedTodos.length,
            itemBuilder: (context, index) {
              final todo = archivedTodos[index];
              final category = todo.categoryIds.isNotEmpty
                  ? categoryProvider.getCategoryById(todo.categoryIds.first)
                  : null;

              return Dismissible(
                key: ValueKey(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red[400],
                  child: const DoodleIcon(type: DoodleIconType.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('영구 삭제'),
                      content: Text('"${todo.title}"을(를) 영구적으로 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  todoProvider.permanentlyDeleteTodo(todo.id);
                },
                child: ListTile(
                  leading: Text(
                    category?.emoji ?? '📌',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      color: todo.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  subtitle: todo.dueDate != null
                      ? Text(
                          '마감: ${todo.dueDate!.month}/${todo.dueDate!.day}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const DoodleIcon(type: DoodleIconType.restore, color: Color(0xFF2E7D32)),
                    onPressed: () {
                      todoProvider.unarchiveTodo(todo.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${todo.title}" 복원됨'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
