import 'package:flutter/material.dart';
import 'package:gym_schedule/member/log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reservation_page.dart';
import 'my_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 하단 네비게이션 바 현재 선택 인덱스

  // AppBar 타이틀 변경을 위한 리스트
  // final List<String> _appBarTitles = ['수업 예약', '이용 내역', '마이 페이지'];
  final List<String> _appBarTitles = ['수업 예약', '마이 페이지'];

  // 로그아웃 처리
  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LogInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ReservationPage(), // 수업 예약
      // const Center(child: Text('이용 내역')), // 이용 내역
      MyPage(logoutCallback: _logout, isAdmin: true), // 마이 페이지
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_currentIndex],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: pages[_currentIndex], // 현재 선택된 페이지
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 탭 변경
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '수업 예약',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.history),
          //   label: '이용 내역',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '마이 페이지',
          ),
        ],
      ),
    );
  }
}





