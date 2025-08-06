// lib/screens/resource_input_screen.dart

import 'package:allcal/models/resource.dart';
import 'package:allcal/providers/data_provider.dart';
import 'package:allcal/providers/resource_provider.dart';
import 'package:allcal/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// 입력 줄 하나의 상태를 관리하는 모델
class ResourceInputState {
  String? selectedResourceId;
  bool isPositive = true;
  final TextEditingController amountController = TextEditingController();

  // 완료 버튼 활성화 여부를 위한 getter
  bool get isValid => selectedResourceId != null && amountController.text.isNotEmpty;

  ResourceInputState();
}

class ResourceInputScreen extends StatefulWidget {
  final String dataId;
  const ResourceInputScreen({super.key, required this.dataId});

  @override
  State<ResourceInputScreen> createState() => _ResourceInputScreenState();
}

class _ResourceInputScreenState extends State<ResourceInputScreen> {
  List<ResourceInputState> _inputStates = [];
  bool _canSave = false; // 완료 버튼 활성화 상태

  @override
  void initState() {
    super.initState();
    // 초기 입력 줄 추가 및 리스너 설정
    _addInputRow();
  }

  @override
  void dispose() {
    for (var state in _inputStates) {
      state.amountController.dispose();
    }
    super.dispose();
  }

  // 모든 입력 줄이 유효한지 확인하여 _canSave 상태 업데이트
  void _validateInputs() {
    final allValid = _inputStates.every((state) => state.isValid);
    if (_canSave != allValid) {
      setState(() {
        _canSave = allValid;
      });
    }
  }

  void _addInputRow() {
    setState(() {
      final newState = ResourceInputState();
      // 새로운 입력 줄의 값이 변경될 때마다 유효성 검사 실행
      newState.amountController.addListener(_validateInputs);
      _inputStates.add(newState);
      _validateInputs(); // 추가 후 즉시 유효성 검사
    });
  }
  
  void _removeInputRow(int index) {
     if (_inputStates.length > 1) {
        _inputStates[index].amountController.removeListener(_validateInputs);
        _inputStates.removeAt(index);
        _validateInputs(); // 삭제 후 즉시 유효성 검사
     }
  }

  void _saveChanges() {
    if (!_canSave) return; // 저장할 수 없는 상태면 무시

    final List<ResourceChange> changes = [];
    for (final state in _inputStates) {
      final amount = int.tryParse(state.amountController.text) ?? 0;
      changes.add(ResourceChange(
        resourceId: state.selectedResourceId!,
        amount: state.isPositive ? amount : -amount,
      ));
    }
    
    final dataProvider = context.read<DataProvider>();
    final resourceProvider = context.read<ResourceProvider>();
    final statusProvider = context.read<StatusProvider>();

    dataProvider.addResourceChanges(widget.dataId, changes);
    statusProvider.recalculateStatus(dataProvider.allData, resourceProvider.resources);
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽 상단 '+' 버튼
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _addInputRow,
              ),
              const Text('자원 변화 입력', style: TextStyle(fontWeight: FontWeight.bold)),
              // 오른쪽 상단 '완료(✓)' 버튼
              IconButton(
                icon: Icon(Icons.check, color: _canSave ? Colors.blue : Colors.grey),
                onPressed: _saveChanges,
              )
            ],
          ),
        ),
        const Divider(height: 1),
        // [수정] 스크롤 및 동적 높이를 위해 Flexible + ListView 사용
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            itemCount: _inputStates.length,
            itemBuilder: (context, index) {
              return _ResourceInputRow(
                inputState: _inputStates[index],
                onDelete: () => setState(() => _removeInputRow(index)),
                onChanged: _validateInputs, // 자식 위젯의 변경을 감지
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- 입력 줄 하나를 그리는 별도의 위젯 ---
class _ResourceInputRow extends StatefulWidget {
  final ResourceInputState inputState;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _ResourceInputRow({
    required this.inputState, 
    required this.onDelete,
    required this.onChanged,
  });

  @override
  __ResourceInputRowState createState() => __ResourceInputRowState();
}

class __ResourceInputRowState extends State<_ResourceInputRow> {
  @override
  Widget build(BuildContext context) {
    final resourceProvider = context.watch<ResourceProvider>();
    final availableResources = resourceProvider.resources;
    
    Resource? selectedResource;
    if (widget.inputState.selectedResourceId != null) {
      selectedResource = availableResources.firstWhere((r) => r.id == widget.inputState.selectedResourceId);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 1. 자원 선택
          GestureDetector(
            onTap: () async {
              final selectedId = await _showResourcePicker(context, availableResources);
              if (selectedId != null) {
                setState(() {
                  widget.inputState.selectedResourceId = selectedId;
                  widget.onChanged(); // 변경사항 부모에게 알림
                });
              }
            },
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(selectedResource?.iconData ?? Icons.question_mark, color: selectedResource?.color),
            ),
          ),
          const SizedBox(width: 8),

          // 2. +/- 토글 버튼
          ToggleButtons(
            isSelected: [widget.inputState.isPositive, !widget.inputState.isPositive],
            onPressed: (index) => setState(() => widget.inputState.isPositive = (index == 0)),
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            children: const [Icon(Icons.add), Icon(Icons.remove)],
          ),
          const SizedBox(width: 8),

          // 3. 증감 값 입력
          Expanded(
            child: TextField(
              controller: widget.inputState.amountController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: OutlineInputBorder()),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }

  // '?' 아이콘을 눌렀을 때 자원 목록을 보여주는 함수
  Future<String?> _showResourcePicker(BuildContext context, List<Resource> resources) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return ListTile(
              leading: Icon(resource.iconData, color: resource.color),
              title: Text(resource.name),
              onTap: () => Navigator.of(context).pop(resource.id),
            );
          },
        );
      },
    );
  }
}