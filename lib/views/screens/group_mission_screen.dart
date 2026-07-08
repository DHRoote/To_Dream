import 'package:flutter/material.dart';
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
  List<GroupMission> _filteredMissions = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '전체';
  final List<String> _categories = ['전체', '운동', '취미', '공부', '식습관', '기타'];

  @override
  void initState() {
    super.initState();
    _filteredMissions = GroupMission.globalMissions;
    _searchController.addListener(_filterMissions);
  }

  void _filterMissions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMissions = GroupMission.globalMissions.where((mission) {
        final matchesQuery = mission.title.toLowerCase().contains(query) ||
            mission.leaderName.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == '전체' || mission.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _addNewMission(GroupMission mission) {
    setState(() {
      GroupMission.globalMissions.insert(0, mission);
      _filterMissions(); // Refresh filtered list
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: _searchController,
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
            SizedBox(
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
                        _filterMissions();
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
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 ${_filteredMissions.length}개의 미션',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateMissionScreen()),
                        );
                        if (result != null && result is GroupMission) {
                          _addNewMission(result);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline, color: Colors.purpleAccent, size: 18),
                      label: const Text(
                        '미션 만들기',
                        style: TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.star_border, color: Colors.grey, size: 16),
                      label: const Text('추천순', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: _filteredMissions.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _filteredMissions.length,
                      itemBuilder: (context, index) {
                        return MissionCard(
                          mission: _filteredMissions[index],
                          onJoin: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(mission: _filteredMissions[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
