// lib/providers/resource_provider.dart
import 'package:flutter/material.dart';
import 'package:allcal/models/resource.dart';
import 'package:uuid/uuid.dart';

class ResourceProvider extends ChangeNotifier {
  final List<Resource> _resources = [
    // --- 최종 자원 ---
    Resource(id: 'health', name: '체력', color: Colors.red, iconData: Icons.favorite, computation: {'health': 1.0}),
    Resource(id: 'mentalEnergy', name: '정신력', color: Colors.blue, iconData: Icons.electric_bolt, computation: {'mentalEnergy': 1.0}),
    Resource(id: 'capital', name: '자본', color: Colors.green, iconData: Icons.attach_money, computation: {'capital': 1.0}),
    
    // --- 증감 자원 ---
    Resource(id: 'stress', name: '스트레스', color: Colors.yellow, iconData: Icons.bolt, computation: {'mentalEnergy': -1.0}),
    Resource(id: 'efficacy', name: '자기 효능감', color: Colors.purple, iconData: Icons.star, computation: {'mentalEnergy': 1.0}),
  ];
  
  List<Resource> get resources => _resources;
  
  // TODO: 자원 추가, 수정, 삭제, 순서 변경 함수 구현
}