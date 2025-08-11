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
        // CategoryProvider를 먼저 생성
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        
        // =============================================
        // ✨ DataProvider 생성 방식 변경 ✨
        // =============================================
        // 생성된 CategoryProvider를 읽어서 DataProvider에 전달
        ChangeNotifierProxyProvider<CategoryProvider, DataProvider>(
          create: (context) => DataProvider(context.read<CategoryProvider>()),
          update: (context, categoryProvider, previousDataProvider) =>
              DataProvider(categoryProvider),
        ),
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