import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPage extends StatelessWidget {
  final VoidCallback logoutCallback;
  final bool isAdmin; // 관리자 여부 확인

  const MyPage({super.key, required this.logoutCallback, required this.isAdmin});

  Future<void> updateWeeklyData() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      // 1. Members 컬렉션에서 expired: false인 회원 가져오기
      final membersSnapshot = await db
          .collection('Members')
          .where('expired', isEqualTo: false)
          .get();

      final List<Map<String, dynamic>> membersData = membersSnapshot.docs
          .map((doc) => {
        "email": doc.id,
        "name": doc['name'],
        "classDay": doc['classDay'],
        "classTime": doc['classTime'],
      }).toList();

      final DateTime now = DateTime.now();
      final List<DateTime> next7Days = List.generate(7, (index) => now.add(Duration(days: index)));

      for (DateTime date in next7Days) {
        final String formattedDate =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        final String dayOfWeek =
        date.weekday == 7 ? 'sunday' : _getDayName(date.weekday);

        for (var member in membersData) {
          if (member['classDay'] == dayOfWeek) {
            final reservationRef = db
                .collection('Reserved')
                .doc(formattedDate) // 날짜를 문서 ID로
                .collection(member['classTime']) // 시간대 서브컬렉션
                .doc(member['email']); // 회원 이메일 문서 ID

            final reservationSnapshot = await reservationRef.get();

            if (!reservationSnapshot.exists) {
              // 문서가 존재하지 않을 때만 추가
              await reservationRef.set({
                'name': member['name'],
                'email': member['email'],
                'status': 'reserved',
              });
            }

          }
        }
      }
      print('Weekly reservations updated successfully!');
    } catch (e) {
      print('Error updating weekly reservations: $e');
    }
  }



  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
      default:
        return 'sunday';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center( // 전체 화면에서 중앙 배치
      child: Column(
        mainAxisSize: MainAxisSize.min, // 중앙에 맞게 최소 크기만 사용
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: logoutCallback,
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
          const SizedBox(height: 16), // 버튼 간 간격
          if (isAdmin) // 관리자만 보이도록 설정
            ElevatedButton(
              onPressed: () async {
                await updateWeeklyData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('주간 데이터 갱신 완료')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '갱신',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}