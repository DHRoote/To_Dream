import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';
import '../theme/furniture_model.dart';
import '../theme/theme_display_widget.dart';

class FriendDetailScreen extends StatefulWidget {
  final FriendModel friend;

  const FriendDetailScreen({super.key, required this.friend});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  int _selectedTabIndex = 0;

  final List<Color> _presetBgColors = [const Color(0xFF283593), const Color(0xFF004D40), const Color(0xFF4A148C)];
  final List<IconData> _presetIcons = [Icons.menu_book, Icons.directions_run, Icons.record_voice_over];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F071D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.friend.nickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${widget.friend.lastActive} 활동', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildTabSelector(),
            const SizedBox(height: 20),
            // 💡 탭 선택 상태에 따라 실시간 파이어베이스 렌더링 위젯 호출
            if (_selectedTabIndex == 0) _buildFirebaseMissionList() else _buildFirebaseMySpace(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1435),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8A2387), Color(0xFFE94057)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 36),
              ),
              Positioned(
                right: -6, bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(12)),
                  child: Text('${widget.friend.level}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.friend.nickname, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.friend.xpProgress, minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${_formatNumber(widget.friend.currentXp)} / ${_formatNumber(widget.friend.maxXp)} XP', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        _buildTabItem('개인 미션', 0),
        const SizedBox(width: 16),
        _buildTabItem('나만의 공간', 1),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3, width: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD946EF) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 1. Firebase에서 미션 리스트 불러오기
  Widget _buildFirebaseMissionList() {
    return StreamBuilder<QuerySnapshot>(
      // 🚨 [수정 완료] 'personal_missions' 컬렉션에서 데이터 조회
      stream: FirebaseFirestore.instance
          .collection('personal_missions')
          .where('user_id', isEqualTo: widget.friend.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                  '진행 중인 미션이 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, height: 1.5)
              ),
            ),
          );
        }

        final missionDocs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: missionDocs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = missionDocs[index].data() as Map<String, dynamic>;

            // 💡 [수정 완료] 제공해주신 DB 구조에 맞게 필드명 매핑
            final String title = data['title']?.toString() ?? '알 수 없는 미션';
            final String desc = data['description']?.toString() ?? ''; // DB 필드명: description

            // 💡 진행률 계산 (progress / target)
            final double currentProgress = (data['progress'] as num?)?.toDouble() ?? 0.0;
            final double target = (data['target'] as num?)?.toDouble() ?? 1.0;
            // target이 0일 경우 에러 방지용 삼항 연산자 처리
            final double progressRatio = target > 0 ? (currentProgress / target) : 0.0;
            final double safeProgress = progressRatio > 1.0 ? 1.0 : progressRatio;

            // 💡 완료 여부 (is_completed)
            final bool isCompleted = data['is_completed'] == true;
            final String status = isCompleted ? '완료' : '진행중';

            // 💡 보상 XP (reward_xp)
            final String xp = '+${data['reward_xp'] ?? 0} XP';

            // 아이콘과 배경색 프리셋을 순환하며 적용
            final Color iconBg = _presetBgColors[index % _presetBgColors.length];
            final IconData iconData = _presetIcons[index % _presetIcons.length];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1435),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
                    child: Icon(iconData, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: safeProgress, minHeight: 6,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF00E5FF)
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                                status,
                                style: TextStyle(
                                    color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF00E5FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text(xp, style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 💡 2. Firebase에서 나만의 공간(가구 배치) 불러오기
  Widget _buildFirebaseMySpace() {
    return StreamBuilder<QuerySnapshot>(
      // 친구 UID를 바탕으로 테마 배치 정보 가져오기
      stream: FirebaseFirestore.instance
          .collection('theme_placements')
          .where('user_id', isEqualTo: widget.friend.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(60.0),
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('정보를 불러올 수 없습니다.', style: TextStyle(color: Colors.white54)));
        }

        // 파이어베이스 문서를 PlacedItem 객체로 변환
        List<PlacedItem> friendPlacedItems = [];
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final int fId = data['furniture_id'] ?? 0;
          friendPlacedItems.add(
            PlacedItem(
              docId: doc.id,
              item: FurnitureMaster.findById(fId),
              x: data['position_x'] ?? 0,
              y: data['position_y'] ?? 0,
              rotation: data['rotation'] ?? 0,
            ),
          );
        }

        // 💡 기존에 만들어둔 ThemeDisplayWidget을 렌더링
        return Container(
          // 테두리 등 약간의 데코레이션 추가
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: ThemeDisplayWidget(placedItems: friendPlacedItems),
        );
      },
    );
  }
}