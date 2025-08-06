// lib/providers/calendar_provider.dart

import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners(); // '선택된 날짜가 바뀌었다!'고 다른 위젯들에게 알림
  }

  // [추가] 이전 달로 이동
  void goToPreviousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
  }

  // [추가] 다음 달로 이동
  void goToNextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }

  // [추가] 특정 날짜로 바로 이동 (3번 기능에서 사용)
  void jumpToMonth(DateTime date) {
    _focusedDay = date;
    // 선택된 날짜도 해당 월의 1일로 초기화해주는 것이 자연스러움
    _selectedDay = date; 
    notifyListeners();
  }
}