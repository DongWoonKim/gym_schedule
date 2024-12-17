
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign-up.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LogInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 입력 필드 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // 로그인 처리 함수
  Future<void> _signIn() async {
    final email = _idController.text.trim();
    final password = _pwController.text;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('로그인 성공!'),
        backgroundColor: Colors.green,
      ));

      // 로그인 성공 후 홈 페이지 또는 다른 페이지로 이동
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('로그인 실패: ${e.message}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLG GYM'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 패딩 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ID 입력 필드
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'ID',
                hintText: 'ID를 입력하세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16), // 간격

            // PW 입력 필드
            TextField(
              controller: _pwController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '비밀번호를 입력하세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true, // 비밀번호 가리기
            ),
            const SizedBox(height: 24), // 간격

            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                final id = _idController.text;
                final pw = _pwController.text;
                // 로그인 처리 로직 추가
                print('ID: $id, Password: $pw');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12), // 간격

            // 회원가입 버튼
            TextButton(
              onPressed: () {
                // 회원가입 페이지로 이동 로직 추가
                Navigator.of(context).push(
                    MaterialPageRoute( builder: (context) => const SignUpPage() )
                );
              },
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            )
          ],
        )
      )
    );

  }

}