// lib/screens/resource_management_screen.dart
import 'package:allcal/providers/resource_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResourceManagementScreen extends StatelessWidget {
  const ResourceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resourceProvider = context.watch<ResourceProvider>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('자원 관리')),
      // TODO: ReorderableListView로 수정
      body: ListView.builder(
        itemCount: resourceProvider.resources.length,
        itemBuilder: (context, index) {
          final resource = resourceProvider.resources[index];
          return ListTile(
            leading: Icon(resource.iconData, color: resource.color),
            title: Text(resource.name, style: TextStyle(color: resource.color)),
            trailing: const Icon(Icons.settings_outlined),
            onTap: () { /* TODO: 자원 세부 설정 화면으로 이동 */ },
          );
        },
      ),
    );
  }
}