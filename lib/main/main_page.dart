
import 'package:flutter/material.dart';
import 'package:gym_schedule/main/reservation_page.dart';

import 'my_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 하단 네비게이션 바 현재 선택 인덱스
  // AppBar 타이틀 변경을 위한 리스트
  final List<String> _appBarTitles = ['수업 예약', '마이 페이지'];
  final List<Widget> pages = [
    ReservationPage(), // 수업 예약
    MyPage(), // 마이 페이지
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_currentIndex],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: pages[_currentIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '마이 페이지',
          ),
        ],
      ),

    );
  }

}