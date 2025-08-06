import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:allcal/models/daily_data.dart';
import 'package:allcal/screens/item_edit_screen.dart';

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
    FabAction(label: '일정', icon: Icons.schedule, type: ItemType.schedule),
    FabAction(label: '기한', icon: Icons.flag_outlined, type: ItemType.deadline),
    FabAction(label: '할일', icon: Icons.check_box_outlined, type: ItemType.task),
    FabAction(label: '기록', icon: Icons.edit_note_outlined, type: ItemType.record),
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
    return Visibility(
      visible: widget.isOpen,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: widget.onToggle,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 96.0), // 하단 바 높이만큼 올림
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: actions.reversed.map((action) {
                      return Opacity(
                        opacity: _animation.value,
                        child: Transform.translate(
                          offset: Offset(0.0, 100 * (1.0 - _animation.value)),
                          child: _buildActionButton(action: action),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({required FabAction action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onButtonPressed(action.type),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action.label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 4)]),
            ),
            const SizedBox(width: 12),
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              elevation: 4.0,
              child: SizedBox(
                width: 56.0,
                height: 56.0,
                child: Icon(action.icon, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}