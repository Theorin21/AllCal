// lib/screens/category_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allcal/providers/category_provider.dart';
import 'package:allcal/screens/category_edit_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  bool _isReorderMode = false;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더 관리'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // [수정] '+ 추가' 버튼을 AppBar로 이동
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CategoryEditScreen(), // 만들기 모드로 진입
                fullscreenDialog: true,
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () {
              setState(() {
                _isReorderMode = !_isReorderMode;
              });
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        // [수정] itemCount를 카테고리 길이로 변경
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            key: ValueKey(category.id),
            leading: Icon(Icons.circle, color: category.color),
            title: Text(category.name),
            trailing: _isReorderMode
                ? ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  )
                : null, // [수정] 장식용 > 아이콘 제거
            onTap: () {
              if (!_isReorderMode) {
                // [수정] 탭하면 수정 모드로 진입
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CategoryEditScreen(category: category),
                  fullscreenDialog: true,
                ));
              }
            },
          );
        },
        onReorder: (oldIndex, newIndex) {
          context.read<CategoryProvider>().reorderCategories(oldIndex, newIndex);
        },
      ),
    );
  }
}