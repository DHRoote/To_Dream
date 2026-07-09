import 'package:eh/views/mainapp/main_drawer.dart';
import 'package:eh/views/mainapp/calander_widget.dart';
import 'package:flutter/material.dart';
import '../models/group_mission.dart';
import '../widgets/mission_card.dart';
import '../screens/chat_screen.dart';

class MainAppPage extends StatefulWidget {
  final String userId;
  final String nickname;

  const MainAppPage({
    super.key,
    required this.userId,
    required this.nickname
  });

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  // 현재 선택된 미션 탭 상태 관리
  String _selectedMissionTab = '개인';

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
            // TODO: 버튼 클릭 시 동작 추가, 위젯 페이지 이동
            print('공간 FAB 클릭됨');
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
                '🏡',
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

      // 메인 영역
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

                      // --- 2. 달력 영역 (동적 변환을 위해 메서드로 분리) ---
                      DynamicCalendarWidget(),
                      const SizedBox(height: 28),

                      // --- 3. 미션 탭 바 (개인미션 / 그룹미션 토글) ---
                      _buildMissionTabBar(),
                      const SizedBox(height: 16),

                      // --- 4. 동적 미션 리스트 표시 영역 ---
                      _buildMissionList(),
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
              '안녕하세요,',
              style: TextStyle(
                color: Color(0xFF7C6FA0),
                fontSize: 14,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),

            Row(
              children: [
                Text(
                  widget.nickname,
                  style: TextStyle(
                    color: Color(0xFFF0EAFF),
                    fontSize: 20,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '님 🌟',
                  style: TextStyle(
                    color: Color(0xFFF0EAFF),
                    fontSize: 20,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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

  // 달력 위젯
  // 외부 클래스로 대체

  // 미션 선택 탭바 (개인미션 / 그룹미션)
  Widget _buildMissionTabBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton('개인'),
          _buildTabButton('그룹'),
        ],
      ),
    );
  }

  // 탭바 개별 버튼 생성기
  Widget _buildTabButton(String title) {
    final bool isSelected = _selectedMissionTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMissionTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: ShapeDecoration(
            color: isSelected ? const Color(0x268E51FF) : Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: isSelected ? const Color(0xFF8E51FF) : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            '$title미션',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFF0EAFF) : const Color(0xFF7C6FA0),
              fontSize: 14,
              fontFamily: 'Noto Sans KR',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 현재 선택된 탭에 맞춰 동적으로 미션 리스트를 빌드하는 핵심 컬럼
  Widget _buildMissionList() {
    // 실제 운영 시 데이터베이스나 서버 연동 리스트로 대체될 영역입니다.
    if (_selectedMissionTab == '개인') {
      return Column(
        spacing: 12,
        children: [
          _buildMissionCard('아침 물 한 잔 마시기', '매일 오전 8:00', 0.8, const Color(0xFF7C3AED)),
          _buildMissionCard('알고리즘 1문제 풀기', '매일 오후 9:00', 0.3, const Color(0xFFDB2777)),
          _buildMissionCard('일기 작성하기', '매일 오후 11:00', 0.0, const Color(0xFF7C6FA0)),
        ],
      );
    } else {
      if (GroupMission.globalMissions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text(
              '참여 중인 그룹 미션이 없습니다.\n새로운 미션에 참여해 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      }
      return Column(
        children: GroupMission.globalMissions.map((mission) {
          return MissionCard(
            mission: mission,
            onJoin: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(mission: mission),
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  // 단일 미션 카드 레이아웃 컴포넌트
  Widget _buildMissionCard(String title, String time, double progress, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.67, color: Color(0x198E51FF)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        children: [
          // 좌측 대표 포인트 컬러 서클
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),

          // 중앙 미션 정보 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF0EAFF),
                    fontSize: 14,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF7C6FA0),
                    fontSize: 11,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 우측 달성률 원형 프로그레스 인디케이터
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: themeColor,
                  strokeWidth: 3.5,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFFF0EAFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}