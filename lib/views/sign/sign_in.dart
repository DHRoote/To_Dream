import 'package:flutter/material.dart';
import 'package:eh/views/mainapp/main_app.dart';
import 'package:eh/views/sign/sign_up.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // UI상 '아이디' 입력란이지만 기존 컨트롤러 변수명을 유지합니다.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBlankWarning = false;
  bool _isAuthFailed = false;
  bool _isObscured = true;
  bool _isLoading = false; // 로딩 상태 추가

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 로그인 인증 로직 (Firestore 연동)
  void _handleLogin() async {
    final String usernameInput = _emailController.text.trim();
    final String passwordInput = _passwordController.text.trim();

    // 1. 입력 공백 확인
    if (usernameInput.isEmpty || passwordInput.isEmpty) {
      setState(() {
        _isBlankWarning = true;
        _isAuthFailed = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isBlankWarning = false;
      _isAuthFailed = false;
    });

    try {
      // 2. Firestore의 'users' 컬렉션에서 아이디와 비밀번호가 일치하는 문서 조회
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameInput)
          .where('password', isEqualTo: passwordInput) // 스키마 기준 평문 저장 가정
          .get();

      // 3. 일치하는 유저 정보가 존재하는 경우
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();

        // PK 역할의 문서 고유 ID와 닉네임 추출
        final String userId = userDoc.id;
        final String nickname = userData['nickname'] ?? '이름없음';

        if (mounted) {
          // 4. 메인페이지로 이동하면서 ID와 닉네임 파라미터 전달

          context.read<UserProvider>().setUserId(userId);
          context.read<UserProvider>().setNickname(nickname);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainAppPage()),
          );
        }
      } else {
        // 일치하는 유저가 없는 경우 (인증 실패)
        setState(() {
          _isAuthFailed = true;
        });
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF08051A),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.32, 0.00),
              end: Alignment(0.68, 1.00),
              colors: [
                Color(0xFF12083A),
                Color(0xFF0D0A1E),
                Color(0xFF081228),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 헤더 영역
              SizedBox(
                height: 228,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.30,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.00, 0.00),
                              radius: 0.86,
                              colors: [
                                const Color(0xFF7C3AED),
                                Colors.black.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 20),
                        Text(
                          '🌟',
                          style: TextStyle(
                            color: Color(0xFFF0EAFF),
                            fontSize: 60,
                            fontFamily: 'Noto Sans KR',
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '드림퀘스트',
                          style: TextStyle(
                            color: Color(0xFFF0EAFF),
                            fontSize: 24,
                            fontFamily: 'Noto Sans KR',
                            fontWeight: FontWeight.w700,
                            height: 1.33,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '꿈을 향한 나의 성장 여정',
                          style: TextStyle(
                            color: Color(0xFF7C6FA0),
                            fontSize: 14,
                            fontFamily: 'Noto Sans KR',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. 입력 폼 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      // 아이디 입력
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text(
                              '아이디',
                              style: TextStyle(
                                color: Color(0xFF7C6FA0),
                                fontSize: 14,
                                fontFamily: 'Noto Sans KR',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                              ),
                            ),
                          ),
                          TextField(
                            controller: _emailController,
                            onChanged: (value) {
                              setState(() {
                                _isBlankWarning = false;
                                _isAuthFailed = false;
                              });
                            },
                            style: const TextStyle(
                              color: Color(0xFFC4B4FF),
                              fontSize: 14,
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w400,
                            ),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15.5),
                              hintText: '아이디를 입력하세요',
                              hintStyle: const TextStyle(
                                color: Color(0x7F7C6FA0),
                                fontSize: 14,
                                fontFamily: 'Noto Sans KR',
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.07),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 0.67, color: Color(0x338E51FF)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 0.67, color: Color(0x338E51FF)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 1.0, color: Color(0x7F8E51FF)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 비밀번호 입력
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text(
                              '비밀번호',
                              style: TextStyle(
                                color: Color(0xFF7C6FA0),
                                fontSize: 14,
                                fontFamily: 'Noto Sans KR',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                              ),
                            ),
                          ),
                          TextField(
                            controller: _passwordController,
                            onChanged: (value) {
                              setState(() {
                                _isBlankWarning = false;
                                _isAuthFailed = false;
                              });
                            },
                            obscureText: _isObscured,
                            style: const TextStyle(
                              color: Color(0xFFC4B4FF),
                              fontSize: 14,
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w400,
                            ),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(16, 15.5, 12, 15.5),
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: const TextStyle(
                                color: Color(0x7F7C6FA0),
                                fontSize: 14,
                                fontFamily: 'Noto Sans KR',
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.07),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  _isObscured ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xFF7C6FA0),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 0.67, color: Color(0x338E51FF)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 0.67, color: Color(0x338E51FF)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 1.0, color: Color(0x7F8E51FF)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_isBlankWarning) ...[
                        const Text(
                          '아이디와 비밀번호를 입력해주세요.',
                          style: TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'Noto Sans KR'),
                        )
                      ],

                      if (_isAuthFailed) ...[
                        const Text(
                          '아이디와 비밀번호를 다시 확인해주세요.',
                          style: TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'Noto Sans KR'),
                        ),
                      ],

                      // 로그인 버튼 (로딩 상태 적용)
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.00, 0.00),
                            end: Alignment(1.00, 1.00),
                            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            disabledBackgroundColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            '로그인',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Noto Sans KR', fontWeight: FontWeight.w700, height: 1.43),
                          ),
                        ),
                      ),

                      // '또는' 구분선
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: const BoxDecoration(color: Color(0x268E51FF)),
                            ),
                          ),
                          const Text(
                            '또는',
                            style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12, fontFamily: 'Noto Sans KR', fontWeight: FontWeight.w400, height: 1.33),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: const BoxDecoration(color: Color(0x268E51FF)),
                            ),
                          ),
                        ],
                      ),

                      // 회원가입 버튼
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.67, color: const Color(0x4C8E51FF)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(color: Color(0xFFC4B4FF), fontSize: 14, fontFamily: 'Noto Sans KR', fontWeight: FontWeight.w600, height: 1.43),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. 하단 문구 영역
              Container(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                alignment: Alignment.center,
                child: const Text(
                  '드림퀘스트와 함께 꿈을 이루어가세요 ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12, fontFamily: 'Noto Sans KR', fontWeight: FontWeight.w400, height: 1.33),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}