import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isNameError = false;
  bool _isIdError = false;
  bool _isNicknameError = false;
  bool _isPhoneError = false;
  bool _isPasswordError = false;
  bool _isConfirmPasswordError = false;

  bool _isPasswordObscured = true;
  String _selectedGender = '남성';

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    setState(() {
      _isNameError = _nameController.text.trim().isEmpty;
      _isIdError = _idController.text.trim().isEmpty;
      _isNicknameError = _nicknameController.text.trim().isEmpty;
      _isPhoneError = _phoneController.text.trim().isEmpty;
      _isPasswordError = _passwordController.text.trim().isEmpty;
      _isConfirmPasswordError = _confirmPasswordController.text.trim().isEmpty;
    });

    if (_isNameError || _isIdError || _isNicknameError ||
        _isPhoneError || _isPasswordError || _isConfirmPasswordError) {
      return;
    }

    // 모든 검증 통과 시 수행할 로직
    print('가입 완료 진행');
    // todo 데이터베이스 저장 / 서버 전송
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  InputDecoration _buildInputDecoration(String hintText, {bool isError = false}) {
    final borderColor = isError ? Colors.redAccent : const Color(0x338E51FF);
    final focusedBorderColor = isError ? Colors.redAccent : const Color(0x7F8E51FF);

    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0x7F7C6FA0), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(width: 1, color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(width: 1.5, color: focusedBorderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, -0.8),
            end: Alignment(0.0, 1.0),
            colors: [Color(0xFF12083A), Color(0xFF0D0A1E), Color(0xFF081228)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 헤더 영역 생략 (기존과 동일)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
                  child: Row(
                    spacing: 12,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 36, height: 36,
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF0EAFF), size: 16),
                        ),
                      ),
                      const Text('회원가입', style: TextStyle(color: Color(0xFFF0EAFF), fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

                // --- 회원가입 폼 영역 ---
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      // 1. 이름 입력란
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('이름 *', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          TextField(
                            controller: _nameController,
                            onTap: () {
                              if (_isNameError) setState(() => _isNameError = false);
                            },
                            style: const TextStyle(color: Color(0xFFC4B4FF), fontSize: 14),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: _buildInputDecoration('실명을 입력하세요', isError: _isNameError),
                          ),
                        ],
                      ),

                      // 2. 아이디 입력란
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('아이디 *', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          TextField(
                            controller: _idController,
                            onTap: () {
                              if (_isIdError) setState(() => _isIdError = false);
                            },
                            style: const TextStyle(color: Color(0xFFC4B4FF), fontSize: 14),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: _buildInputDecoration('영문 소문자, 숫자 조합', isError: _isIdError),
                          ),
                        ],
                      ),

                      // 3. 닉네임 입력란
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('닉네임 *', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          TextField(
                            controller: _nicknameController,
                            onTap: () {
                              if (_isNicknameError) setState(() => _isNicknameError = false);
                            },
                            style: const TextStyle(color: Color(0xFFC4B4FF), fontSize: 14),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: _buildInputDecoration('앱에서 사용할 닉네임', isError: _isNicknameError),
                          ),
                        ],
                      ),

                      // 4. 전화번호 입력란
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('전화번호 *', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            onTap: () {
                              if (_isPhoneError) setState(() => _isPhoneError = false);
                            },
                            style: const TextStyle(color: Color(0xFFC4B4FF), fontSize: 14),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: _buildInputDecoration('010-0000-0000', isError: _isPhoneError),
                          ),
                        ],
                      ),

                      // 5. 성별 선택란 (생략 없이 동일 유지)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('성별', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedGender = '남성'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: ShapeDecoration(
                                      color: _selectedGender == '남성' ? const Color(0x1A8E51FF) : Colors.white.withValues(alpha: 0.05),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1, color: _selectedGender == '남성' ? const Color(0xFF8E51FF) : const Color(0x338E51FF)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text('남성', textAlign: TextAlign.center, style: TextStyle(color: _selectedGender == '남성' ? const Color(0xFFF0EAFF) : const Color(0xFF7C6FA0))),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedGender = '여성'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: ShapeDecoration(
                                      color: _selectedGender == '여성' ? const Color(0x1A8E51FF) : Colors.white.withValues(alpha: 0.05),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1, color: _selectedGender == '여성' ? const Color(0xFF8E51FF) : const Color(0x338E51FF)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text('여성', textAlign: TextAlign.center, style: TextStyle(color: _selectedGender == '여성' ? const Color(0xFFF0EAFF) : const Color(0xFF7C6FA0))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // 6. 비밀번호 입력란
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('비밀번호 *', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            onTap: () {
                              if (_isPasswordError) setState(() => _isPasswordError = false);
                            },
                            style: const TextStyle(color: Color(0xFFC4B4FF), fontSize: 14),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: _buildInputDecoration('6자 이상 입력하세요', isError: _isPasswordError).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF7C6FA0), size: 20),
                                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 7. 비밀번호 확인 입력란
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('비밀번호 확인 *', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12))),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _isPasswordObscured,
                            onTap: () {
                              if (_isConfirmPasswordError) setState(() => _isConfirmPasswordError = false);
                            },
                            style: const TextStyle(color: Color(0xFFC4B4FF), fontSize: 14),
                            cursorColor: const Color(0xFF7C3AED),
                            decoration: _buildInputDecoration('비밀번호를 다시 입력하세요', isError: _isConfirmPasswordError),
                          ),
                        ],
                      ),

                      // 8. 가입 완료 버튼
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: double.infinity, height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('가입 완료', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}