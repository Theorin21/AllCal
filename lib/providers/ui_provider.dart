// lib/providers/ui_provider.dart
import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  // 최초 높이는 MainScreen에서 동적으로 설정될 것임
  double _deadlinePanelHeight = 150.0;
  // 높이가 한 번이라도 설정되었는지 확인하는 플래그
  bool _isDeadlinePanelHeightInitialized = false;

  double get deadlinePanelHeight => _deadlinePanelHeight;

  // 최초 높이를 딱 한 번만 설정하기 위한 함수
  void initializeDeadlinePanelHeight(double initialHeight) {
    if (!_isDeadlinePanelHeightInitialized) {
      _deadlinePanelHeight = initialHeight;
      _isDeadlinePanelHeightInitialized = true;
      // ✨ 1. UI를 다시 그리라고 알림을 보냅니다. ✨
      // addPostFrameCallback 안에서 호출되므로 안전합니다.
      notifyListeners();    }
  }

  // 동적인 최소/최대 높이를 받도록 함수 수정
  void setDeadlinePanelHeight(double newHeight, double minHeight, double maxHeight) {
    // clamp 함수를 사용하여 newHeight가 minHeight와 maxHeight 사이를 벗어나지 않도록 보정
    final clampedHeight = newHeight.clamp(minHeight, maxHeight);
    
    if (_deadlinePanelHeight != clampedHeight) {
      _deadlinePanelHeight = clampedHeight;
      notifyListeners();
    }
  }
}