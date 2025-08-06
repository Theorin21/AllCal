import 'package:allcal/models/daily_data.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:allcal/models/resource.dart'; // [추가]

class DataProvider extends ChangeNotifier {
  final List<DailyData> _allData = [
    DailyData(id: '1', title: '플러터 공부', type: ItemType.schedule, categoryId: '2', startTime: DateTime.now().add(const Duration(hours: 1)), endTime: DateTime.now().add(const Duration(hours: 3)), completionState: CompletionState.completed),
    DailyData(id: '2', title: '헬스', type: ItemType.task, categoryId: '4'),
    DailyData(id: '3', title: '프로젝트 기획서 제출', type: ItemType.deadline, categoryId: '1', startTime: DateTime.now().add(const Duration(hours: 8))),
    DailyData(id: '4', title: '저녁 약속', type: ItemType.schedule, categoryId: '1', startTime: DateTime.now().add(const Duration(hours: 9)), endTime: DateTime.now().add(const Duration(hours: 10))),
    DailyData(id: '5', title: '어제 회의 기록', type: ItemType.record, categoryId: '3', completionState: CompletionState.detailed),
  ];
  
  List<DailyData> get allData => _allData;
  
  void addData(DailyData data) {
    _allData.add(data);
    notifyListeners();
  }

  void cycleCompletionState(String id) {
    try {
      final data = _allData.firstWhere((item) => item.id == id);
      if (data.completionState == CompletionState.notCompleted) {
        data.completionState = CompletionState.completed;
      } else {
        // 이미 완료된 항목을 다시 누르면 미완료로 (토글)
        data.completionState = CompletionState.notCompleted;
        data.resourceChanges = []; // 기록된 자원 변화량도 초기화
      }
      notifyListeners();
    } catch (e) {
      print('Could not find data with id: $id');
    }
  }

  // [추가] 자원 변화량을 저장하고 상태를 'detailed'로 바꾸는 함수
  void addResourceChanges(String id, List<ResourceChange> changes) {
    try {
      final data = _allData.firstWhere((item) => item.id == id);
      data.resourceChanges = changes;
      data.completionState = CompletionState.detailed;
      notifyListeners();
    } catch (e) {
      print('Could not find data with id: $id');
    }
  }

  List<DailyData> getDataForDay(DateTime date) {
    final day = DateUtils.dateOnly(date);

    return _allData.where((data) {
      if (data.startTime == null) {
        return false;
      }
      
      final start = DateUtils.dateOnly(data.startTime!);
      final end = DateUtils.dateOnly(data.endTime ?? data.startTime!);

      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();
  }
}