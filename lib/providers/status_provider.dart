// lib/providers/status_provider.dart
import 'package:allcal/models/daily_data.dart';
import 'package:allcal/models/resource.dart';
import 'package:allcal/models/status.dart';
import 'package:flutter/material.dart';

class StatusProvider extends ChangeNotifier {
  Status _currentStatus = Status();
  
  Status get currentStatus => _currentStatus;

  void recalculateStatus(List<DailyData> allData, List<Resource> allResources) {
    // 1. 최종 자원을 기본값(100)으로 초기화
    _currentStatus = Status();

    // 2. 모든 데이터 항목을 순회
    for (final data in allData) {
      // 3. 각 항목에 기록된 자원 변화량을 순회
      for (final change in data.resourceChanges) {
        try {
          // 4. 변화량에 해당하는 자원 정보를 찾음
          final resource = allResources.firstWhere((r) => r.id == change.resourceId);
          // 5. 자원의 연산식에 따라 최종 자원에 영향 적용
          resource.computation.forEach((targetResourceId, factor) {
            if (targetResourceId == 'health') {
              _currentStatus.health += change.amount * factor;
            } else if (targetResourceId == 'mentalEnergy') {
              _currentStatus.mentalEnergy += change.amount * factor;
            } else if (targetResourceId == 'capital') {
              _currentStatus.capital += change.amount * factor;
            }
          });
        } catch (e) { /* 자원을 못찾으면 무시 */ }
      }
    }
    // 6. 계산이 끝나면 UI에 변경사항 알림
    notifyListeners();
  }
}