import 'package:allcal/models/daily_data.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:allcal/models/resource.dart'; // [추가]
import 'package:allcal/providers/category_provider.dart'; // 카테고리 프로바이더 import

class DataProvider extends ChangeNotifier {
  final List<DailyData> _allData = [
    DailyData(id: '1', title: '플러터 공부', type: ItemType.schedule, categoryId: '2', startTime: DateTime.now().add(const Duration(hours: 1)), endTime: DateTime.now().add(const Duration(hours: 3)), completionState: CompletionState.completed),
    DailyData(id: '2', title: '헬스', type: ItemType.task, categoryId: '4'),
    DailyData(
      id: '3', 
      title: '프로젝트 기획서 제출', 
      type: ItemType.deadline, 
      categoryId: '1', 
      startTime: DateTime.now(), // startTime은 현재 시간 (생성 시점)
      endTime: DateTime.now().add(const Duration(days: 1)), // endTime은 하루 뒤 (마감일)
    ),
    DailyData(
      id: '5', 
      title: '과제 1', 
      type: ItemType.deadline, 
      categoryId: '2', 
      startTime: DateTime.now(), // startTime은 현재 시간 (생성 시점)
      endTime: DateTime.now().add(const Duration(days: 2)), // endTime은 하루 뒤 (마감일)
    ),
    DailyData(
      id: '6', 
      title: '헬로우', 
      type: ItemType.deadline, 
      categoryId: '3', 
      startTime: DateTime.now(), // startTime은 현재 시간 (생성 시점)
      endTime: DateTime.now().add(const Duration(days: 3)), // endTime은 하루 뒤 (마감일)
    ),
    DailyData(id: '4', title: '저녁 약속', type: ItemType.schedule, categoryId: '1', startTime: DateTime.now().add(const Duration(hours: 9)), endTime: DateTime.now().add(const Duration(hours: 10))),
  ];
  
  final CategoryProvider _categoryProvider;

  DataProvider(this._categoryProvider) {
    // 생성 시점에 초기 정렬을 한 번 수행
    _sortData();
  }

  List<DailyData> get allData => _allData;

  void _sortData() {
    // CategoryProvider의 최신 카테고리 목록을 가져옴
    final categories = _categoryProvider.categories;

    _allData.sort((a, b) {
    // =============================================
    // ✨ 1. 모순 없는 타입 정렬 규칙으로 변경 ✨
    // =============================================
    // 타입이 다르면, enum에 정의된 순서(schedule -> deadline -> task)로 정렬
    if (a.type.index != b.type.index) {
      return a.type.index.compareTo(b.type.index);
    }

      // 2. 타입이 '일정'으로 같으면, 시간순으로 정렬
      if (a.type == ItemType.schedule) {
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return a.startTime!.compareTo(b.startTime!);
      }

      // 타입이 '기한'으로 같으면, endTime 기준으로 정렬 (마감일이 빠른 순)
      if (a.type == ItemType.deadline) {
        // endTime이 없는 경우(오류 데이터)를 대비해 맨 뒤로 보냄
        if (a.endTime == null) return 1;
        if (b.endTime == null) return -1;
        return a.endTime!.compareTo(b.endTime!);
      }
      
      // 3. 타입이 '할일'으로 같으면, 카테고리 우선순위로 정렬
      if (a.type == ItemType.task) {
        final priorityA = categories.indexWhere((c) => c.id == a.categoryId);
        final priorityB = categories.indexWhere((c) => c.id == b.categoryId);
        
        if (priorityA == -1) return 1;
        if (priorityB == -1) return -1;

        // 우선순위가 같으면 순서를 바꾸지 않음 (생성 순 유지)
        if (priorityA != priorityB) {
          return priorityA.compareTo(priorityB);
        }
      }
      
      // 그 외의 경우 (같은 카테고리 내의 할일 등) 순서 유지
      return 0;
    });
  }
  
