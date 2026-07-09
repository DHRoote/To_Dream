import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../mainapp/main_drawer.dart';
import '../models/group_mission.dart';

class TotalMissionScreen extends StatefulWidget {
  const TotalMissionScreen({super.key});

  @override
  State<TotalMissionScreen> createState() => _TotalMissionScreenState();
}

class _TotalMissionScreenState extends State<TotalMissionScreen> {
  int _selectedTabIndex = 0; // 0: 진행 중인 미션, 1: 종료된 미션

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().userId;

    return Scaffold(
      endDrawer: const MainEndDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.32, 0.00),
            end: Alignment(0.68, 1.00),
            colors: [Color(0xFF1A1040), Color(0xFF0F0C2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 10),
              _buildTabs(),
              const SizedBox(height: 20),
              Expanded(
                child: _buildMissionList(userId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const Text(
            '전체 미션',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabItem(0, '진행 중인 미션', Icons.access_time),
          const SizedBox(width: 12),
          _buildTabItem(1, '종료된 미션', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)])
                : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('personal_missions')
          .where('user_id', isEqualTo: userId)
          .snapshots(),
      builder: (context, personalSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('group_missions').snapshots(),
          builder: (context, groupSnapshot) {
            if (personalSnapshot.connectionState == ConnectionState.waiting ||
                groupSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
            }

            // 개인 미션 변환
            List<Map<String, dynamic>> allMissions = [];
            if (personalSnapshot.hasData) {
              for (var doc in personalSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final progress = (data['progress'] ?? 0) / (data['max_progress'] ?? 1);
                allMissions.add({
                  'type': '개인',
                  'title': data['title'] ?? '',
                  'description': data['description'] ?? '개인 미션 달성하기',
                  'progress': progress,
                  'xp': data['points'] ?? 0,
                  'isFinished': progress >= 1.0,
                  'remaining': '오늘 자정',
                  'icon': '💧', // 기본 아이콘
                });
              }
            }

            // 그룹 미션 변환
            if (groupSnapshot.hasData) {
              for (var doc in groupSnapshot.data!.docs) {
                final mission = GroupMission.fromFirestore(doc);
                allMissions.add({
                  'type': '그룹',
                  'title': mission.title,
                  'description': mission.description,
                  'progress': mission.progress,
                  'xp': mission.xp,
                  'isFinished': mission.progress >= 1.0,
                  'remaining': mission.remainingTime,
                  'icon': '🏃', // 기본 아이콘
                });
              }
            }

            // 탭에 따라 필터링
            final filteredMissions = allMissions.where((m) {
              return _selectedTabIndex == 0 ? !m['isFinished'] : m['isFinished'];
            }).toList();

            if (filteredMissions.isEmpty) {
              return Center(
                child: Text(
                  _selectedTabIndex == 0 ? '진행 중인 미션이 없습니다.' : '종료된 미션이 없습니다.',
                  style: const TextStyle(color: Colors.white38),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredMissions.length,
              itemBuilder: (context, index) {
                return _buildMissionCard(filteredMissions[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final bool isPersonal = mission['type'] == '개인';
    final double progress = mission['progress'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(mission['icon'], style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['title'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission['description'],
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPersonal ? Colors.purple.withValues(alpha: 0.2) : Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mission['type'],
                  style: TextStyle(
                    color: isPersonal ? Colors.purpleAccent : Colors.tealAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.orangeAccent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+${mission['xp']} XP',
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    mission['remaining'],
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
