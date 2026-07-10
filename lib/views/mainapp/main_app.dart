import 'package:eh/views/mainapp/main_drawer.dart';
import 'package:eh/views/mainapp/calander_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eh/providers/user_provider.dart';
import '../theme/theme_main.dart';
import '../models/group_mission.dart';
import '../widgets/mission_card.dart';
import '../screens/chat_screen.dart';

class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  String _selectedMissionTab = '개인';

  // 💡 메인 앱에서 선택된 날짜를 직접 들고 관리합니다.
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final myUserId = context.read<UserProvider>().userId;
    final myNickname = context.read<UserProvider>().nickname;

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
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThemeAppPage(),
              ),
            );
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(myNickname),
                      const SizedBox(height: 24),

                      // 💡 [수정] 외부 위젯 달력에 상태값과 콜백 함수를 주입합니다.
                      DynamicCalendarWidget(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date; // 달력에서 날짜를 찍으면 메인 앱 상태가 변함
                          });
                        },
                      ),
                      const SizedBox(height: 28),

                      _buildMissionTabBar(),
                      const SizedBox(height: 16),

                      _buildMissionList(myUserId, myNickname),
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

  Widget _buildHeader(String nickname) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '안녕하세요,',
              style: TextStyle(
                color: Color(0xFF7C6FA0),
                fontSize: 14,
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    color: Color(0xFFF0EAFF),
                    fontSize: 20,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
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

  Widget _buildMissionList(String userId, String myNickname) {
    if (_selectedMissionTab == '개인') {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('personal_missions')
            .where('user_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF8E51FF))),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  '등록된 미션이 없습니다.',
                  style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 14),
                ),
              ),
            );
          }

          // 💡 달력에서 선택한 날짜(_selectedDate)와 파이어베이스 미션의 날짜 대조 필터링
          final filteredMissions = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? targetTimestamp = data['target_date'] as Timestamp?;
            if (targetTimestamp == null) return false;

            final targetDate = targetTimestamp.toDate();
            return targetDate.year == _selectedDate.year &&
                targetDate.month == _selectedDate.month &&
                targetDate.day == _selectedDate.day;
          }).toList();

          if (filteredMissions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  '해당 날짜에 예정된 미션이 없습니다.',
                  style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 14),
                ),
              ),
            );
          }

          return Column(
            children: filteredMissions.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String title = data['title'] ?? '제목 없음';
              final int progress = data['progress'] ?? 0;
              final int maxProgress = data['max_progress'] ?? 1;
              final int points = data['points'] ?? 0;

              final double progressRatio = (maxProgress > 0) ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildMissionCard(
                  title: title,
                  subtitle: '보상: $points XP',
                  progress: progressRatio,
                  themeColor: const Color(0xFF7C3AED),
                ),
              );
            }).toList(),
          );
        },
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('group_missions')
            .where('participants', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF8E51FF))),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  '참여 중인 그룹 미션이 없습니다.\n우측 메뉴의 [그룹 미션]에서 새로운 미션에 참여해 보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }

          final missions = snapshot.data!.docs.map((doc) => GroupMission.fromFirestore(doc)).toList();

          return Column(
            children: missions.map((mission) {
              return MissionCard(
                mission: mission,
                isJoined: true, // 홈에 보이는 건 이미 참가한 미션들이므로
                onJoin: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(mission: mission),
                    ),
                  );
                },
                onDelete: mission.participants.isNotEmpty && mission.participants.first == userId
                    ? () {
                        _showDeleteConfirmDialog(context, mission);
                      }
                    : null,
              );
            }).toList(),
          );
        },
      );
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, GroupMission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('미션 삭제', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('${mission.title} 미션을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('group_missions')
                    .doc(mission.id)
                    .delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('미션이 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('삭제', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required String title,
    required String subtitle,
    required double progress,
    required Color themeColor,
  }) {
    final bool isCompleted = progress >= 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 0.67,
              color: isCompleted ? const Color(0x6610B981) : const Color(0x198E51FF)
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF10B981) : themeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF7C6FA0) : const Color(0xFFF0EAFF),
                    fontSize: 14,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? '달성 완료 🎉' : subtitle,
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF7C6FA0),
                    fontSize: 11,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: isCompleted ? const Color(0xFF10B981) : themeColor,
                  strokeWidth: 3.5,
                ),
              ),
              Text(
                isCompleted ? '완료' : '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFF0EAFF),
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