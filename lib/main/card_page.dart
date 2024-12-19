import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassCard extends StatelessWidget {
  final String time;
  final int reserved;
  final int max;
  final bool isReservable;
  final bool isPast;
  final bool isUserReserved;
  final DateTime selectedDate;
  final VoidCallback onReservationSuccess;

  const ClassCard({
    super.key,
    required this.time,
    required this.reserved,
    required this.max,
    required this.isReservable,
    this.isPast = false,
    this.isUserReserved = false,
    required this.selectedDate,
    required this.onReservationSuccess, // 콜백 추가
  });

  Future<void> _handleReservation(BuildContext context) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? "이름없음";
    if (userEmail == null) return;

    final formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    try {
      final firestore = FirebaseFirestore.instance;

      // Step 1: 사용자의 기존 예약 삭제
      final userReservationQuery = await firestore
          .collection('Reserved')
          .get();

      for (var doc in userReservationQuery.docs) {
        final reservationRef = doc.reference.collection('all').doc(userEmail);
        final reservationSnapshot = await reservationRef.get();
        if (reservationSnapshot.exists) {
          await reservationRef.delete();
        }
      }

      // Step 2: 새로운 시간에 예약 등록
      await firestore
          .collection('Reserved')
          .doc(formattedDate)
          .collection('all')
          .doc(userEmail)
          .set({
        'name': userName,
        'classTime': time.replaceAll(":", "").substring(0, 4), // HH:mm -> HHmm
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 예약 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 완료되었습니다!')),
      );

      // 화면 새로고침

    } catch (e) {
      print("Error processing reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isPast ? Colors.grey.shade200 : Colors.white,
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
          leading: CircleAvatar(
            backgroundColor: isPast ? Colors.grey : Colors.blueAccent,
            child: Icon(
              Icons.person,
              color: isPast ? Colors.white70 : Colors.white,
            ),
          ),
          title: Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPast ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Text(
            isPast
                ? '종료'
                : isUserReserved
                ? '예약됨'
                : '예약 $reserved / $max명',
            style: TextStyle(
              color: isPast ? Colors.grey : Colors.black54,
            ),
          ),
          trailing: isPast
              ? null // 과거 시간: 버튼 숨김
              : isUserReserved
              ? const Text(
            '예약됨',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          )
              : isReservable
              ? TextButton(
            onPressed: reserved < max
                ? () async {
                  await _handleReservation(context);
                  onReservationSuccess(); // 예약 성공 후 콜백 호출
                }
                : null, // 최대치 도달 시 비활성화
            style: TextButton.styleFrom(
              foregroundColor:
              reserved < max ? Colors.blue : Colors.grey,
            ),
            child: Text(
              reserved < max ? '예약' : '예약 불가',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
              : null,
        ),
      ),
    );
  }
}