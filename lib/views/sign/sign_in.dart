import 'package:flutter/material.dart';
import 'package:eh/views/mainapp/main_app.dart';
import 'package:eh/views/sign/sign_up.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBlankWarning = false;
  bool _isAuthFailed = false;
  bool _isObscured = true;

  void _handleLogin() {
    // 입력 공백 확인
    if (_emailController.text == '' || _passwordController.text == '') {
      setState(() {
        _isBlankWarning = true;
      });
      return;
    }

    // 로그인 인증
    if (true) {
      // 로그인 인증 성공
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainAppPage()),
      );
    } else {
      setState(() {
        _isAuthFailed = true;
      });
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
                    // 배경 글로우 효과
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
                    // 타이틀 및 서브타이틀
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
                                borderSide: const BorderSide(
                                  width: 0.67,
                                  color: Color(0x338E51FF),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  width: 0.67,
                                  color: Color(0x338E51FF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  width: 1.0,
                                  color: Color(0x7F8E51FF),
                                ),
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
                            // 변수 상태에 따라 글자를 마스킹하거나 보여줍니다.
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
                                  // _isObscured 가 true면 눈 모양, false면 대각선 눈 모양 기본 아이콘 사용
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

                      // 로그인 유지 체크박스
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0.67,
                                  color: Color(0x4C8E51FF),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const Text(
                            '로그인 유지',
                            style: TextStyle(
                              color: Color(0xFF7C6FA0),
                              fontSize: 14,
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w500,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),

                      if(_isBlankWarning) ...[
                        const Text(
                            '아이디와 비밀번호를 입력해주세요.',
                            style: TextStyle (
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: 'Noto Sans KR'
                            )
                        )
                      ],

                      if(_isAuthFailed) ...[
                        const Text(
                            '아이디와 비밀번호를 다시 확인해주세요.',
                            style: TextStyle (
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: 'Noto Sans KR'
                            )
                        ),
                      ],

                      // 로그인 버튼
                      Container(
                        width: double.infinity,
                        height: 48, // 기존 디자인의 상하 패딩(28) + 텍스트 높이(20)를 합산한 원래 높이
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.00, 0.00),
                            end: Alignment(1.00, 1.00),
                            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero, // Container 높이에 맞추기 위해 내부 패딩 제거
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                            ),
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
                              decoration: const BoxDecoration(
                                color: Color(0x268E51FF),
                              ),
                            ),
                          ),
                          const Text(
                            '또는',
                            style: TextStyle(
                              color: Color(0xFF7C6FA0),
                              fontSize: 12,
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Color(0x268E51FF),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 회원가입 버튼
                      Container(
                        width: double.infinity,
                        height: 48, // 로그인 버튼과 동일한 높이로 고정하여 크기 통일
                        decoration: BoxDecoration(
                          // 기존의 선 두께와 색상, 둥근 모서리 유지
                          border: Border.all(
                            width: 0.67,
                            color: const Color(0x4C8E51FF),
                          ),
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
                            padding: EdgeInsets.zero, // Container 크기에 온전히 맞추기 위해 기본 여백 제거
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14), // 클릭 시 물결 애니메이션(Ripple)이 둥근 테두리에 예쁘게 맞도록 설정
                            ),
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              color: Color(0xFFC4B4FF),
                              fontSize: 14,
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w600,
                              height: 1.43,
                            ),
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
                  style: TextStyle(
                    color: Color(0xFF7C6FA0),
                    fontSize: 12,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
