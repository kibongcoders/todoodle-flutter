---
name: new-screen
description: Clean Architecture 구조에 맞는 새 화면(Page) 생성
---

# New Screen/Page Skill (Clean Architecture)

Feature-First 구조에 맞는 새로운 화면을 생성합니다.

## Usage
`/new-screen [FeatureName] [PageName]` - 새 화면 생성

## File Location
```
lib/features/[feature]/presentation/pages/[page_name]_page.dart
```

## Templates

### Basic Page (StatefulWidget)
```dart
// lib/features/[feature]/presentation/pages/[page_name]_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/[feature]_provider.dart';

class [PageName]Page extends StatefulWidget {
  const [PageName]Page({super.key});

  @override
  State<[PageName]Page> createState() => _[PageName]PageState();
}

class _[PageName]PageState extends State<[PageName]Page> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    Future.microtask(() =>
      context.read<[Feature]Provider>().loadItems()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Title]'),
      ),
      body: SafeArea(
        child: Consumer<[Feature]Provider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return _buildErrorWidget(provider.error!);
            }

            return _buildContent(provider);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('오류: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<[Feature]Provider>().loadItems(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent([Feature]Provider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content here
        ],
      ),
    );
  }
}
```

### List Page with Pull-to-Refresh
```dart
class [PageName]Page extends StatefulWidget {
  const [PageName]Page({super.key});

  @override
  State<[PageName]Page> createState() => _[PageName]PageState();
}

class _[PageName]PageState extends State<[PageName]Page> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<[Feature]Provider>().loadItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Title]'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Consumer<[Feature]Provider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.items.isEmpty) {
            return _buildEmptyWidget();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadItems(),
            child: ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return [Feature]Item(item: item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('항목이 없습니다'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('새로 만들기'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // TODO: Implement
  }
}
```

### Detail Page with Arguments
```dart
class [PageName]DetailPage extends StatelessWidget {
  final String itemId;

  const [PageName]DetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Selector<[Feature]Provider, [Feature]Model?>(
        selector: (_, provider) => provider.getById(itemId),
        builder: (context, item, child) {
          if (item == null) {
            return const Center(child: Text('항목을 찾을 수 없습니다'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                // More details...
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    // TODO: Navigate to edit page
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<[Feature]Provider>().deleteItem(itemId);
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Detail page
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

## Navigation Patterns

### Named Routes
```dart
// main.dart 또는 router.dart
MaterialApp(
  routes: {
    '/[feature]': (context) => const [Feature]Page(),
    '/[feature]/detail': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return [Feature]DetailPage(itemId: args);
    },
  },
)

// 사용
Navigator.pushNamed(context, '/[feature]');
Navigator.pushNamed(context, '/[feature]/detail', arguments: item.id);
```

### GoRouter (권장)
```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/[feature]',
      builder: (context, state) => const [Feature]Page(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => [Feature]DetailPage(
            itemId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
)
```

## Checklist
- [ ] Page 파일 생성
- [ ] Provider Consumer 연결
- [ ] 로딩/에러/빈 상태 처리
- [ ] 네비게이션 설정
- [ ] AppBar actions 구현
