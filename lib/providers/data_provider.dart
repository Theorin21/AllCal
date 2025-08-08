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
  ];
  
  List<DailyData> get allData => _allData;
  
  void addData(DailyData data) {
    _allData.add(data);
    notifyListeners();
  }

  // [수정] notCompleted -> completed 상태로만 변경하는 함수
  void setCompleted(String id) {
    try {
      final data = _allData.firstWhere((item) => item.id == id);
      if (data.completionState == CompletionState.notCompleted) {
        data.completionState = CompletionState.completed;
        notifyListeners();
      }
    } catch (e) { print('Could not find data with id: $id'); }
  }

  // [추가] 상태를 되돌리는 함수 (꾹 누르기 기능)
  void revertCompletionState(String id) {
    try {
      final data = _allData.firstWhere((item) => item.id == id);
      if (data.completionState == CompletionState.detailed) {
        data.completionState = CompletionState.completed;
        data.resourceChanges = []; // [핵심] 자원 기록 삭제
      } else if (data.completionState == CompletionState.completed) {
        data.completionState = CompletionState.notCompleted;
      }
      notifyListeners();
    } catch (e) { print('Could not find data with id: $id'); }
  }

  // [추가] 기존 데이터를 수정(덮어쓰기)하는 함수
  void updateData(DailyData updatedData) {
    try {
      // 리스트에서 수정할 데이터의 인덱스를 찾습니다.
      final index = _allData.indexWhere((item) => item.id == updatedData.id);
      if (index != -1) {
        // 해당 인덱스의 기존 데이터를 새로운 데이터로 교체합니다.
        _allData[index] = updatedData;
        notifyListeners(); // 변경사항을 알립니다.
      }
    } catch (e) {
      print('Could not find data with id: ${updatedData.id}');
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