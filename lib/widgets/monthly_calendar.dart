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
    final selectedDate = calendarProvider.selectedDay;

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
      // [수정] 명확한 레이아웃 구조로 변경
      child: Column(
        children: [
          // 1. 요일 위젯 (고정 높이)
          _buildDaysOfWeek(),
          
          // 2. 남은 모든 공간을 차지하는 주(Week)들의 컨테이너
          Expanded(
            child: Column(
              // 주(week)들이 남은 공간을 균등하게 나눠 가짐
              children: weeks.map((week) {
                return Expanded(
                  child: Container(
                    // [디버깅용] 각 주(week)의 영역을 확인하기 위한 임시 색상
                    // color: Colors.amber.withOpacity(0.2), 
                    // 각 주(week)는 다시 'W곡선'과 '날짜' 영역으로 나뉨
                    child: Column(
                      children: [
                        // 2-1. W곡선이 들어갈 빈 공간 (남는 공간을 모두 차지)
                        Expanded(
                          child: Container(
                            // [디버깅용] W곡선 영역 확인을 위한 임시 색상
                            // color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        // 2-2. 날짜가 들어갈 공간 (고정 높이)
                        _buildDateRow(context, week, selectedDate, focusedDate.month, focusedDate.year),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          Color dayColor = Colors.grey.shade600;
          if (day == '토') dayColor = Colors.blue;
          if (day == '일') dayColor = Colors.red;
          return Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: dayColor));
        }).toList(),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, List<DateTime> week, DateTime selectedDate, int currentMonth, int currentYear) {
    final today = DateTime.now();
    final koreanHolidays = KoreanHolidays(year: currentYear);

    return Container(
      // [디버깅용] 날짜 영역 확인을 위한 임시 색상
      // color: Colors.pink.withOpacity(0.2),
      height: 36, // 날짜 영역의 높이를 고정
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = week[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, today);
          final isCurrentMonth = date.month == currentMonth;
          final isHoliday = koreanHolidays.isHoliday(date);

          Color textColor;
          if (!isCurrentMonth) {
            textColor = Colors.grey.withOpacity(0.5);
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isToday)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.black, // 선택된 날 위에 오늘 테두리가 흰색으로 표시
                          width: 1.5,
                        ),
                      ),
                    ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isCurrentMonth ? FontWeight.normal : FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}