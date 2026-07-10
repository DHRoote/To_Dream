import 'package:eh/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/group_mission.dart';
import '../widgets/mission_card.dart';
import 'create_mission_screen.dart';
import 'chat_screen.dart';
import '../mainapp/main_drawer.dart';

class GroupMissionScreen extends StatefulWidget {
  const GroupMissionScreen({super.key});

  @override
  State<GroupMissionScreen> createState() => _GroupMissionScreenState();
}

class _GroupMissionScreenState extends State<GroupMissionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '전체';
  final List<String> _categories = ['전체', '운동', '취미', '공부', '식습관', '기타'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = context.watch<UserProvider>().userId;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E), // Very dark blue/black
        endDrawer: const MainEndDrawer(),
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('그룹 미션', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('group_missions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          final allMissions = snapshot.data!.docs.map((doc) => GroupMission.fromFirestore(doc)).toList();
          
          final query = _searchController.text.toLowerCase();
          final filteredMissions = allMissions.where((mission) {
            final matchesQuery = mission.title.toLowerCase().contains(query) ||
                mission.leaderName.toLowerCase().contains(query);
            final matchesCategory = _selectedCategory == '전체' || mission.category == _selectedCategory;
            return matchesQuery && matchesCategory;
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    hintText: '미션 이름, 리더 검색...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                // Category Chips
                _buildCategoryList(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 ${filteredMissions.length}개의 미션',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateMissionScreen()),
                        );
                        // StreamBuilder가 자동으로 갱신하므로 별도의 추가 로직 불필요
                      },
                      icon: const Icon(Icons.add_circle_outline, color: Colors.purpleAccent, size: 18),
                      label: const Text(
                        '미션 만들기',
                        style: TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: filteredMissions.isEmpty
                      ? const Center(child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: filteredMissions.length,
                          itemBuilder: (context, index) {
                            final mission = filteredMissions[index];
                            final isJoined = mission.participants.contains(myUserId);

                            return MissionCard(
                              mission: mission,
                              isJoined: isJoined,
                              onJoin: isJoined 
                                ? () {
                                    // 이미 참가 중이면 채팅방으로 이동
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(mission: mission),
                                      ),
                                    );
                                  }
                                : () async {
                                    // 참가하기 로직
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('group_missions')
                                          .doc(mission.id)
                                          .update({
                                        'currentParticipants': FieldValue.increment(1),
                                        'participants': FieldValue.arrayUnion([myUserId]),
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${mission.title} 미션에 참가했습니다!')),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('참가 실패: $e')),
                                        );
                                      }
                                    }
                                  },
                              onDelete: mission.participants.isNotEmpty && mission.participants.first == myUserId
                                ? () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFF1E1E2C),
                                        title: const Text('미션 삭제', style: TextStyle(color: Colors.white)),
                                        content: const Text('정말로 이 그룹 미션을 삭제하시겠습니까?', style: TextStyle(color: Colors.white70)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('취소', style: TextStyle(color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('group_missions')
                                            .doc(mission.id)
                                            .delete();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('미션이 삭제되었습니다.')),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('삭제 실패: $e')),
                                          );
                                        }
                                      }
                                    }
                                  }
                                : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildCategoryList() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(
                minWidth: 64,
                minHeight: 32,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purpleAccent
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                cat,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  height: 1.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}