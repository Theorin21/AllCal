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
  print('[DEBUG] main 함수 시작'); // 디버그 프린트 1
  // [3] 이 줄 추가: 플러터 엔진과 위젯을 연결하는 역할
  WidgetsFlutterBinding.ensureInitialized();
  print('[DEBUG] 위젯 바인딩 초기화 완료'); // 디버그 프린트 2
  
  // [4] 이 줄 추가: 한국어 날짜/시간 데이터를 미리 준비시킴
  await initializeDateFormatting();
  print('[DEBUG] 날짜 포맷 초기화 완료'); // 디버그 프린트 3

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
          create: (context) {
            print('[DEBUG] DataProvider 생성 시도'); // 디버그 프린트 4
            final dataProvider = DataProvider(context.read<CategoryProvider>());
            print('[DEBUG] DataProvider 생성 완료'); // 디버그 프린트 5
            return dataProvider;
          },
          update: (context, categoryProvider, previousDataProvider) {
            print('[DEBUG] DataProvider 업데이트 시도');
            final dataProvider = DataProvider(categoryProvider);
            print('[DEBUG] DataProvider 업데이트 완료');
            return dataProvider;
          },
        ),
      ],
      child: const AllCalApp(),
    ),
  );
  print('[DEBUG] runApp 함수 호출 완료'); // 디버그 프린트 6
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