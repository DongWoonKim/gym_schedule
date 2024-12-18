import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gym_schedule/main/main_page.dart';
import 'package:gym_schedule/member/log_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 준비
  await Firebase.initializeApp(); // Firebase 초기화
  await initializeDateFormatting('ko_KR', null); // 'ko_KR' 로케일 데이터 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GL GYM',
      home: const CheckAuthPage(), // 처음 시작 시 인증 상태 확인
    );
  }
}

class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth에서 현재 유저 가져오기
    final user = FirebaseAuth.instance.currentUser;

    // 유저가 로그인되어 있으면 MainPage, 아니면 LogInPage로 이동
    if (user != null) {
      return const MainPage();
    } else {
      return const LogInPage();
    }
  }
}
