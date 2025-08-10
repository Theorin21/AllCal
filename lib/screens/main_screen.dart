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
    final selectedDay = context.watch<CalendarProvider>().selectedDay;
    final dataProvider = context.watch<DataProvider>();
    final uiProvider = context.watch<UiProvider>();

    final allDayData = dataProvider.getDataForDay(selectedDay);

    final schedules = allDayData.where((d) => d.type == ItemType.schedule).toList();
    final deadlines = allDayData.where((d) => d.type == ItemType.deadline).toList();
    final tasks = allDayData.where((d) => d.type == ItemType.task).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(),
      drawer: const SettingsDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 400,
                child: CustomMonthlyCalendar(),
              ),
              const Divider(height: 1, color: Colors.black12),
              Expanded(
                // [수정] 1층: 기본 좌우 분할 목록
                child: Row(
                  children: [
                    Expanded(
                      child: DragTarget<DailyData>(
                        builder: (context, candidateData, rejectedData) {
                          // 드래그 중인 아이템이 위로 올라왔을 때 배경색 변경
                          bool isTarget = candidateData.isNotEmpty && candidateData.first?.type == ItemType.task;
                          return Container(
                            color: isTarget ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                            child: DailyListView(items: schedules),
                          );
                        },
                        // '할일' 타입만 받도록 설정
                        onWillAccept: (data) => data?.type == ItemType.task,
                        // 드롭 성공 시 타입 변경 함수 호출
                        onAccept: (data) {
                          context.read<DataProvider>().changeItemType(data.id, ItemType.schedule);
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.black12),
                    // =============================================
                    // ✨ 2. '할일' 목록을 DragTarget으로 감싸기 ✨
                    // =============================================
                    Expanded(
                      child: DragTarget<DailyData>(
                        builder: (context, candidateData, rejectedData) {
                          bool isTarget = candidateData.isNotEmpty && candidateData.first?.type == ItemType.schedule;
                          return Container(
                            color: isTarget ? Colors.green.withOpacity(0.1) : Colors.transparent,
                            child: DailyListView(items: tasks),
                          );
                        },
                        // '일정' 타입만 받도록 설정
                        onWillAccept: (data) => data?.type == ItemType.schedule,
                        // 드롭 성공 시 타입 변경 함수 호출
                        onAccept: (data) {
                          context.read<DataProvider>().changeItemType(data.id, ItemType.task);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // 상태 바가 들어갈 빈 공간 확보
            ],
          ),

          // [수정] 2층: 기한 패널 (조건부 표시)
          if (deadlines.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final parentHeight = MediaQuery.of(context).size.height - 400 - 80 - MediaQuery.of(context).padding.top - kToolbarHeight;
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
            child: BottomStatusBar(onAddPressed: _toggleFab),
          ),

          ExpandingFab(
            isOpen: _isFabOpen,
            animationController: _fabController,
            onToggle: _toggleFab,
          ),
        ],
      ),
    );
  }
}