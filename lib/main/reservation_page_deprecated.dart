import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_page.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();
  late DateTime weekStartDate;
  List<Map<String, dynamic>> classTimes = [];
  String? userClassTime = ""; // 사용자의 예약된 시간
  String? userClassName = ""; // 사용자 이름

  @override
  void initState() {
    super.initState();
    weekStartDate = _getWeekStartDate(today);
    selectedDate = today; // 오늘 날짜를 기본 선택
    _fetchClassTimes();
    _fetchUserReservation();
  }

  Future<void> _fetchUserReservation() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return;

    final formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";


  }

  Future<void> _fetchClassTimes() async {

  }

  DateTime _getWeekStartDate(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  List<DateTime> _generateWeekDays(DateTime startOfWeek) {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isPastTime(String startTime) {
    final now = DateTime.now();
    final classDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(startTime.substring(0, 2)),
      int.parse(startTime.substring(2)),
    );
    return classDateTime.isBefore(now);
  }

  Future<int> _countReservations(String date, String classTime) async {
     return -1;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _generateWeekDays(weekStartDate);
    final dayLabels = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      children: [
        // 날짜 이동 UI
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    weekStartDate = weekStartDate.subtract(const Duration(days: 7));
                    _fetchClassTimes();
                    _fetchUserReservation();
                  });
                },
              ),
              Text(
                DateFormat('yyyy년 MM월').format(weekStartDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    weekStartDate = weekStartDate.add(const Duration(days: 7));
                    _fetchClassTimes();
                    _fetchUserReservation();
                  });
                },
              ),
            ],
          ),
        ),
        // 요일 UI
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                    (index) => Text(
                  dayLabels[index],
                  style: TextStyle(
                    color: index == 0
                        ? Colors.red
                        : index == 6
                        ? Colors.blue
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((date) {
                final isSelected = date == selectedDate;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      _fetchClassTimes();
                      _fetchUserReservation();
                    });
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: isSelected ? Colors.blue : Colors.transparent,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
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
            children: classTimes.isEmpty
                ? [const Center(child: Text("수업 시간이 없습니다."))]
                : classTimes.map((time) {
              String displayTime =
                  '${time['start']!.substring(0, 2)}:${time['start']!.substring(2)} ~ ${time['end']!.substring(0, 2)}:${time['end']!.substring(2)}';

              bool isPast = _isPastTime(time['start']);
              bool isReservedByUser = time['start'] == userClassTime;

              return FutureBuilder<int>(
                future: _countReservations(
                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                    time['start']),
                builder: (context, snapshot) {
                  int reservedCount = snapshot.data ?? 0;

                  return ClassCard(
                    time: displayTime,
                    reserved: reservedCount,
                    max: time['max'],
                    isReservable: !isPast && !isReservedByUser,
                    isPast: isPast,
                    isUserReserved: isReservedByUser,
                    selectedDate: selectedDate,
                    onReservationSuccess: () {
                      setState(() {
                        _fetchClassTimes(); // 화면 새로고침을 위해 수업 시간 재로드
                        _fetchUserReservation(); // 사용자 예약 정보 재로드
                      });
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
        const Divider(),
        if (userClassName != null && userClassTime != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "$userClassName ${_formatTime(userClassTime!)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(String classTime) {
    // 길이 검사: classTime이 4자리 미만이면 기본값 반환
    if (classTime.length < 4) {
      print("Invalid classTime: $classTime");
      return "시간 오류"; // 기본값 반환
    }

    int startHour = int.parse(classTime.substring(0, 2)); // 앞의 두 자리를 시간으로 추출
    String startTime = "${startHour.toString().padLeft(2, '0')}:${classTime.substring(2)}";
    String endTime = "${(startHour + 2).toString().padLeft(2, '0')}:00";
    return "$startTime ~ $endTime";
  }
}