import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../views/sign/sign_in.dart';
import '../../providers/user_provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isEditing = false;

  String userId = "";
  String gender = "";

  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final nicknameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    userId = context.read<UserProvider>().userId;

    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    DocumentSnapshot doc = await firestore
        .collection("users")
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        usernameController.text = data["username"] ?? "";

        nameController.text = data["name"] ?? "";

        nicknameController.text = data["nickname"] ?? "";

        phoneController.text = data["phone_number"] ?? "";

        passwordController.text = data["password"] ?? "";

        gender = data["gender"] ?? "";

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUser() async {
    await firestore.collection("users").doc(userId).update({
      "name": nameController.text,

      "nickname": nicknameController.text,

      "phone_number": phoneController.text,

      "password": passwordController.text,

      "gender": gender,

      "updated_at": Timestamp.now(),
    });

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("프로필이 수정되었습니다.")));
  }

  Future<void> deleteAccount() async {
    try {
      // Firestore 사용자 데이터 삭제
      await firestore.collection("users").doc(userId).delete();

      // Provider 사용자 정보 초기화
      context.read<UserProvider>().clearUser();

      // 로그인 페이지 이동
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("탈퇴 처리 중 오류가 발생했습니다.")));
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: const Color(0xFF1E1E3A),

              borderRadius: BorderRadius.circular(24),

              border: Border.all(color: Colors.white10),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "회원 탈퇴",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 20,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "탈퇴하면 계정 정보가 삭제됩니다.\n정말 탈퇴하시겠습니까?",

                  style: TextStyle(
                    color: Color(0xFFB0A8C8),

                    fontSize: 14,

                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          height: 45,

                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),

                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(color: Colors.white10),
                          ),

                          child: const Text(
                            "취소",

                            style: TextStyle(
                              color: Color(0xFF7C6FA0),

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);

                          deleteAccount();
                        },

                        child: Container(
                          height: 45,

                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),

                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(color: Colors.redAccent),
                          ),

                          child: const Text(
                            "탈퇴",

                            style: TextStyle(
                              color: Colors.redAccent,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget inputBox({
    required String title,

    required TextEditingController controller,

    bool readOnly = false,

    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16162A),

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.white10),
          ),

          child: TextField(
            controller: controller,

            readOnly: readOnly,

            obscureText: obscure,

            style: const TextStyle(color: Colors.white),

            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget genderButton(String value) {
    final bool isSelected = gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: isEditing
            ? () {
                setState(() {
                  gender = value;
                });
              }
            : null,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),

          decoration: ShapeDecoration(
            color: isSelected
                ? const Color(0x268E51FF)
                : Colors.white.withValues(alpha: 0.04),

            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,

                color: isSelected
                    ? const Color(0xFF8E51FF)
                    : Colors.transparent,
              ),

              borderRadius: BorderRadius.circular(10),
            ),
          ),

          child: Text(
            value,

            textAlign: TextAlign.center,

            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFF0EAFF)
                  : const Color(0xFF7C6FA0),

              fontSize: 14,

              fontFamily: 'Noto Sans KR',

              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,

        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.32, 0),

            end: Alignment(0.68, 1),

            colors: [Color(0xFF1A1040), Color(0xFF0F0C2E)],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: Container(
                        padding: const EdgeInsets.all(8),

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(color: Colors.white10),
                        ),

                        child: const Icon(
                          Icons.arrow_back_ios_new,

                          color: Colors.white,

                          size: 18,
                        ),
                      ),
                    ),

                    const Text(
                      "내 프로필",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        if (isEditing) {
                          updateUser();
                        } else {
                          setState(() {
                            isEditing = true;
                          });
                        }
                      },

                      child: Text(
                        isEditing ? "저장" : "수정",

                        style: const TextStyle(
                          color: Colors.orangeAccent,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E3A),

                          borderRadius: BorderRadius.circular(24),

                          border: Border.all(color: Colors.white10),
                        ),

                        child: Column(
                          children: [
                            inputBox(
                              title: "아이디(수정불가)",

                              controller: usernameController,

                              readOnly: true,
                            ),

                            inputBox(
                              title: "이름",

                              controller: nameController,

                              readOnly: !isEditing,
                            ),

                            inputBox(
                              title: "닉네임",

                              controller: nicknameController,

                              readOnly: !isEditing,
                            ),

                            inputBox(
                              title: "전화번호",

                              controller: phoneController,

                              readOnly: !isEditing,
                            ),

                            inputBox(
                              title: "비밀번호",

                              controller: passwordController,

                              readOnly: !isEditing,

                              obscure: !isEditing,
                            ),

                            Align(
                              alignment: Alignment.centerLeft,

                              child: const Text(
                                "성별",

                                style: TextStyle(
                                  color: Colors.grey,

                                  fontSize: 13,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                genderButton("남성"),

                                const SizedBox(width: 12),

                                genderButton("여성"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,

                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,

                            side: const BorderSide(color: Colors.redAccent),

                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),

                          onPressed: () {
                            showDeleteDialog();
                          },

                          child: const Text(
                            "회원 탈퇴",

                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
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
