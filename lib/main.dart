import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 추가
import 'package:gym_schedule/member/log-in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 준비
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Scheduled',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LogInPage(),
    );
  }
}
