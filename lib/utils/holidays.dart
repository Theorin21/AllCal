// lib/utils/holidays.dart (시간대 문제 수정 최종본)

import 'package:flutter/material.dart';

class KoreanHolidays {
  final Set<DateTime> _holidays;

  KoreanHolidays({required int year}) : _holidays = _getHolidaysForYear(year);

  bool isHoliday(DateTime date) {
    return _holidays.contains(DateUtils.dateOnly(date));
  }

  static Set<DateTime> _getHolidaysForYear(int year) {
    // [수정] 모든 DateTime.utc를 DateTime으로 변경하여 지역 시간대 기준으로 통일
    final baseHolidays = {
      DateTime(year, 1, 1),   // 신정
      DateTime(year, 3, 1),   // 삼일절
      DateTime(year, 5, 5),   // 어린이날
      DateTime(year, 6, 6),   // 현충일
      DateTime(year, 8, 15),  // 광복절
      DateTime(year, 10, 3),  // 개천절
      DateTime(year, 10, 9),  // 한글날
      DateTime(year, 12, 25), // 크리스마스
      ..._getLunarHolidays(year),
    };

    final substituteHolidays = _getSubstituteHolidays(year, baseHolidays);
    
    return baseHolidays..addAll(substituteHolidays);
  }

  static Set<DateTime> _getSubstituteHolidays(int year, Set<DateTime> baseHolidays) {
    final substitutes = <DateTime>{};
    
    final applicableHolidays = [
        DateTime(year, 3, 1),
        DateTime(year, 5, 5),
        DateTime(year, 8, 15),
        DateTime(year, 10, 3),
        DateTime(year, 10, 9),
        ..._getLunarHolidays(year).where((day) => day.month == 1 || day.month == 8)
    ];
    
    for (final holiday in applicableHolidays) {
      final holidayWeekday = holiday.weekday;
      
      if (holiday.month == 5 && holiday.day == 5) {
        if (holidayWeekday == DateTime.saturday || holidayWeekday == DateTime.sunday) {
          substitutes.add(_findNextAvailableDay(holiday, baseHolidays));
        }
      } 
      else {
        if (holidayWeekday == DateTime.sunday) {
          substitutes.add(_findNextAvailableDay(holiday, baseHolidays));
        }
      }
    }
    return substitutes;
  }

  static DateTime _findNextAvailableDay(DateTime startDate, Set<DateTime> baseHolidays) {
    var nextDay = startDate.add(const Duration(days: 1));
    while (baseHolidays.contains(nextDay) || nextDay.weekday == DateTime.saturday || nextDay.weekday == DateTime.sunday) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }

  static Set<DateTime> _getLunarHolidays(int year) {
    const lunarData = {
      2020: {'seollal': [1, 24], 'buddha': [4, 30], 'chuseok': [9, 30]},
      2021: {'seollal': [2, 11], 'buddha': [5, 19], 'chuseok': [9, 20]},
      2022: {'seollal': [1, 31], 'buddha': [5, 8], 'chuseok': [9, 9]},
      2023: {'seollal': [1, 21], 'buddha': [5, 27], 'chuseok': [9, 28]},
      2024: {'seollal': [2, 9], 'buddha': [5, 15], 'chuseok': [9, 16]},
      2025: {'seollal': [1, 28], 'buddha': [5, 5], 'chuseok': [10, 5]},
      2026: {'seollal': [2, 16], 'buddha': [5, 24], 'chuseok': [9, 24]},
      2027: {'seollal': [2, 6], 'buddha': [5, 13], 'chuseok': [9, 14]},
      2028: {'seollal': [1, 26], 'buddha': [5, 2], 'chuseok': [10, 2]},
      2029: {'seollal': [2, 12], 'buddha': [5, 20], 'chuseok': [9, 21]},
      2030: {'seollal': [2, 2], 'buddha': [5, 9], 'chuseok': [9, 11]},
    };
    
    if (!lunarData.containsKey(year)) return {};

    final yearData = lunarData[year]!;
    final seollal = DateTime(year, yearData['seollal']![0], yearData['seollal']![1]);
    final buddha = DateTime(year, yearData['buddha']![0], yearData['buddha']![1]);
    final chuseok = DateTime(year, yearData['chuseok']![0], yearData['chuseok']![1]);

    return {
      seollal.subtract(const Duration(days: 1)), seollal, seollal.add(const Duration(days: 1)),
      buddha,
      chuseok.subtract(const Duration(days: 1)), chuseok, chuseok.add(const Duration(days: 1)),
    };
  }
}