  void addData(DailyData data) {
    _allData.add(data);
    _sortData();
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
        _sortData();
        notifyListeners();
      }
    } catch (e) {
      print('Could not find data with id: ${updatedData.id}');
    }
  }

  void changeItemType(String id, ItemType newType) {
    try {
      final oldItemIndex = _allData.indexWhere((i) => i.id == id);
      if (oldItemIndex == -1) return;

      final oldItem = _allData[oldItemIndex];
      if (oldItem.type == newType) return;

      DateTime? newStartTime = oldItem.startTime;
      DateTime? newEndTime = oldItem.endTime;

      // 타입 변경에 따른 데이터 조정
      if (newType == ItemType.task) {
        if(newStartTime != null) newStartTime = DateUtils.dateOnly(newStartTime);
        if(newEndTime != null) newEndTime = DateUtils.dateOnly(newEndTime);
      } else if (newType == ItemType.schedule) {
        if(newStartTime != null) {
          newStartTime = DateTime(newStartTime.year, newStartTime.month, newStartTime.day, 9, 0);
        }
        if(newEndTime != null) {
          newEndTime = DateTime(newEndTime.year, newEndTime.month, newEndTime.day, 10, 0);
        } else {
          newEndTime = newStartTime?.add(const Duration(hours: 1));
        }
      }

      // 기존 정보를 바탕으로 타입과 시간만 변경된 새 객체 생성
      final newItem = DailyData(
        id: oldItem.id,
        type: newType, // 타입 변경
        title: oldItem.title,
        categoryId: oldItem.categoryId,
        startTime: newStartTime, // 시간 변경
        endTime: newEndTime,     // 시간 변경
        isAllDay: oldItem.isAllDay,
        memo: oldItem.memo,
        notifications: oldItem.notifications,
        completionState: oldItem.completionState,
        resourceChanges: oldItem.resourceChanges,
      );

      // 기존 객체를 새 객체로 교체
      _allData[oldItemIndex] = newItem;

    _sortData();
    notifyListeners();
    } catch (e) {
      print('Could not find data with id: $id to change type.');
    }
  }

  void convertTaskToSchedule(DailyData task, int dropIndex, DateTime date) {
    try {
      final oldItemIndex = _allData.indexWhere((i) => i.id == task.id);
      if (oldItemIndex == -1) return;

      // 설정 가능한 쿠션 간격 (분 단위), 지금은 0으로 고정
      const _cushionInMinutes = 0;
      final cushion = const Duration(minutes: _cushionInMinutes);

      // 해당 날짜의 '일정'만 시간순으로 정렬해서 가져옴
      final schedules = _allData.where((d) => d.type == ItemType.schedule && DateUtils.isSameDay(d.startTime, date)).toList()
        ..sort((a, b) => a.startTime!.compareTo(b.startTime!));

      DateTime newStartTime;
      DateTime newEndTime;

      if (schedules.isEmpty) {
        // 케이스 1: 그날 일정이 하나도 없을 때
        newStartTime = DateTime.now();
        newEndTime = newStartTime.add(const Duration(hours: 1));
      } else if (dropIndex <= 0) {
        // 케이스 2: 맨 앞에 드롭했을 때
        newEndTime = schedules.first.startTime!.subtract(cushion);
        newStartTime = newEndTime.subtract(const Duration(hours: 1));
      } else if (dropIndex >= schedules.length) {
        // 케이스 3: 맨 뒤에 드롭했을 때
        newStartTime = schedules.last.endTime!.add(cushion);
        newEndTime = newStartTime.add(const Duration(hours: 1));
      } else {
        // 케이스 4: 두 일정 사이에 드롭했을 때
        final prevSchedule = schedules[dropIndex - 1];
        final nextSchedule = schedules[dropIndex];

        final gap = nextSchedule.startTime!.difference(prevSchedule.endTime!);

        // 빈틈이 (쿠션*2)보다 작으면 아무것도 하지 않고 종료
        if (gap.inMinutes <= _cushionInMinutes * 2) {
          return; 
        }

        newStartTime = prevSchedule.endTime!.add(cushion);
        newEndTime = nextSchedule.startTime!.subtract(cushion);
      }

      // 새 정보로 객체 생성
      final newItem = DailyData(
        id: task.id,
        type: ItemType.schedule, // 타입 변경
        title: task.title,
        categoryId: task.categoryId,
        startTime: newStartTime, // 계산된 시간 적용
        endTime: newEndTime,     // 계산된 시간 적용
        isAllDay: false,
        memo: task.memo,
        notifications: task.notifications,
        completionState: task.completionState,
        resourceChanges: task.resourceChanges,
      );

      // 기존 '할일'을 새로 생성된 '일정'으로 교체
      _allData[oldItemIndex] = newItem;
      _sortData();
      notifyListeners();

    } catch (e) {
      print('Failed to convert task to schedule: $e');
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