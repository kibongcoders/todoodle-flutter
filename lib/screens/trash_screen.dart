import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/todo_provider.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('휴지통'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: const Color(0xFF2E7D32),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, _) {
              final trashTodos = todoProvider.getTrashTodos();
              if (trashTodos.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showEmptyTrashDialog(context, todoProvider),
                child: const Text('비우기', style: TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer2<TodoProvider, CategoryProvider>(
        builder: (context, todoProvider, categoryProvider, _) {
          final trashTodos = todoProvider.getTrashTodos();

          if (trashTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🗑️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    '휴지통이 비어있어요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '삭제된 할일은 30일 후 자동으로 삭제됩니다',
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
            itemCount: trashTodos.length,
            itemBuilder: (context, index) {
              final todo = trashTodos[index];
              final category = todo.categoryIds.isNotEmpty
                  ? categoryProvider.getCategoryById(todo.categoryIds.first)
                  : null;
              final daysLeft = 30 - DateTime.now().difference(todo.deletedAt!).inDays;

              return Dismissible(
                key: ValueKey(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red[400],
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('영구 삭제'),
                      content: Text('"${todo.title}"을(를) 영구적으로 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('영구 삭제'),
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
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                  subtitle: Text(
                    '$daysLeft일 후 자동 삭제',
                    style: TextStyle(
                      color: daysLeft <= 7 ? Colors.red[400] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore, color: Color(0xFF2E7D32)),
                    onPressed: () {
                      todoProvider.restoreTodo(todo.id);
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

  void _showEmptyTrashDialog(BuildContext context, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('휴지통 비우기'),
        content: const Text('휴지통의 모든 항목을 영구적으로 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              todoProvider.emptyTrash();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('휴지통을 비웠습니다'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('비우기'),
          ),
        ],
      ),
    );
  }
}
