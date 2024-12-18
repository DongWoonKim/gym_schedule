
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_page.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime today = DateTime.now(); // 오늘 날짜
  DateTime selectedDate = DateTime.now(); // 선택된 날짜
  late DateTime weekStartDate; // 이번 주 시작 날짜
  List<Map<String, dynamic>> classTimes = []; // Firestore에서 가져올 시간 데이터

  @override
  void initState() {
    super.initState();
    weekStartDate = _getWeekStartDate(today); // 주 시작 날짜 설정
  }

  Future<void> _fetchClassTimes() async {
    String day = DateFormat('EEEE').format(selectedDate).toLowerCase(); // 요일
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('OpenTimes')
          .doc(day)
          .get();

      if (snapshot.exists) {
        List<dynamic> times = snapshot['times'];
        setState(() {
          // times 리스트를 Map<String, String> 형태로 변환
          classTimes = times.map((e) => {
            'start': e['start'] as String,
            'end': e['end'] as String,
            'max': e['max'] as int,
          }).toList();
        });
      } else {
        setState(() {
          classTimes = []; // 해당 요일에 데이터가 없을 경우
        });
      }
    } catch (e) {
      print('Error fetching class times: $e');
    }
  }

  // 주 시작 날짜 계산
  DateTime _getWeekStartDate(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  // 이번 주 날짜 리스트 생성
  List<DateTime> _generateWeekDays(DateTime startOfWeek) {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _generateWeekDays(weekStartDate);

    return Column(
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
                      _fetchClassTimes(); // 선택된 날짜에 맞게 데이터를 가져옵니다.
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
            shrinkWrap: true,
            children: classTimes.isEmpty
                ? [const Center(child: Text("수업 시간이 없습니다."))]
                : classTimes.map((time) {
              String displayTime =
                  '${time['start']!.substring(0, 2)}:${time['start']!.substring(2)} ~ ${time['end']!.substring(0, 2)}:${time['end']!.substring(2)}';
              return ClassCard(time: displayTime, reserved: 0, max: time['max']);
            }).toList(),
          ),
        ),
      ],
    );
  }
}