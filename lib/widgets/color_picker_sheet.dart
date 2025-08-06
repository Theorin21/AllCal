// lib/widgets/color_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:allcal/providers/category_provider.dart';

class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({super.key});

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final presets = categoryProvider.colorPresets;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [수정] 제목, 휴지통, 추가 아이콘을 담는 Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽: 휴지통 아이콘
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _isDeleteMode = !_isDeleteMode;
                  });
                },
              ),
              // 가운데: 제목
              const Text(
                '캘린더 색상',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // 오른쪽: '+' 추가 아이콘
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showDetailedColorPicker(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            // [수정] itemCount를 프리셋 목록의 길이로 변경
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final color = presets[index];
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isDeleteMode) return;
                      Navigator.of(context).pop(color);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (_isDeleteMode)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () {
                          context.read<CategoryProvider>().deleteColorPreset(color);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // _showDetailedColorPicker 함수는 이전과 동일
  void _showDetailedColorPicker(BuildContext context) {
    Color pickedColor = Colors.blue;
    final TextEditingController hexController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('색상 선택'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (color) {
                        setState(() {
                          pickedColor = color;
                          hexController.text = color.value.toRadixString(16).substring(2).toUpperCase();
                        });
                      },
                      pickerAreaHeightPercent: 0.7,
                      displayThumbColor: true,
                      enableAlpha: false,
                    ),
                    TextField(
                      controller: hexController,
                      decoration: const InputDecoration(
                        labelText: 'Hex Code',
                        prefixText: '#',
                      ),
                      onSubmitted: (String value) {
                        try {
                          final newColor = Color(int.parse('FF$value', radix: 16));
                          setState(() {
                            pickedColor = newColor;
                          });
                        } catch (e) {}
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('추가'),
                  onPressed: () {
                    context.read<CategoryProvider>().addColorPreset(pickedColor);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(pickedColor);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}