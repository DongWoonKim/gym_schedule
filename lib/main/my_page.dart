
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../member/log_in.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyPageState();
  }

}

class _MyPageState extends State<MyPage> {

  // 로그아웃 처리
  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LogInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
      return Center( // 전체 화면에서 중앙 배치
        child: Column(
          mainAxisSize: MainAxisSize.min, // 중앙에 맞게 최소 크기만 사용
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '로그아웃',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ]
      )
    );
  }

}