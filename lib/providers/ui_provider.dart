// lib/providers/ui_provider.dart
import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  // 왼쪽 '기한' 패널의 높이
  double _deadlinePanelHeight = 150.0;
  // 오른쪽 '기록' 패널의 높이
  double _recordPanelHeight = 150.0;

  double get deadlinePanelHeight => _deadlinePanelHeight;
  double get recordPanelHeight => _recordPanelHeight;

  // 높이를 조절하는 함수
  void setDeadlinePanelHeight(double newHeight, double maxHeight) {
    // 최소, 최대 높이 제약 조건
    if (newHeight >= 80 && newHeight <= maxHeight) {
      _deadlinePanelHeight = newHeight;
      notifyListeners();
    }
  }

  void setRecordPanelHeight(double newHeight, double maxHeight) {
    if (newHeight >= 80 && newHeight <= maxHeight) {
      _recordPanelHeight = newHeight;
      notifyListeners();
    }
  }
}