import 'package:flutter/material.dart';
import '../screens/group_mission_screen.dart';
import '../screens/achievement_screen.dart';

class MainEndDrawer extends StatelessWidget {
  const MainEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260, // 기존 피그마 디자인의 너비 스펙 완벽 유지
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.32, 0.00),
            end: Alignment(0.68, 1.00),
            colors: [
              Color(0xFF1A1040),
              Color(0xFF0F0C2E)
            ],
          ),
          border: Border(
            left: BorderSide(
              width: 0.67,
              color: Color(0x26A78BFA),
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. 상단 헤더 영역 (프로필 및 정보) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '메뉴',
                          style: TextStyle(
                            color: Color(0xFFF0EAFF),
                            fontSize: 16,
                            fontFamily: 'Noto Sans KR',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0x1AA78BFA), height: 1),
              const SizedBox(height: 16),

              // --- 2. 상호작용 메뉴 버튼 영역 (업적, 개인미션) ---
              // --- 2. 상호작용 메뉴 버튼 영역 (전체 메뉴 추가 및 투명화) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4, // 버튼 간 간격 4px 반영
                  children: [
                    _buildMenuButton(
                      icon: Icons.emoji_events_outlined,
                      title: '업적',
                      onTap: () {
                        Navigator.pop(context); // 클릭 시 드로어 닫기
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AchievementScreen()),
                        );
                      },
                    ),
                    _buildMenuButton(
                      icon: Icons.person_outline,
                      title: '개인 미션',
                      onTap: () {
                        Navigator.pop(context);
                        print('개인 미션 메뉴 클릭됨');
                      },
                    ),
                    _buildMenuButton(
                      icon: Icons.group_outlined, // 그룹 아이콘으로 대체
                      title: '그룹 미션',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GroupMissionScreen()),
                        );
                      },
                    ),
                    _buildMenuButton(
                      icon: Icons.list_alt_outlined,
                      title: '전체 미션',
                      onTap: () {
                        Navigator.pop(context);
                        print('전체 미션 메뉴 클릭됨');
                      },
                    ),
                    _buildMenuButton(
                      icon: Icons.storefront_outlined,
                      title: '상점',
                      onTap: () {
                        Navigator.pop(context);
                        print('상점 메뉴 클릭됨');
                      },
                    ),
                    _buildMenuButton(
                      icon: Icons.people_outline,
                      title: '친구',
                      onTap: () {
                        Navigator.pop(context);
                        print('친구 메뉴 클릭됨');
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(), // 하단 로그아웃 버튼을 아래 구석으로 밀어내기 위한 여백

              // --- 3. 하단 로그아웃 영역 (Stack 오류 완벽 해결) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 로그아웃 세션 해제 처리
                    print('로그아웃 수행');
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        width: 0.67,
                        color: const Color(0x26A78BFA),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center, // 기기 해상도에 상관없이 정확히 텍스트를 중앙 배치
                    child: const Text(
                      '로그아웃',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF7C6FA0),
                        fontSize: 12,
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 배경색과 테두리를 없애고 투명하게 유지한 클릭 버튼 빌더
  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14), // 터치 물결 효과 둥글기 반영
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent, // 배경색 완전 투명하게
          borderRadius: BorderRadius.circular(14),
          // border 속성 삭제
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 피그마 컨테이너(18x18) 크기에 맞춘 아이콘
            Icon(icon, color: const Color(0xFFF0EAFF), size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF7C6FA0),
                fontSize: 14,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w600,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}