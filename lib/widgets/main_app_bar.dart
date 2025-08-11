// lib/widgets/main_app_bar.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:allcal/providers/calendar_provider.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // [수정] Provider를 사용하여 현재 달력의 기준 날짜를 가져옵니다.
    final calendarProvider = context.watch<CalendarProvider>();
    final displayDate = calendarProvider.focusedDay;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          // [수정] Scaffold의 Drawer를 열도록 명령합니다.
          Scaffold.of(context).openDrawer();
        },
      ),
      // [수정] Row와 GestureDetector를 사용하여 제목을 버튼처럼 만듭니다.
      title: GestureDetector(
        onTap: () {
          // 월 선택 다이얼로그를 띄웁니다.
          showMonthPicker(
            context: context,
            initialDate: displayDate,
            locale: const Locale('ko'), // 한국어 설정
          ).then((date) {
            if (date != null) {
              // 날짜가 선택되면 Provider를 통해 해당 월로 이동합니다.
              context.read<CalendarProvider>().jumpToMonth(date);
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [수정] 날짜를 'yyyy.MM.' 형식으로 동적으로 표시합니다.
            Text(DateFormat('yyyy.MM.').format(displayDate)),
            const Icon(Icons.keyboard_arrow_down, size: 24.0),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_today)),
      ],
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}