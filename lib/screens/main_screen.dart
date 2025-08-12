import 'package:allcal/models/daily_data.dart';
import 'package:allcal/providers/data_provider.dart';
import 'package:allcal/providers/ui_provider.dart';
import 'package:allcal/widgets/draggable_divider.dart';
import 'package:flutter/material.dart';
import 'package:allcal/widgets/main_app_bar.dart';
import 'package:allcal/widgets/monthly_calendar.dart';
import 'package:allcal/widgets/daily_list_view.dart';
import 'package:allcal/widgets/bottom_status_bar.dart';
import 'package:allcal/widgets/settings_drawer.dart';
import 'package:allcal/widgets/expanding_fab.dart';
import 'package:provider/provider.dart';
import 'package:allcal/providers/calendar_provider.dart';
import 'package:allcal/providers/category_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;

    final selectedDay = context.watch<CalendarProvider>().selectedDay;
    final dataProvider = context.watch<DataProvider>();
    final uiProvider = context.watch<UiProvider>();

    final categoryProvider = context.watch<CategoryProvider>();

    final allDayData = dataProvider.getDataForDay(selectedDay);

    final schedules = allDayData.where((d) => d.type == ItemType.schedule).toList();
    final deadlines = allDayData.where((d) => d.type == ItemType.deadline).toList();
    final tasks = allDayData.where((d) => d.type == ItemType.task).toList();

    // 화면 전체 높이의 약 45%를 캘린더 높이로 설정 (기존 400과 비슷하게)
    final calendarHeight = screenSize.height * 0.35; 
    // 화면 전체 높이의 약 10%를 하단 바 높이로 설정 (기존 80과 비슷하게)
    final bottomBarHeight = screenSize.height * 0.1;

    // 2. 생성된 리스트에 대해 sort 함수를 호출합니다.
    tasks.sort((a, b) {
      final priorityA = categoryProvider.categories.indexWhere((c) => c.id == a.categoryId);
      final priorityB = categoryProvider.categories.indexWhere((c) => c.id == b.categoryId);

      if (priorityA == -1) return 1;
      if (priorityB == -1) return -1;
      
      return priorityA.compareTo(priorityB);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(),
      drawer: const SettingsDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: calendarHeight,
                  child: CustomMonthlyCalendar(),
                ),
                const Divider(height: 1, color: Colors.black12),
                Expanded(
                  // [수정] 1층: 기본 좌우 분할 목록
                  child: Row(
                    children: [
                      // 이제 그냥 DailyListView를 호출하기만 하면 됩니다.
                      Expanded(child: DailyListView(items: schedules)),
                      const VerticalDivider(width: 1, color: Colors.black12),
                      Expanded(
                        // '할일' DragTarget은 기존과 동일 (단순 타입 변경)
                        child: DragTarget<DailyData>(
                          builder: (context, candidateData, rejectedData) {
                            bool isTarget = candidateData.isNotEmpty && candidateData.first?.type == ItemType.schedule;
                            return Container(
                              color: isTarget ? Colors.green.withOpacity(0.1) : Colors.transparent,
                              child: DailyListView(items: tasks),
                            );
                          },
                          onWillAccept: (data) => data?.type == ItemType.schedule,
                          onAccept: (data) {
                            context.read<DataProvider>().changeItemType(data.id, ItemType.task);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: bottomBarHeight),
              ],
            ),

            // [수정] 2층: 기한 패널 (조건부 표시)
            if (deadlines.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomBarHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final parentHeight = screenSize.height - calendarHeight - bottomBarHeight - MediaQuery.of(context).padding.top - kToolbarHeight;
                    final maxHeight = parentHeight;

                    // [수정] 이전의 Container와 BoxDecoration을 사용하는 코드로 복구합니다.
                    return Container(
                      height: uiProvider.deadlinePanelHeight,
                      decoration: BoxDecoration(
                        color: Colors.white, // 배경색
                        // 그림자는 직선으로 표시되는 이전 방식
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                        // 둥근 모서리
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      // 내용물을 둥글게 잘라내서 구분선이 삐져나오지 않도록 합니다.
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Column(
                          children: [
                            DraggableDivider(
                              onDrag: (details) {
                                final newHeight = uiProvider.deadlinePanelHeight - details.delta.dy;
                                uiProvider.setDeadlinePanelHeight(newHeight, maxHeight);
                              },
                            ),
                            Expanded(
                              child: DailyListView(items: deadlines),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 3층: 상태 바 (항상 표시)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              // BottomStatusBar에도 동일한 높이 값을 적용해 일관성 유지
              child: SizedBox(
                height: bottomBarHeight,
                child: BottomStatusBar(onAddPressed: _toggleFab)
              ),
            ),

            ExpandingFab(
              isOpen: _isFabOpen,
              animationController: _fabController,
              onToggle: _toggleFab,
            ),
          ],
        ),
      ),
    );
  }
}