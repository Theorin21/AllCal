import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:allcal/models/daily_data.dart';
import 'package:allcal/screens/item_edit_screen.dart';
import 'package:material_symbols_icons/symbols.dart';

class FabAction {
  final String label;
  final IconData icon;
  final ItemType type;
  FabAction({required this.label, required this.icon, required this.type});
}

class ExpandingFab extends StatefulWidget {
  final bool isOpen;
  final AnimationController animationController;
  final VoidCallback onToggle;

  const ExpandingFab({
    super.key,
    required this.isOpen,
    required this.animationController,
    required this.onToggle,
  });

  @override
  State<ExpandingFab> createState() => _ExpandingFabState();
}

class _ExpandingFabState extends State<ExpandingFab> {
  late final Animation<double> _animation;

  final List<FabAction> actions = [
    FabAction(label: '일정', icon: Symbols.calendar_add_on, type: ItemType.schedule),
    FabAction(label: '기한', icon: Icons.flag_outlined, type: ItemType.deadline),
    FabAction(label: '할일', icon: Icons.check_box_outlined, type: ItemType.task),
  ];

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    );
  }

  void _onButtonPressed(ItemType type) {
    widget.onToggle();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ItemEditScreen(itemType: type),
      fullscreenDialog: true,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    // [수정] 위젯 전체를 AnimatedBuilder로 감싸 애니메이션의 모든 프레임을 제어합니다.
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // [수정] 애니메이션이 끝나면(값이 0) 터치 이벤트를 무시하여 아래 화면과 상호작용할 수 있게 합니다.
        return IgnorePointer(
          ignoring: _animation.value == 0,
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.bottomRight,
              clipBehavior: Clip.none,
              children: [
                // 배경 (블러 + 탭 감지)
                BackdropFilter(
                  filter: ImageFilter.blur(
                    // 애니메이션 값에 따라 블러 강도 조절 (0 -> 5)
                    sigmaX: _animation.value * 2.0,
                    sigmaY: _animation.value * 2.0,
                  ),
                  child: GestureDetector(
                    onTap: widget.onToggle,
                    child: Container(
                      // 애니메이션 값에 따라 배경 투명도 조절 (0.0 -> 0.5)
                      color: Colors.white.withOpacity(_animation.value * 0.6),
                    ),
                  ),
                ),
                
                // 버튼 목록
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 53.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: actions.reversed.map((action) {
                      return Opacity(
                        // 애니메이션 값에 따라 버튼 투명도 조절
                        opacity: _animation.value,
                        child: Transform.translate(
                          // 애니메이션 값에 따라 버튼 위치 조절
                          offset: Offset(0.0, 100 * (1.0 - _animation.value)),
                          child: _buildActionButton(action: action),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActionButton({required FabAction action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onButtonPressed(action.type),
        child: Material(
          type: MaterialType.transparency, // 배경을 투명하게 하여 기존 UI에 영향을 주지 않음
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(width: 12),
              Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                elevation: 2.0,
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: Icon(action.icon, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}