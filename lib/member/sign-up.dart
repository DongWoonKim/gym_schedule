
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  // 입력 필드 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isCheckingId = false;

  Future<void> _checkIdExists() async {
    // ID 중복 체크
    final snapshot = await _database.child('users').child(_idController.text).get();
    if (snapshot.exists) {
      _isCheckingId = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ID already exists!'),
        backgroundColor: Colors.red,
      ));
    } else {
      _isCheckingId = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ID is available!'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _signUp() async {
    try {
      // Firebase Authentication - 이메일/비밀번호로 회원가입
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _pwController.text.trim(),
      );

      // Firebase Realtime Database - 사용자 정보 저장
      final userId = _idController.text.trim();
      final now = DateTime.now().toIso8601String(); // 가입일

      await _database.child('users').child(userId).set({
        'uid': credential.user?.uid,
        'id': userId,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'created_at': now,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sign-up Successful!'),
        backgroundColor: Colors.green,
      ));

      // 회원가입 성공 후 로그인 페이지로 이동
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.message}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
              children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'ID',
                suffixIcon: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _checkIdExists,
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // 그림자 제거
                      backgroundColor: Colors.transparent, // 배경색 투명
                      foregroundColor: Colors.blue, // 글자색
                      padding: EdgeInsets.zero, // 패딩 최소화
                    ),
                    child: const Text(
                      '중복체크',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _idController.clear();
                      _pwController.clear();
                      _nameController.clear();
                      _phoneController.clear();
                      _dobController.clear();
                      _emailController.clear();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
                ],
              )
            ]
          )
        )
      ),
    );

  }
}