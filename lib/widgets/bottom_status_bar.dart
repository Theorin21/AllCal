// lib/widgets/bottom_status_bar.dart

import 'package:allcal/models/resource.dart';
import 'package:allcal/providers/resource_provider.dart';
import 'package:allcal/providers/status_provider.dart';
import 'package:allcal/widgets/status_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomStatusBar extends StatelessWidget {
  final VoidCallback onAddPressed;

  const BottomStatusBar({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<StatusProvider>();
    final resourceProvider = context.watch<ResourceProvider>();
    
    final healthResource = resourceProvider.resources.firstWhere((r) => r.id == 'health');
    final mentalResource = resourceProvider.resources.firstWhere((r) => r.id == 'mentalEnergy');
    final capitalResource = resourceProvider.resources.firstWhere((r) => r.id == 'capital');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색은 흰색 유지
        boxShadow: [
          // 위쪽에만 은은한 그림자를 추가
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 그림자 색상
            blurRadius: 4, // 흐림 효과 반경
            offset: const Offset(0, -2), // 그림자 위치 (y축 위쪽으로 -2)
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            // [수정] Row -> Table로 변경하여 그리드 레이아웃을 다시 구현합니다.
            child: Table(
              // 각 열(Column)의 너비를 어떻게 정할지 정의합니다.
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(), // 0번 열(아이콘)은 내용물 크기에 맞춤
                1: IntrinsicColumnWidth(), // 1번 열(자원 값)도 내용물 중 가장 넓은 것에 맞춤
                2: FlexColumnWidth(),      // 2번 열(상태 바)은 남는 공간을 모두 차지
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _buildStatusTableRow(
                  resource: healthResource,
                  value: statusProvider.currentStatus.health,
                ),
                _buildStatusTableRow(
                  resource: mentalResource,
                  value: statusProvider.currentStatus.mentalEnergy,
                ),
                _buildStatusTableRow(
                  resource: capitalResource,
                  value: statusProvider.currentStatus.capital,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.blue),
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }

  // [수정] Row를 반환하는 대신, TableRow를 반환합니다.
  TableRow _buildStatusTableRow({required Resource resource, required double value}) {
    return TableRow(
      children: <Widget>[
        // 1번 열: 아이콘
        Icon(resource.iconData, color: resource.color, size: 20),
        
        // 2번 열: 자원 값 (오른쪽 정렬 및 간격)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            value.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: resource.color,
            ),
          ),
        ),

        // 3번 열: 상태 바
        StatusProgressBar(
          value: value,
          color: resource.color,
        ),
      ],
    );
  }
}