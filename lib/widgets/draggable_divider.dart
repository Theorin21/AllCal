// lib/widgets/draggable_divider.dart
import 'package:flutter/material.dart';

/// 사용자가 요청한 디자인이 적용된 드래그 가능한 구분선 위젯
class DraggableDivider extends StatelessWidget {
  final Function(DragUpdateDetails) onDrag;
  final VoidCallback? onDragEnd;

  const DraggableDivider({
    super.key,
    required this.onDrag,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetector가 드래그 이벤트를 감지합니다.
    return GestureDetector(
      onVerticalDragUpdate: onDrag,
      onVerticalDragEnd: (_) => onDragEnd?.call(),
      child: Container(
        width: double.infinity,
        height: 20, // 터치 영역과 위젯을 그리기에 충분한 높이
        color: Colors.transparent, // 배경은 투명하게 하여 터치만 감지
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. 배경에 그려지는 볼록한 구분선
            const HandleDivider(),

            // 2. 구분선 위에 표시되는 드래그 핸들 막대
            Container(
              width: 40,
              height: 2,
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

/// 중앙이 볼록하게 솟아오른 모양의 구분선을 그리는 위젯
class HandleDivider extends StatelessWidget {
  const HandleDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _HandleDividerPainter(),
      ),
    );
  }
}

class _HandleDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const curveWidth = 20.0;    // 곡선 부분의 너비
    const topLineWidth = 50.0;  // 위쪽 직선의 너비
    const humpHeight = 20.0;    // 솟아오르는 높이
    const smoothness = 0.5;     // 곡선의 부드러움 제어

    final midX = size.width / 2;
    // 선이 그려질 Y축 위치를 화면 중앙으로 조정
    final startY = size.height / 2 + humpHeight / 2;

    final path = Path();
    
    // 1. 왼쪽 직선
    path.moveTo(0, startY);
    path.lineTo(midX - topLineWidth / 2 - curveWidth, startY);

    // 2. 부드럽게 솟아오르는 S자 곡선 (Cubic Bezier 사용)
    path.cubicTo(
      // 제어점 1: 시작 부분의 곡률 제어 (수평 유지)
      (midX - topLineWidth / 2 - curveWidth) + (curveWidth * smoothness), startY,
      // 제어점 2: 끝 부분(정상)의 곡률 제어 (수평 유지)
      (midX - topLineWidth / 2) - (curveWidth * (1 - smoothness)), startY - humpHeight,
      // 끝점: 곡선의 정상
      midX - topLineWidth / 2, startY - humpHeight,
    );

    // 3. 위쪽 직선
    path.lineTo(midX + topLineWidth / 2, startY - humpHeight);

    // 4. 부드럽게 내려오는 S자 곡선 (Cubic Bezier 사용)
    path.cubicTo(
      // 제어점 1: 시작 부분(정상)의 곡률 제어 (수평 유지)
      (midX + topLineWidth / 2) + (curveWidth * (1 - smoothness)), startY - humpHeight,
      // 제어점 2: 끝 부분의 곡률 제어 (수평 유지)
      (midX + topLineWidth / 2 + curveWidth) - (curveWidth * smoothness), startY,
      // 끝점: 다시 직선으로 돌아옴
      midX + topLineWidth / 2 + curveWidth, startY,
    );

    // 5. 오른쪽 직선
    path.lineTo(size.width, startY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
