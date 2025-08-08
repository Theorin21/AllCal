import 'package:allcal/models/category.dart';
import 'package:allcal/models/daily_data.dart';
import 'package:allcal/providers/category_provider.dart';
import 'package:allcal/providers/data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:allcal/screens/notification_setting_screen.dart';

class ItemEditScreen extends StatefulWidget {
  final ItemType itemType;
  final DailyData? data;

  const ItemEditScreen({super.key, required this.itemType, this.data});

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  late Category? _selectedCategory;
  late DateTime _startDate;
  late DateTime _endDate;
  late ItemType _currentItemType; // [추가] 변경 가능한 itemType 상태 변수

  @override
  void initState() {
    super.initState();
    _currentItemType = widget.itemType; // [추가] 상태 변수 초기화

    final categoryProvider = context.read<CategoryProvider>();

    _titleController = TextEditingController(text: widget.data?.title ?? '');
    _memoController = TextEditingController(text: widget.data?.memo ?? '');
    _startDate = widget.data?.startTime ?? DateTime.now();
    _endDate = widget.data?.endTime ?? _startDate.add(const Duration(hours: 1));

    if (widget.data != null) {
      try {
        _selectedCategory = categoryProvider.categories.firstWhere((c) => c.id == widget.data!.categoryId);
      } catch (e) {
        _selectedCategory = null;
      }
    } else {
      _selectedCategory = categoryProvider.categories.isNotEmpty ? categoryProvider.categories.first : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (_currentItemType) { // [수정]
      case ItemType.schedule: return '일정';
      case ItemType.deadline: return '기한';
      case ItemType.task: return '할일';
    }
  }

  void _saveItem() {
    if (_titleController.text.isEmpty || _selectedCategory == null) {
      return;
    }
    
    final dataProvider = context.read<DataProvider>();
    final newItem = DailyData(
      id: widget.data?.id ?? const Uuid().v4(), // [핵심] 수정 모드일 경우 기존 id를 그대로 사용
      type: _currentItemType, // [수정]
      title: _titleController.text,
      categoryId: _selectedCategory!.id,
      isAllDay: widget.data?.isAllDay ?? false, // isAllDay는 수정 화면에서 바꿀 수 없음 (임시)
      startTime: _startDate,
      endTime: (widget.itemType == ItemType.schedule || widget.itemType == ItemType.deadline) ? _endDate : null,
      memo: (widget.itemType == ItemType.task) ? _memoController.text : null,
      completionState: widget.data?.completionState ?? CompletionState.notCompleted, // 기존 상태 유지
      resourceChanges: widget.data?.resourceChanges ?? [], // 기존 자원 기록 유지
    );
    
    // [수정] '수정 모드'인지 '만들기 모드'인지 확인하여 다른 함수를 호출합니다.
    if (widget.data != null) { // data가 있으면 수정 모드
      dataProvider.updateData(newItem);
    } else { // data가 없으면 만들기 모드
      dataProvider.addData(newItem);
    }
    
    Navigator.of(context).pop();
  }

  void _selectCategory() {
    final categoryProvider = context.read<CategoryProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: categoryProvider.categories.length,
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];
          return ListTile(
            leading: Icon(Icons.circle, color: category.color),
            title: Text(category.name),
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  // [추가] 타입 변경 시 데이터 변환 로직을 처리하는 함수
  void _onTypeChanged(ItemType newType) {
    setState(() {
      // 예시: 일정 -> 기한으로 변경 시, 시작 시간을 기한 시간으로 복사
      if (widget.itemType == ItemType.schedule && newType == ItemType.deadline) {
        _endDate = _startDate;
      }
      // TODO: 다른 모든 타입 변경 경우에 대한 데이터 변환 규칙 추가
      
      // [수정] widget.itemType = newType; -> _currentItemType = newType;
      _currentItemType = newType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // 이제 이 속성이 정상적으로 작동합니다.
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        // [수정] ExpansionTile -> 직접 만든 커스텀 위젯으로 교체
        // [수정] title을 PopupMenuButton으로 교체
        title: PopupMenuButton<ItemType>(
          // [2. 위치 수정] offset 속성을 추가하여 메뉴가 아래로 나타나도록 합니다.
          offset: const Offset(-39, 40), // y축(세로)으로 40만큼 아래에 표시
          onSelected: (ItemType newType) {
            _onTypeChanged(newType);
          },
          itemBuilder: (BuildContext context) {
            return ItemType.values
                .where((type) => type != _currentItemType)
                .map((ItemType type) {
              return PopupMenuItem<ItemType>(
                value: type,
                // [1. 한국어 수정] _translateItemType 함수를 사용하여 한글로 표시
                child: Center(child: Text(_translateItemType(type))),
              );
            }).toList();
          },
          child: Text(
            _getTitle(),
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveItem,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 카테고리/제목 UI
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _selectCategory,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedCategory?.name ?? '카테고리 선택', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedCategory?.color ?? Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '이름 입력',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          
          if (_currentItemType == ItemType.schedule) _buildScheduleFields(), // [수정]
          if (_currentItemType == ItemType.deadline) _buildDeadlineFields(), // [수정]
          if (_currentItemType == ItemType.task) _buildTaskFields(),       // [수정]
        ],
      ),
    );
  }

  // [1. 한국어 수정] ItemType을 한국어로 변환하는 헬퍼 함수 추가
  String _translateItemType(ItemType type) {
    switch (type) {
      case ItemType.schedule:
        return '일정';
      case ItemType.deadline:
        return '기한';
      case ItemType.task:
        return '할일';
    }
  }

  Widget _buildScheduleFields() {
    return Column(
      children: [
        _DateTimePickerRow(
          label: '시작',
          date: _startDate,
          mode: CupertinoDatePickerMode.dateAndTime,
          onChanged: (newDate) => setState(() => _startDate = newDate),
        ),
        _DateTimePickerRow(
          label: '종료',
          date: _endDate,
          mode: CupertinoDatePickerMode.dateAndTime,
          onChanged: (newDate) => setState(() => _endDate = newDate),
        ),
      ],
    );
  }

  Widget _buildDeadlineFields() {
    return _DateTimePickerRow(
      label: '기한',
      date: _startDate, // 기한은 startTime에 저장
      mode: CupertinoDatePickerMode.dateAndTime,
      onChanged: (newDate) => setState(() => _startDate = newDate),
    );
  }

  Widget _buildTaskFields() {
    return Column(
      children: [
        _DateTimePickerRow(
          label: '시작 날짜',
          date: _startDate,
          mode: CupertinoDatePickerMode.date,
          onChanged: (newDate) => setState(() => _startDate = newDate),
        ),
        _DateTimePickerRow(
          label: '종료 날짜',
          date: _endDate,
          mode: CupertinoDatePickerMode.date,
          onChanged: (newDate) => setState(() => _endDate = newDate),
        ),
        const Divider(),
        _buildMemoField(),
      ],
    );
  }
  
  Widget _buildMemoField() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.edit_note_outlined),
      title: TextField(
        controller: _memoController,
        decoration: const InputDecoration(
          hintText: '메모',
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }
}

class _DateTimePickerRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final CupertinoDatePickerMode mode;
  final ValueChanged<DateTime> onChanged;

  const _DateTimePickerRow({
    required this.label,
    required this.date,
    required this.mode,
    required this.onChanged,
  });

  DateTime _getInitialDateTime() {
    final now = date;
    // dateAndTime 모드일 때만 분을 5의 배수로 맞춤
    if (mode == CupertinoDatePickerMode.dateAndTime) {
      return DateTime(
        now.year, now.month, now.day, now.hour, (now.minute / 5).floor() * 5,
      );
    }
    return now;
  }

  @override
  Widget build(BuildContext context) {
    final format = (mode == CupertinoDatePickerMode.date) 
      ? DateFormat('yyyy. MM. dd. (E)', 'ko_KR') 
      : DateFormat('yyyy. MM. dd. (E)  a h:mm', 'ko_KR');
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SizedBox(width: 40),
      title: Text(label),
      trailing: Text(format.format(date)),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    initialDateTime: _getInitialDateTime(),
                    minuteInterval: 5,
                    use24hFormat: false,
                    mode: mode,
                    onDateTimeChanged: onChanged,
                  ),
                ),
                CupertinoButton(
                  child: const Text('확인'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}