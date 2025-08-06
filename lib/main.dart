// [1] 이 줄 추가
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allcal/providers/calendar_provider.dart';
import 'package:allcal/providers/data_provider.dart';
import 'package:allcal/screens/main_screen.dart';
import 'package:allcal/providers/category_provider.dart'; // [추가]
import 'package:allcal/providers/ui_provider.dart'; // [추가]
import 'package:allcal/providers/resource_provider.dart'; // [추가]
import 'package:allcal/providers/status_provider.dart';   // [추가]

// [2] async 추가
void main() async {
  // [3] 이 줄 추가: 플러터 엔진과 위젯을 연결하는 역할
  WidgetsFlutterBinding.ensureInitialized();
  
  // [4] 이 줄 추가: 한국어 날짜/시간 데이터를 미리 준비시킴
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // [추가]
        ChangeNotifierProvider(create: (_) => UiProvider()), // [추가]
        ChangeNotifierProvider(create: (_) => ResourceProvider()), // [추가]
        ChangeNotifierProvider(create: (_) => StatusProvider()),   // [추가]
      ],
      child: const AllCalApp(),
    ),
  );
}

class AllCalApp extends StatelessWidget {
  const AllCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllCal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}