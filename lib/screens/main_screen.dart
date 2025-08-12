import 'dart:math';
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

    // 2. 생성된 리스트에 대해 sort 함수를 호출합니다.
    tasks.sort((a, b) {
      final priorityA = categoryProvider.categories.indexWhere((c) => c.id == a.categoryId);
      final priorityB = categoryProvider.categories.indexWhere((c) => c.id == b.categoryId);

      if (priorityA == -1) return 1;
      if (priorityB == -1) return -1;
      
      return priorityA.compareTo(priorityB);
    });

    // [수정] Stack을 PopScope 위젯으로 감싸줍니다.
    return PopScope(
      // FAB이 열려 있으면(true) 뒤로가기(pop)를 막고(false), 닫혀 있으면(false) 허용(true)합니다.
      canPop: !_isFabOpen,
      // 뒤로가기 제스처가 발생한 후 호출됩니다.
      onPopInvoked: (bool didPop) {
        // 만약 뒤로가기가 성공적으로 처리되었다면(didPop = true), 아무것도 하지 않습니다.
        if (didPop) {
          return;
        }
        // 뒤로가기가 canPop에 의해 막혔다면(didPop = false), FAB을 닫습니다.
        if (_isFabOpen) {
          _toggleFab();
        }
      },
      child: Stack(
        children: [
          // 1층: 기존 화면 전체 (Scaffold)
          Scaffold(
            backgroundColor: Colors.white,
            appBar: const MainAppBar(),
            drawer: const SettingsDrawer(),
            body: SafeArea(

              // =============================================
              // ✨ 1. LayoutBuilder를 body 전체를 감싸도록 이동 ✨
              // =============================================
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // constraints.maxHeight는 이제 AppBar와 SafeArea를 제외한 실제 사용 가능 높이
                  final availableHeight = constraints.maxHeight;

                  final calendarHeight = availableHeight * 0.45;
                  final bottomBarHeight = availableHeight * 0.12;
                  
                  // '일정/할일' 창이 차지하는 실제 높이
                  final listAreaHeight = availableHeight - calendarHeight - bottomBarHeight;

                  // =============================================
                  // ✨ 2. 정확한 maxHeight 계산 ✨
                  // =============================================
                  const minHeight = 20.0;
                  const singleItemHeight = 54.0;
                  // 규칙 1: 아래 목록이 가려지지 않도록 하는 최대 높이
                  final spaceBasedMaxHeight = (listAreaHeight - singleItemHeight);

                  // 규칙 2: 콘텐츠 높이에 맞춘 최대 높이
                  // (드래그 바 높이 + 모든 기한 아이템의 높이 합)
                  final contentBasedMaxHeight = minHeight + 4 + (deadlines.length * singleItemHeight);

                  // =============================================
                  // ✨ 2. 두 값 중 더 작은 값을 최종 maxHeight로 선택 ✨
                  // =============================================
                  final maxHeight = min(spaceBasedMaxHeight, contentBasedMaxHeight).clamp(minHeight, listAreaHeight);
                  
                  final initialHeight = (minHeight + singleItemHeight + 4).clamp(minHeight, maxHeight);

                  final List<double> snapPoints = [];
                  // 0단계: 드래그 바만 보이는 높이
                  snapPoints.add(minHeight);
                  // 1, 2, 3...개 아이템이 보이는 높이를 순서대로 추가
                  for (int i = 1; i <= deadlines.length; i++) {
                    final snapHeight = minHeight + 4 + (i * singleItemHeight);
                    if (snapHeight <= maxHeight) {
                      snapPoints.add(snapHeight);
                    } else {
                      // 최대 높이를 초과하면 더 이상 추가하지 않음
                      break;
                    }
                  }

                  // 최초 높이를 안전하게 설정
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (deadlines.isNotEmpty) {
                      context.read<UiProvider>().initializeDeadlinePanelHeight(initialHeight);
                    }
                  });        

                  return Stack(
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
                          // [수정] 이전의 Container와 BoxDecoration을 사용하는 코드로 복구합니다.
                          child: Container(
                            height: uiProvider.deadlinePanelHeight,
                            decoration: BoxDecoration(
                              color: Colors.white, // 배경색
                              // 그림자는 직선으로 표시되는 이전 방식
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.0),
                                  blurRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                              // 둥근 모서리
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                            ),
                            // 내용물을 둥글게 잘라내서 구분선이 삐져나오지 않도록 합니다.
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                              child: Column(
                                children: [
                                  DraggableDivider(
                                    onDrag: (details) {
                                      final newHeight = uiProvider.deadlinePanelHeight - details.delta.dy;
                                      // =============================================
                                      // ✨ 3. 계산된 최소/최대 높이를 사용하여 업데이트 ✨
                                      // =============================================
                                      uiProvider.setDeadlinePanelHeight(newHeight, minHeight, maxHeight);
                                    },
                                    onDragEnd: () {
                                      final currentHeight = uiProvider.deadlinePanelHeight;
                                      
                                      // 현재 높이에서 가장 가까운 자석 지점을 찾음
                                      final closestSnapPoint = snapPoints.reduce(
                                        (a, b) => (a - currentHeight).abs() < (b - currentHeight).abs() ? a : b
                                      );
                                      
                                      // 가장 가까운 지점으로 높이를 최종 설정
                                      uiProvider.setDeadlinePanelHeight(closestSnapPoint, minHeight, maxHeight);
                                    },
                                  ),
                                  Expanded(
                                    child: DailyListView(items: deadlines),
                                  ),
                                ],
                              ),
                            ),
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
                    ],
                  );
                },
              ),
            ),
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