import 'package:flutter/material.dart';
import 'package:allcal/models/resource.dart'; // [추가]

// [추가] 3단계 완료 상태를 정의하는 열거형(enum)
enum CompletionState {
  notCompleted, // 완료되지 않음
  completed,    // 완료는 했지만, 자원 증감은 입력 안 함
  detailed,     // 자원 증감까지 모두 입력 완료
}

// 데이터 타입을 명확히 구분하기 위한 열거형(enum)
enum ItemType { schedule, deadline, task, record }

class DailyData {
  final String id;
  final ItemType type;
  String title;
  String categoryId;
  
  DateTime? startTime;
  DateTime? endTime;
  bool isAllDay;

  String? memo;
  
  List<Duration> notifications;

  // [수정] bool isCompleted -> CompletionState completionState
  CompletionState completionState;

  // [추가] 자원 변화량 기록
  List<ResourceChange> resourceChanges;

  DailyData({
    required this.id,
    required this.type,
    required this.title,
    required this.categoryId,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.memo,
    this.notifications = const [],
    // [수정] 기본 상태를 notCompleted로 설정
    this.completionState = CompletionState.notCompleted,
    this.resourceChanges = const [], // [추가]
  });
}