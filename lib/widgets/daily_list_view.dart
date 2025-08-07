import 'package:allcal/models/category.dart';
import 'package:allcal/providers/category_provider.dart';
import 'package:allcal/providers/resource_provider.dart';
import 'package:allcal/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allcal/models/daily_data.dart';
import 'package:allcal/providers/calendar_provider.dart';
import 'package:allcal/providers/data_provider.dart';
import 'package:intl/intl.dart';
import 'package:allcal/screens/item_edit_screen.dart';
import 'package:allcal/screens/resource_input_screen.dart';

class DailyListView extends StatelessWidget {
  final List<DailyData> items;
  const DailyListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildListItem(context, items[index]);
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DailyData data) {
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.categories.firstWhere(
      (cat) => cat.id == data.categoryId,
      orElse: () => Category(id: 'not_found', name: '', color: Colors.grey),
    );
    final categoryColor = category.color;

    final timeText = _formatTimeText(data, context);
    final bool isFinished = data.completionState != CompletionState.notCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // [수정] Expanded 부분을 GestureDetector로 감싸서 터치 영역을 확장합니다.
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ItemEditScreen(itemType: data.type, data: data),
                  fullscreenDialog: true,
                ));
              },
              behavior: HitTestBehavior.opaque,
              // [수정] 색상 아이콘과 텍스트를 새로운 Row로 묶습니다.
              child: Row(
                children: [
                  if (data.type == ItemType.schedule)
                    Container(width: 4, height: 30, color: categoryColor),
                  if (data.type == ItemType.deadline)
                    CustomPaint(
                      size: const Size(4, 30),
                      painter: DeadlinePainter(color: categoryColor),
                    ),
                  if (data.type == ItemType.task || data.type == ItemType.record)
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: categoryColor, shape: BoxShape.circle)),
                  
                  const SizedBox(width: 8),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 탭하면 '수정' 모드로 ItemEditScreen을 엽니다.
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ItemEditScreen(
                            itemType: data.type,
                            data: data, // [핵심] 탭한 항목의 데이터를 전달
                          ),
                          fullscreenDialog: true,
                        ));
                      },
                      // 배경이 없는 위젯도 탭 영역으로 인식하도록 설정
                      behavior: HitTestBehavior.opaque, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: TextStyle(
                              fontSize: 15,
                              decoration: isFinished ? TextDecoration.lineThrough : TextDecoration.none,
                              color: isFinished ? Colors.grey : Colors.black,
                            ),
                          ),
                          if (timeText.isNotEmpty)
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: isFinished ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),

                  // [수정] InkWell -> GestureDetector로 변경하여 onLongPress 추가
                  GestureDetector(
                    behavior: HitTestBehavior.opaque, // 투명한 영역도 터치되도록
                    onTap: () {
                      switch (data.completionState) {
                        case CompletionState.notCompleted:
                          // [수정] setCompleted 함수 호출
                          context.read<DataProvider>().setCompleted(data.id);
                          break;
                        case CompletionState.completed:
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // ResourceInputScreen을 AlertDialog로 감싸서 팝업 형태로 만듭니다.
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(0),
                                // --- [추가] 디자인 속성들 ---
                                backgroundColor: Colors.white, // 배경색
                                elevation: 8.0, // 그림자 농도
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0), // 모서리를 12만큼 둥글게
                                ),
                                // [수정] SizedBox로 감싸서 가로 길이를 고정합니다.
                                content: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
                                  child: ResourceInputScreen(dataId: data.id),
                                ),
                              );
                            },
                          );
                          break;
                        case CompletionState.detailed:
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // ResourceInputScreen을 AlertDialog로 감싸서 팝업 형태로 만듭니다.
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(0),
                                // --- [추가] 디자인 속성들 ---
                                backgroundColor: Colors.white, // 배경색
                                elevation: 8.0, // 그림자 농도
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0), // 모서리를 12만큼 둥글게
                                ),
                                // [수정] SizedBox로 감싸서 가로 길이를 고정합니다.
                                content: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
                                  child: ResourceInputScreen(dataId: data.id,
                                  // [수정] '수정' 모드를 위해 기존 자원 증감 값을 전달합니다.
                                  initialChanges: data.resourceChanges,),
                                ),
                              );
                            },
                          );
                          break;
                      }
                    },
                    onLongPress: () {
                      // [추가] 꾹 누르면 상태 되돌리기 및 상태바 재계산
                      final dataProvider = context.read<DataProvider>();
                      dataProvider.revertCompletionState(data.id);
                      
                      final resourceProvider = context.read<ResourceProvider>();
                      final statusProvider = context.read<StatusProvider>();
                      statusProvider.recalculateStatus(dataProvider.allData, resourceProvider.resources);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildCompletionIcon(context, data),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [수정] 자원 증감 정보를 아이콘과 함께 제대로 표시하도록 변경
  Widget _buildCompletionIcon(BuildContext context, DailyData data) {
    switch (data.completionState) {
      case CompletionState.notCompleted:
        return const Icon(Icons.check_box_outline_blank, color: Colors.grey);
      case CompletionState.completed:
        return const Icon(Icons.add, color: Colors.grey);
      case CompletionState.detailed:
        // 자원 정보를 가져오기 위해 ResourceProvider에 접근
        final resourceProvider = context.read<ResourceProvider>();
        // [수정] Row -> Column으로 변경하여 자식들을 세로로 쌓습니다.
        // [수정] 아이콘 열과 텍스트 열을 분리하기 위해 Row > Column 구조 사용
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 아이콘만 모아놓은 Column
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.resourceChanges.map((change) {
                try {
                  final resource = resourceProvider.resources.firstWhere((r) => r.id == change.resourceId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Icon(resource.iconData, color: resource.color, size: 12),
                  );
                } catch (e) { return const SizedBox.shrink(); }
              }).toList(),
            ),
            const SizedBox(width: 2),
            // 2. 텍스트만 모아놓은 Column
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.resourceChanges.map((change) {
                try {
                  final resource = resourceProvider.resources.firstWhere((r) => r.id == change.resourceId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Text(
                      change.amount.toString(),
                      style: TextStyle(fontSize: 12, color: resource.color, fontWeight: FontWeight.bold, height: 1.15),
                    ),
                  );
                } catch (e) { return const SizedBox.shrink(); }
              }).toList(),
            ),
          ],
        );
    }
  }

  String _formatTimeText(DailyData data, BuildContext context) {
    if (data.startTime == null) return '';

    final selectedDay = context.read<CalendarProvider>().selectedDay;
    final start = data.startTime!;
    final end = data.endTime;
    final timeFormat = DateFormat('HH:mm');

    switch (data.type) {
      case ItemType.schedule:
        if (start == null || end == null) return '';
        final isSameDay = DateUtils.isSameDay(start, end);
        if (isSameDay) return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
        
        final isStartDay = DateUtils.isSameDay(start, selectedDay);
        if (isStartDay) return '${timeFormat.format(start)} ~';

        final isEndDay = DateUtils.isSameDay(end, selectedDay);
        if (isEndDay) return '~ ${timeFormat.format(end)}';
        
        return '';
      
      case ItemType.deadline:
        // [수정] start -> end로 변경
      if (end == null) return '';
        return '~ ${timeFormat.format(end)}';  

      case ItemType.task:
        return '';

      case ItemType.record:
        // [수정] start -> end로 변경
        if (end == null) return '';
        return timeFormat.format(end);
      
      default:
        return '';
    }
  }
}

class DeadlinePainter extends CustomPainter {
  final Color color;
  DeadlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 6.0;

    final path = Path();
    
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height - cornerSize);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}