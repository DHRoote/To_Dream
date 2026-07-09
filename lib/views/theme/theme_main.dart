import 'package:eh/views/mainapp/main_drawer.dart';
import 'package:flutter/material.dart';

class ThemeAppPage extends StatefulWidget {
  final String userId;
  final String nickname;

  const ThemeAppPage({
    super.key,
    required this.userId,
    required this.nickname
  });

  @override
  State<ThemeAppPage> createState() => _ThemeAppPageState();
}

class _ThemeAppPageState extends State<ThemeAppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      endDrawer: const MainEndDrawer(),

      floatingActionButton: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.00, 0.00),
            end: Alignment(1.00, 1.00),
            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x662563EB),
              blurRadius: 32,
              offset: Offset(0, 8),
              spreadRadius: 0,
            )
          ],
        ),

        // 플로팅 버튼
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '🎯',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '공간',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, -0.8),
            end: Alignment(0.0, 1.0),
            colors: [
              Color(0xFF12083A),
              Color(0xFF0D0A1E),
              Color(0xFF081228)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 메인 영역
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // --- 1. 상단 프로필 및 헤더 영역 ---
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // --- 2. 테마 영역 ---
                      _buildTheme(),
                      const SizedBox(height: 24),

                      /// --- 3. 인벤토리 영역 ---
                      _buildInventory(),
                      const SizedBox(height: 24),
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

  // 상단 프로필 헤더
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '나만의 공간ㅅ',
              style: TextStyle(
                color: Color(0xFFF0EAFF),
                fontSize: 20,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),

            Text(
              '${widget.nickname}님의 공간',
              style: TextStyle(
                color: Color(0xFF7C6FA0),
                fontSize: 14,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Builder(
            builder: (context) {
              return InkWell(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.67, color: Color(0x198E51FF)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Color(0xFFF0EAFF),
                    size: 22,
                  ),
                ),
              );
            }
        ),
      ],
    );
  }

  Widget _buildTheme() {
    return Row(

    );
  }

  Widget _buildInventory() {
    return Row(

    );
  }
}
