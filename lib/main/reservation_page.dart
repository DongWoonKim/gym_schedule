import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReservationPageState();
  }
}

class _ReservationPageState extends State<ReservationPage> {
  String? membership; // "주말" 또는 "평일" 또는 null(데이터 로딩 전)
  Map<String, dynamic>? selectedTimes; // membership에 맞는 요일들의 오픈 타임 정보
  String? selectedDay;
  String? selectedTimeSlotKey;
  Map<dynamic, dynamic>? userData;
  String? beforeSelectedTimeSlotKey;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    if (email.isNotEmpty) {
      _fetchUserInfoByEmail(email);
    }
  }

  void _fetchUserInfoByEmail(String email) async {
    final ref = FirebaseDatabase.instance.ref("users");
    final query = ref.orderByChild("email").equalTo(email);
    final snapshot = await query.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final uid = data.keys.first;
      userData = data[uid] as Map<dynamic, dynamic>;
      membership = userData!['membership'];
      _fetchOpenTimes();
    }
  }

  void _fetchOpenTimes() async {
    if (membership == null) return;

    List<String> targetDays;
    if (membership == '주말') {
      targetDays = ['wed', 'sat', 'sun'];
    } else {
      targetDays = ['mon', 'tue', 'thur', 'fri'];
    }

    final openTimesRef = FirebaseDatabase.instance.ref("open_times");
    final openTimesSnap = await openTimesRef.get();

    if (openTimesSnap.exists) {
      final openTimesData = openTimesSnap.value as Map<dynamic, dynamic>;

      final result = <String, dynamic>{};
      for (var day in targetDays) {
        if (openTimesData.containsKey(day)) {
          result[day] = openTimesData[day];
        }
      }

      print('user user user :: $userData');
      setState(() {
        selectedTimes = result;
        if (selectedTimes!.isNotEmpty) {
          selectedDay = koreanDayToEnglish(userData!['days'][0]);
          final userTimeSlot = userData!['timeSlot'] as String;
          final dayTimeSlots = selectedTimes![selectedDay] as List;
          print('user user user :: $dayTimeSlots');
          if (userTimeSlot.isNotEmpty && dayTimeSlots.isNotEmpty) {
            // userTimeSlot 파싱
            final parts = userTimeSlot.split("~");
            if (parts.length == 2) {
              final startStr = parts[0].trim(); // "10:00"
              final endStr = parts[1].trim();   // "12:00"

              // "10:00" -> "1000" 변환
              String formatToHHMM(String time) {
                return time.replaceAll(":", "");
              }

              final startKey = formatToHHMM(startStr); // "1000"
              final endKey = formatToHHMM(endStr);     // "1200"

              // dayTimeSlots 순회하여 matching
              for (var slot in dayTimeSlots) {
                final slotMap = slot as Map<dynamic, dynamic>;
                final slotStart = slotMap['start'];
                final slotEnd = slotMap['end'];
                if (slotStart == startKey && slotEnd == endKey) {
                  // 매칭 slot 발견
                  setState(() {
                    selectedTimeSlotKey = "$slotStart~$slotEnd";
                    beforeSelectedTimeSlotKey = userTimeSlot;
                  });
                  break;
                }
              }
            }
          }
        }
      });
    } else {
      print("No open_times data found");
    }
  }

  String koreanDayToEnglish(String koreanDay) {
    switch (koreanDay) {
      case "일":
        return "sun";
      case "월":
        return "mon";
      case "화":
        return "tue";
      case "수":
        return "wed";
      case "목":
        return "thur";
      case "금":
        return "fri";
      case "토":
        return "sat";
      default:
        throw ArgumentError("Invalid Korean day: $koreanDay");
    }
  }

  String englishDayToKoreanFull(String englishDay) {
    switch (englishDay) {
      case "sun":
        return "일요일";
      case "mon":
        return "월요일";
      case "tue":
        return "화요일";
      case "wed":
        return "수요일";
      case "thur":
        return "목요일";
      case "fri":
        return "금요일";
      case "sat":
        return "토요일";
      default:
        throw ArgumentError("Invalid English day: $englishDay");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (membership == null || selectedTimes == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("예약")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dayList = selectedTimes!.keys.toList();
    final currentDayTimes = selectedDay != null && selectedTimes![selectedDay] != null
        ? List<Map<dynamic, dynamic>>.from(selectedTimes![selectedDay])
        : [];

    return Scaffold(
      appBar: AppBar(title: Text("$membership반 $beforeSelectedTimeSlotKey")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 요일 선택 Dropdown
            SizedBox(
              width: double.infinity,
              child: DropdownButton<String>(
                value: selectedDay,
                items: dayList.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(
                      englishDayToKoreanFull(day),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                    selectedTimeSlotKey = null; // 요일 변경 시 기존 선택 해제
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // 시간대 리스트 표시 (카드 형태)
            Expanded(
              child: ListView.builder(
                itemCount: currentDayTimes.length,
                itemBuilder: (context, index) {
                  final slot = currentDayTimes[index];
                  final start = slot['start'];
                  final end = slot['end'];
                  final key = "$start~$end";
                  final displayTextStart = "${start.toString().substring(0,2)}:${start.toString().substring(2)}";
                  final displayTextEnd = "${end.toString().substring(0,2)}:${end.toString().substring(2)}";

                  final isSelected = (selectedTimeSlotKey == key);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (isSelected) {
                              // 이미 선택된 것을 체크해제
                              selectedTimeSlotKey = null;
                            } else {
                              // 다른 시간이 선택되어 있어도 현재 선택으로 변경
                              selectedTimeSlotKey = key;
                            }
                          });
                        },
                      ),
                      title: Text(
                        "$displayTextStart ~ $displayTextEnd",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "예약 0 / 20명",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (selectedDay != null && selectedTimeSlotKey != null) {
                  print("선택한 요일: $selectedDay");
                  print("선택한 시간대: $selectedTimeSlotKey");
                } else {
                  print("요일 또는 시간대를 선택해주세요.");
                }
              },
              child: const Text("변경"),
            )
          ],
        ),
      ),
    );
  }
}