// lib/widgets/status_progress_bar.dart

import 'package:flutter/material.dart';

class StatusProgressBar extends StatelessWidget {
  final double value; // 현재 값 (0 ~ 200)
  final Color color;   // 막대의 색상

  const StatusProgressBar({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = (value / 200).clamp(0.0, 1.0);

    // [수정] Stack을 사용하여 배경, 값, 그림자를 겹쳐서 표현
    return Stack(
      children: [
        // 1. 배경 트랙 (은은한 배경색)
        Container(
          height: 12,
          decoration: BoxDecoration(
            // 자원 색상의 매우 연한 버전을 배경으로 사용
            color: color.withOpacity(0.2), 
            borderRadius: BorderRadius.circular(4), // 곡률 4로 조정
          ),
        ),
        // 2. 값 막대 (앞에 표시됨)
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: ratio,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4), // 곡률 4로 조정
              // [추가] 미세한 그림자 효과
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}