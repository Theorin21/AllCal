// lib/screens/category_edit_screen.dart
import 'package:allcal/models/category.dart';
import 'package:allcal/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:allcal/widgets/color_picker_sheet.dart'; // [추가]

class CategoryEditScreen extends StatefulWidget {
  // 수정 모드를 위해 기존 카테고리 정보를 받을 수 있도록 함 (없으면 만들기 모드)
  final Category? category;

  const CategoryEditScreen({super.key, this.category});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  // 텍스트 필드와 색상 상태를 관리
  late TextEditingController _nameController;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    // 수정 모드이면 기존 값으로, 만들기 모드이면 기본값으로 초기화
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _currentColor = widget.category?.color ?? Colors.blue;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // [수정] _pickColor 함수
  void _pickColor() async {
    // showModalBottomSheet는 사용자가 선택한 값을 반환할 수 있음 (Future)
    final selectedColor = await showModalBottomSheet<Color>(
      context: context,
      builder: (context) => const ColorPickerSheet(),
    );

    // 사용자가 색상을 선택하고 닫았다면 (null이 아니라면)
    if (selectedColor != null) {
      // 화면의 색상을 업데이트
      setState(() {
        _currentColor = selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '캘린더 설정' : '캘린더 만들기'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // [수정] 저장(✓) 아이콘으로 변경
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // 저장 로직
              if (_nameController.text.isNotEmpty) {
                final provider = context.read<CategoryProvider>();
                if (isEditing) {
                  provider.updateCategory(widget.category!.id, _nameController.text, _currentColor);
                } else {
                  provider.addCategory(_nameController.text, _currentColor);
                }
                Navigator.of(context).pop();
              }
            },
          ),
          // 수정 모드일 때만 점 세 개(삭제) 아이콘 표시
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: 캘린더 삭제 팝업 표시
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '캘린더 이름',
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('캘린더 색상'),
              trailing: Icon(Icons.circle, color: _currentColor),
              onTap: _pickColor, // [수정] 탭하면 색상 선택창 호출
            ),
          ],
        ),
      ),
    );
  }
}