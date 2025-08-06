// lib/screens/notification_setting_screen.dart
import 'package:flutter/material.dart';

class NotificationSettingScreen extends StatelessWidget {
  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 알림 데이터와 연동 필요
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: ListView(
        children: [
          ListTile(title: const Text('당일 오전 9시'), trailing: Checkbox(value: true, onChanged: (v){})),
          ListTile(title: const Text('1일 전 오전 9시'), trailing: Checkbox(value: false, onChanged: (v){})),
          ListTile(
            title: const Text('직접 설정'),
            trailing: const Icon(Icons.add),
            onTap: () {
              // TODO: 동영상과 같은 날짜/시간 선택 UI 띄우기
            },
          )
        ],
      ),
    );
  }
}