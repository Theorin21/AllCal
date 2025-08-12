// lib/widgets/draggable_divider.dart
import 'package:flutter/material.dart';

class DraggableDivider extends StatelessWidget {
  final Function(DragUpdateDetails) onDrag;

  // ✨ 1. 드래그 종료 이벤트를 위한 콜백 함수 추가 ✨
  final VoidCallback? onDragEnd;

  const DraggableDivider({
    super.key, 
    required this.onDrag,
    this.onDragEnd, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onDrag,
      // ✨ 2. 드래그 종료를 감지하는 onVerticalDragEnd 추가 ✨
      onVerticalDragEnd: (_) => onDragEnd?.call(),
      child: Container(
        width: double.infinity,
        height: 20, // 터치 영역 확보를 위한 높이
        color: Colors.transparent, // 배경은 투명
        child: Column(
          children: [
            // 위쪽 구분선
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 6),
            // 드래그 핸들 (가운데 짧은 선)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}