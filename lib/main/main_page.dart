import 'package:flutter/material.dart';
import 'package:gym_schedule/member/log_in.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime today = DateTime.now(); // 오늘 날짜
  DateTime selectedDate = DateTime.now(); // 선택된 날짜
  late DateTime weekStartDate; // 이번 주 시작 날짜

  @override
  void initState() {
    super.initState();
    weekStartDate = _getWeekStartDate(today); // 주 시작 날짜 설정
  }

  // 주 시작 날짜 계산
  DateTime _getWeekStartDate(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  // 이번 주 날짜 리스트 생성
  List<DateTime> _generateWeekDays(DateTime startOfWeek) {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // 로그아웃 처리
  void _logout() {
    FirebaseAuth.instance.signOut(); // Firebase 로그아웃 처리
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LogInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _generateWeekDays(weekStartDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '수업 예약',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // User 아이콘과 메뉴
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.blueAccent),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'course_period') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('수강기간: 2024년 12월 ~ 2025년 3월')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'course_period',
                child: Text('수강기간'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('로그아웃'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 월과 주간 이동 버튼
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {
                    setState(() {
                      weekStartDate =
                          weekStartDate.subtract(const Duration(days: 7));
                    });
                  },
                ),
                Text(
                  DateFormat('yyyy년 MM월').format(weekStartDate),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    setState(() {
                      weekStartDate =
                          weekStartDate.add(const Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ),
          // 요일 고정 및 날짜 UI
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('일', style: TextStyle(color: Colors.red)),
                  Text('월'),
                  Text('화'),
                  Text('수'),
                  Text('목'),
                  Text('금'),
                  Text('토', style: TextStyle(color: Colors.blue)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((date) {
                  final isToday = date.day == today.day &&
                      date.month == today.month &&
                      date.year == today.year;

                  final isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected
                          ? Colors.blue
                          : isToday
                          ? Colors.grey.shade300
                          : Colors.transparent,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? Colors.blue
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 수업 리스트
          Expanded(
            child: ListView(
              children: const [
                _ClassCard(time: "18:10 ~ 19:20", reserved: 4),
                _ClassCard(time: "19:30 ~ 20:40", reserved: 6),
                _ClassCard(time: "20:50 ~ 22:00", reserved: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String time;
  final int reserved;

  const _ClassCard({super.key, required this.time, required this.reserved});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('예약 $reserved / 8명'),
            ],
          ),
          trailing: TextButton(
            onPressed: () {},
            child: const Text('예약', style: TextStyle(color: Colors.blue)),
          ),
        ),
      ),
    );
  }
}