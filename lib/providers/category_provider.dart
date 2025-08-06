// lib/providers/category_provider.dart
import 'package:flutter/material.dart';
import 'package:allcal/models/category.dart';
import 'package:uuid/uuid.dart'; // Uuid 패키지 import

// Uuid 객체 생성
var uuid = const Uuid();

class CategoryProvider extends ChangeNotifier {
  final List<Category> _categories = [
    Category(id: '1', name: '데이트', color: Colors.red),
    Category(id: '2', name: '대학교', color: Colors.orange),
    Category(id: '3', name: '고등학교 친구 모임', color: Colors.blue),
    Category(id: '4', name: '자기계발', color: Colors.green),
  ];

  // [추가] 색상 프리셋 목록
  final List<Color> _colorPresets = [
    Colors.red, Colors.orange, Colors.yellow, Colors.green,
    Colors.blue, Colors.indigo, Colors.purple, Colors.pink,
    Colors.teal, Colors.cyan, Colors.lime, Colors.brown,
  ];

  List<Category> get categories => _categories;
  // [추가] 외부에서 프리셋 목록을 읽을 수 있도록 getter 제공
  List<Color> get colorPresets => _colorPresets;

  // [추가] 프리셋 목록에 새로운 색상을 추가하는 함수
  void addColorPreset(Color color) {
    if (!_colorPresets.contains(color)) {
      _colorPresets.add(color);
      notifyListeners();
    }
  }

  // [추가] 프리셋에서 색상을 삭제하는 함수
  void deleteColorPreset(Color color) {
    _colorPresets.remove(color);
    notifyListeners();
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    notifyListeners();
  }

  // [추가] 카테고리 추가 함수
  void addCategory(String name, Color color) {
    final newCategory = Category(
      id: uuid.v4(), // 고유 ID 생성
      name: name,
      color: color,
    );
    _categories.add(newCategory);
    notifyListeners();
  }

  // [추가] 카테고리 수정 함수
  void updateCategory(String id, String newName, Color newColor) {
    final categoryIndex = _categories.indexWhere((cat) => cat.id == id);
    if (categoryIndex != -1) {
      _categories[categoryIndex].name = newName;
      _categories[categoryIndex].color = newColor;
      notifyListeners();
    }
  }

  // [추가] 카테고리 삭제 함수
  void deleteCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
  }
}