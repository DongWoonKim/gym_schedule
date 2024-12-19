import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _database = FirebaseDatabase.instance.ref();
  // 입력 필드 컨트롤러
  final _emailLocalPartController = TextEditingController();
  final _emailDomainController    = TextEditingController();
  final _pwController             = TextEditingController();
  final _nameController           = TextEditingController();
  final _phoneController          = TextEditingController();
  final _birthController          = TextEditingController();

  bool _isCheckingId = false;

  // 이메일 도메인 선택 관련
  final List<String> _emailDomains = ["@gmail.com", "@naver.com", "@daum.net", "직접입력"];
  String _selectedDomain = "@gmail.com";
  bool get _isCustomDomain => _selectedDomain == "직접입력";

  // 회원권 관련
  final List<String> _membershipTypes = ["주말", "평일"];
  String _selectedMembership = "주말";

  // 주말과 평일에 따른 요일 목록
  final List<String> _weekendDays = ["수", "토", "일"];
  final List<String> _weekdayDays = ["월", "화", "목", "금"];
  String? _selectedWeekendDay; // 주말일 때 단일 선택용
  // 평일일 때 다중 선택용
  final Set<String> _selectedWeekdayDays = {};

  // 시간대 목록 정의
  // 주말
  // 토, 일
  final List<String> _weekendWeekendTimes = ["8:00 ~ 10:00", "10:00 ~ 12:00", "12:00 ~ 14:00", "14:00 ~ 16:00", "18:00 ~ 20:00"];
  // 수
  final List<String> _weekendWednesdayTimes = ["10:00 ~ 12:00", "18:30 ~ 20:30", "20:00 ~ 22:00"];
  // 평일
  final List<String> _weekdayTimes = ["06:30 ~ 08:00", "08:15 ~ 09:45", "10:00 ~ 11:30", "14:00 ~ 15:30", "16:00 ~ 17:30", "18:30 ~ 20:00", "19:20 ~ 20:50", "21:00 ~ 22:30"];
  String? _selectedTimeSlot; // 시간대 선택값

  Future<void> _checkIdExists() async {
    final localPart = _emailLocalPartController.text.trim();
    final domain = _isCustomDomain ? _emailDomainController.text.trim() : _selectedDomain;
    final email = localPart + domain;

    // ID 중복 체크
    final snapshot = await _database.child('users').child(email).get();
    if (snapshot.exists) {
      _isCheckingId = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('이미 등록된 Email입니다.'),
        backgroundColor: Colors.red,
      ));
    } else {
      _isCheckingId = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('사용가능한 Email입니다.'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _signUp() async {
    if (!_validateForm()) return;

    final localPart = _emailLocalPartController.text.trim();
    final domain = _isCustomDomain ? _emailDomainController.text.trim() : _selectedDomain;
    final email = localPart + domain;
    final password = _pwController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final birth = _birthController.text.trim();
    final membership = _selectedMembership;
    List<String> selectedDays = [];
    if (membership == "주말") {
      selectedDays = [if (_selectedWeekendDay != null) _selectedWeekendDay!];
    } else {
      selectedDays = _selectedWeekdayDays.toList();
    }
    final timeSlot = _selectedTimeSlot ?? "";

    try {
      // Firebase Authentication - 이메일/비밀번호로 회원가입
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      final uid = cred.user!.uid;

      // Realtime Database 레퍼런스
      final DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

      // 서버 타임스탬프 사용
      final serverTime = ServerValue.timestamp;

      // Firebase Realtime Database - 사용자 정보 저장
      await ref.set(
        {
          'email': email,
          'name': name,
          'phone': phone,
          'birth': birth,
          'role': 'ROLE_USER',
          'membership': membership,
          'days': selectedDays,
          'timeSlot': timeSlot,
          'created_at': serverTime,
          'approved' : false, // 승인 대기
        }
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('회원가입 성공!'),
        backgroundColor: Colors.green,
      ));

      // 회원가입 성공 후 로그인 페이지로 이동
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('회원가입 실패: ${e.message}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  List<String> get dayOptions {
    if (_selectedMembership == "주말") {
      return _weekendDays;
    } else {
      return _weekdayDays;
    }
  }

  bool _validateForm() {
    // 추가 유효성 검사: 회원권에 따라 요일/시간대 선택 체크
    if (_selectedMembership == "주말") {
      if (_selectedWeekendDay == null || _selectedWeekendDay!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("주말 회원권은 요일을 선택해주세요."))
        );
        return false;
      }
      if (_selectedTimeSlot == null || _selectedTimeSlot!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("시간대를 선택해주세요."))
        );
        return false;
      }
    } else {
      // 평일
      if (_selectedWeekdayDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("평일 회원권은 최소 한 개 이상의 요일을 선택해주세요."))
        );
        return false;
      }
      if (_selectedTimeSlot == null || _selectedTimeSlot!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("시간대를 선택해주세요."))
        );
        return false;
      }
    }

    return true;
  }

  List<String> _getTimeOptions() {
    if (_selectedMembership == "주말") {
      // 주말일 때 _selectedWeekendDay에 따라 시간대 결정
      if (_selectedWeekendDay == "수") {
        return _weekendWednesdayTimes;
      } else if (_selectedWeekendDay == "토" || _selectedWeekendDay == "일") {
        return _weekendWeekendTimes;
      } else {
        return []; // 아직 요일 선택 안됨
      }
    } else {
      // 평일은 요일 여러 개 선택 가능, 시간대 동일
      // 평일은 적어도 하나 이상의 요일이 선택되어야 유효
      if (_selectedWeekdayDays.isNotEmpty) {
        return _weekdayTimes;
      } else {
        return [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeekend = _selectedMembership == "주말";
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child:
                    TextFormField(
                      controller: _emailLocalPartController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: '예: test'
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDomain,
                      items: _emailDomains.map((domain) {
                        return DropdownMenuItem(
                          value: domain,
                          child: Text(domain),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDomain = value!;
                          print(_selectedDomain);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
                if (_isCustomDomain)
                  TextFormField(
                    controller: _emailDomainController,
                    decoration: const InputDecoration(
                      labelText: '직접입력',
                      hintText: '예: @mydomain.com'
                    ),
                    validator: (value) {
                      if (_isCustomDomain) {
                        if (value == null || value.isEmpty || !value.startsWith('@')) {
                          return '@를 포함한 올바른 도메인을 입력해주세요';
                        }
                      }
                      return null;
                    },
                  ),
                if (_isCustomDomain)
                  const SizedBox(height: 16),
              // 비밀번호
              TextFormField(
                controller: _pwController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: '최소 6자리 이상'
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 최소 6자리 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: '예: 01012345678'
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '연락처를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: '예: 911009'
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              // 회원권 선택
              DropdownButtonFormField<String>(
                value: _selectedMembership,
                decoration: const InputDecoration(
                    labelText: '회원권'
                ),
                items: _membershipTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMembership = value!;
                    // 회원권 바뀌면 요일과 시간대 초기화
                    _selectedWeekendDay = null;
                    _selectedWeekdayDays.clear();
                    _selectedTimeSlot = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 요일 선택 (회원권에 따라 다름)
              if (isWeekend)
              // 주말: 단일 요일 선택
                DropdownButtonFormField<String>(
                  value: _selectedWeekendDay,
                  decoration: const InputDecoration(
                      labelText: '요일 선택 (주말)'
                  ),
                  items: _weekendDays.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWeekendDay = value;
                      _selectedTimeSlot = null; // 요일 바뀌면 시간대 초기화
                    });
                  },
                  validator: (value) {
                    if (isWeekend && (value == null || value.isEmpty)) {
                      return '요일을 선택해주세요';
                    }
                    return null;
                  },
                )
              else
              // 평일: 다중 요일 선택 (Checkbox)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('요일 선택 (평일):'),
                    for (var day in _weekdayDays)
                      CheckboxListTile(
                        title: Text(day),
                        value: _selectedWeekdayDays.contains(day),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedWeekdayDays.add(day);
                            } else {
                              _selectedWeekdayDays.remove(day);
                            }
                            _selectedTimeSlot = null; // 요일 변경 시 시간대 초기화
                          });
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              // 시간대 선택 (요일에 따라 다름)
              // 주말일 경우 선택한 요일에 따라 시간대 다름
              // 평일일 경우 요일은 여러 개 선택 가능하나 시간대는 공통으로 하나만 선택
              DropdownButtonFormField<String>(
                value: _selectedTimeSlot,
                decoration: const InputDecoration(
                    labelText: '시간대 선택'
                ),
                items: _getTimeOptions().map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeSlot = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '시간대를 선택해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _emailLocalPartController.clear();
                        _pwController.clear();
                        _nameController.clear();
                        _phoneController.clear();
                        _birthController.clear();
                        _selectedDomain = '@gmail.com';
                        _selectedMembership = '주말';
                        _selectedWeekendDay = null;
                        _selectedWeekdayDays.clear();
                        _selectedTimeSlot = null;
                      });
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