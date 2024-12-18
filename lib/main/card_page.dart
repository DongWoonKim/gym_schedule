import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String time;
  final int reserved;
  final int max;

  const ClassCard({super.key, required this.time, required this.reserved, required this.max});

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
              Text('예약 $reserved / $max명'),
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