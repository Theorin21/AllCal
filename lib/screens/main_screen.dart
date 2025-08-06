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
    final records = allDayData.where((d) => d.type == ItemType.record).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(),
      drawer: const SettingsDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 450,
                child: CustomMonthlyCalendar(),
              ),
              const Divider(height: 1, color: Colors.black12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalHeight = constraints.maxHeight;

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(child: DailyListView(items: schedules)),
                              if (deadlines.isNotEmpty) ...[
                                DraggableDivider(
                                  onDrag: (details) {
                                    final newHeight = uiProvider.deadlinePanelHeight - details.delta.dy;
                                    final maxHeight = totalHeight - 80;
                                    uiProvider.setDeadlinePanelHeight(newHeight, maxHeight);
                                  },
                                ),
                                SizedBox(
                                  height: uiProvider.deadlinePanelHeight,
                                  child: DailyListView(items: deadlines),
                                ),
                              ]
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1, color: Colors.black12),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(child: DailyListView(items: tasks)),
                              if (records.isNotEmpty) ...[
                                DraggableDivider(
                                  onDrag: (details) {
                                    final newHeight = uiProvider.recordPanelHeight - details.delta.dy;
                                    final maxHeight = totalHeight - 80;
                                    uiProvider.setRecordPanelHeight(newHeight, maxHeight);
                                  },
                                ),
                                SizedBox(
                                  height: uiProvider.recordPanelHeight,
                                  child: DailyListView(items: records),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
              BottomStatusBar(onAddPressed: _toggleFab),
            ],
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