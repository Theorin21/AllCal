import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allcal/providers/calendar_provider.dart';
import 'package:allcal/utils/holidays.dart';

class CustomMonthlyCalendar extends StatelessWidget {
  const CustomMonthlyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final focusedDate = calendarProvider.focusedDay;

    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDayOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);

    final firstDayOfCalendar = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    final lastDayOfCalendar = lastDayOfMonth.add(Duration(days: DateTime.saturday - (lastDayOfMonth.weekday % 7)));

    final totalDaysInGrid = lastDayOfCalendar.difference(firstDayOfCalendar).inDays + 1;
    final calendarDays = List.generate(totalDaysInGrid, (index) => firstDayOfCalendar.add(Duration(days: index)));

    List<List<DateTime>> weeks = [];
    for (var i = 0; i < calendarDays.length; i += 7) {
      weeks.add(calendarDays.sublist(i, i + 7));
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 100) {
          context.read<CalendarProvider>().goToPreviousMonth();
        } else if (details.primaryVelocity! < -100) {
          context.read<CalendarProvider>().goToNextMonth();
        }
      },
      child: Column(
        children: [
          _buildDaysOfWeek(),
          Expanded(
            child: Column(
              children: weeks.map((week) {
                // =============================================
                // ✨ 1. 각 주(week)를 Row로 변경 ✨
                // =============================================
                return Expanded(
                  child: Row(
                    children: week.map((date) {
                      // 각 날짜에 대해 _buildDayCell을 호출하여 세로 칸을 만듬
                      return _buildDayCell(context, date);
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 아래 함수들은 변경사항 없습니다 ---

  Widget _buildDaysOfWeek() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    
    return Padding(
      // 상하 여백만 유지하고, 좌우 여백은 제거하여 날짜와 완벽하게 정렬
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        // mainAxisAlignment는 더 이상 필요 없으므로 제거
        children: weekdays.map((day) {
          Color dayColor = Colors.black;
          if (day == '토') dayColor = Colors.blue;
          if (day == '일') dayColor = Colors.red;
          
          // =============================================
          // ✨ 1. 각 요일을 Expanded 위젯으로 감싸기 ✨
          // =============================================
          return Expanded(
            // =============================================
            // ✨ 2. Center 위젯으로 감싸서 중앙 정렬 ✨
            // =============================================
            child: Center(
              child: Text(
                day,
                style: TextStyle(color: dayColor)
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final calendarProvider = context.watch<CalendarProvider>();
    final selectedDate = calendarProvider.selectedDay;
    final focusedDate = calendarProvider.focusedDay;
    final today = DateTime.now();
    final koreanHolidays = KoreanHolidays(year: focusedDate.year);

    final isSelected = DateUtils.isSameDay(date, selectedDate);
    final isToday = DateUtils.isSameDay(date, today);
    final isCurrentMonth = date.month == focusedDate.month;
    final isHoliday = koreanHolidays.isHoliday(date);

    Color textColor;
    if (!isCurrentMonth) {
      // 이번 달이 아닌 경우 -> 요일별 색 + 0.5 투명도
      if (isHoliday || date.weekday == DateTime.sunday) {
        textColor = Colors.red.withValues(alpha: 0.5); // 빨간색 + 반투명
      } else if (date.weekday == DateTime.saturday) {
        textColor = Colors.blue.withValues(alpha: 0.5); // 파란색 + 반투명
      } else {
        textColor = Colors.black.withValues(alpha: 0.5); // 검정색 + 반투명
      }
    } else if (isSelected) {
      textColor = Colors.white;
    } else if (isHoliday || date.weekday == DateTime.sunday) {
      textColor = Colors.red;
    } else if (date.weekday == DateTime.saturday) {
      textColor = Colors.blue;
    } else {
      textColor = Colors.black;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<CalendarProvider>().onDaySelected(date, date);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // --- 1. W 곡선을 위한 빈 공간 ---
            Expanded(
              child: Container(color: Colors.transparent),
            ),
            // --- 2. 날짜를 그리는 부분 ---
            SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isToday)
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isCurrentMonth ? FontWeight.normal : FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}