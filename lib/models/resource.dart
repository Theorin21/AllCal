// lib/models/resource.dart
import 'package:flutter/material.dart';

class Resource {
  final String id;
  String name;
  Color color;
  IconData iconData;
  // TODO: 커스텀 이미지 경로 추가
  
  // Map<String, double>은 연산식을 표현합니다.
  // 예: {'health': -1.0} -> 체력을 1.0배율로 감소
  Map<String, double> computation;

  Resource({
    required this.id,
    required this.name,
    required this.color,
    required this.iconData,
    required this.computation,
  });
}

// DailyData에 기록될 자원 변화량
class ResourceChange {
  final String resourceId;
  final int amount;

  ResourceChange({required this.resourceId, required this.amount});
}