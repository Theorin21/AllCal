// [1] 이 줄 추가
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome을 사용하기 위해 import
import 'package:provider/provider.dart';
import 'package:allcal/providers/calendar_provider.dart';
import 'package:allcal/providers/data_provider.dart';
import 'package:allcal/screens/main_screen.dart';
import 'package:allcal/providers/category_provider.dart';
import 'package:allcal/providers/ui_provider.dart';
import 'package:allcal/providers/resource_provider.dart';
import 'package:allcal/providers/status_provider.dart';

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
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',

        // =============================================
        // ✨ AppBar 테마 및 시스템 UI 색상 설정 ✨
        // =============================================
        appBarTheme: const AppBarTheme(
          // 모든 AppBar의 배경색을 흰색으로 지정
          backgroundColor: Colors.white,
          // 모든 AppBar의 아이콘과 글자색을 검은색으로 지정
          foregroundColor: Colors.black,
          // 그림자 효과 제거하여 깔끔하게
          elevation: 0,
          
          // AppBar가 보일 때 적용될 시스템 UI 스타일
          systemOverlayStyle: SystemUiOverlayStyle(
            // 안드로이드 네비게이션 바 색상 설정
            systemNavigationBarColor: Colors.white, // 바 배경을 흰색으로
            systemNavigationBarIconBrightness: Brightness.dark, // 바 아이콘을 어두운 색으로
            
            // 상단 상태 바 아이콘 색상 설정
            statusBarIconBrightness: Brightness.dark, 
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}