// lib/widgets/settings_drawer.dart

import 'package:flutter/material.dart';
import 'package:allcal/screens/category_management_screen.dart';
import 'package:allcal/screens/resource_management_screen.dart'; // [추가]

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer 상단 꾸미기 (프로필 영역)
          const UserAccountsDrawerHeader(
            accountName: Text('닉네임'),
            accountEmail: null,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          // '카테고리 관리' 버튼
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('카테고리 관리'),
            onTap: () {
              // 현재 Drawer를 닫고
              Navigator.of(context).pop(); 
              // CategoryManagementScreen을 전체 화면 다이얼로그로 엽니다.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          // [추가] 자원 관리 버튼
          ListTile(
            leading: const Icon(Icons.spa),
            title: const Text('자원 관리'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ResourceManagementScreen(),
                fullscreenDialog: true,
              ));
            }
          )
          // TODO: 다른 설정 메뉴들 추가
        ],
      ),
    );
  }
}