import 'package:flutter/material.dart';
import '../models/friend_model.dart';

class FriendDetailScreen extends StatefulWidget {
  final FriendModel friend;

  const FriendDetailScreen({super.key, required this.friend});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  // 탭 선택 상태 관리 (0: 개인 미션, 1: 나만의 공간)
  int _selectedTabIndex = 0;

  // 피그마 UI에 있는 미션 더미 데이터 (추후 Firebase 연동 시 교체)
  final List<Map<String, dynamic>> _missions = [
    {
      'title': '새벽 독서 1시간',
      'desc': '매일 아침 책 읽기',
      'progress': 0.8,
      'status': '진행중',
      'xp': '+150 XP',
      'icon': Icons.menu_book,
      'iconBg': const Color(0xFF283593),
    },
    {
      'title': '10km 달리기',
      'desc': '주 3회 러닝 완주',
      'progress': 1.0,
      'status': '완료',
      'xp': '+300 XP',
      'icon': Icons.directions_run,
      'iconBg': const Color(0xFF004D40),
    },
    {
      'title': '영어 회화 연습',
      'desc': '30분 스피킹 연습',
      'progress': 0.55,
      'status': '진행중',
      'xp': '+120 XP',
      'icon': Icons.record_voice_over,
      'iconBg': const Color(0xFF4A148C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F071D), // 어두운 네이비/퍼플 배경
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
            Text(
              widget.friend.nickname,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${widget.friend.lastActive} 활동',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // --- 1. 상단 프로필 요약 카드 ---
            _buildProfileCard(),
            const SizedBox(height: 20),

            // --- 2. 탭 선택 버튼 (☆ 개인 미션 / 🏠 나만의 공간) ---
            _buildTabSelector(),
            const SizedBox(height: 20),

            // --- 3. 하단 콘텐츠 영역 (선택된 탭에 따라 다르게 표시) ---
            if (_selectedTabIndex == 0)
              _buildMissionList()
            else
              _buildMySpacePlaceholder(),
          ],
        ),
      ),
    );
  }

  // 1. 프로필 요약 카드 위젯
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1435), // 카드 배경
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아바타 & 레벨 뱃지
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 36), // 임시 아바타 아이콘
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800), // 노란색 레벨 뱃지
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.friend.level}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // 닉네임, 칭호, XP 바
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 + 칭호
                Row(
                  children: [
                    Text(
                      widget.friend.nickname,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
                      ),
                      child: Text(
                        widget.friend.title,
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // XP 게이지 & 수치
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.friend.xpProgress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)), // 핑크/퍼플 게이지
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_formatNumber(widget.friend.currentXp)} / ${_formatNumber(widget.friend.maxXp)} XP',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. 탭 선택 위젯 ("☆ 개인 미션" vs "🏠 나만의 공간")
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF160E2A), // 탭 배경
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // 탭 1: 개인 미션
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _selectedTabIndex == 0
                      ? const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFFD946EF)]) // 선택 시 핑크/퍼플 그래디언트
                      : null,
                  color: _selectedTabIndex == 0 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_outline, size: 18, color: _selectedTabIndex == 0 ? Colors.white : Colors.white54),
                    const SizedBox(width: 6),
                    Text(
                      '개인 미션',
                      style: TextStyle(
                        color: _selectedTabIndex == 0 ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 탭 2: 나만의 공간
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _selectedTabIndex == 1
                      ? const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFFD946EF)])
                      : null,
                  color: _selectedTabIndex == 1 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 18, color: _selectedTabIndex == 1 ? Colors.white : Colors.white54),
                    const SizedBox(width: 6),
                    Text(
                      '나만의 공간',
                      style: TextStyle(
                        color: _selectedTabIndex == 1 ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. 미션 리스트 위젯
  Widget _buildMissionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _missions.length,
      itemBuilder: (context, index) {
        final mission = _missions[index];
        final isCompleted = mission['status'] == '완료';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1435), // 카드 배경
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1열: 아이콘 + 제목 + 설명 + 상태 뱃지
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 미션 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: mission['iconBg'],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(mission['icon'], color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // 제목 & 설명
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mission['desc'],
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // 상태 뱃지 ("진행중" vs "완료")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF004D40).withOpacity(0.6) // 완료: 다크 그린/티얼 배경
                          : const Color(0xFF4A148C).withOpacity(0.6), // 진행중: 다크 퍼플 배경
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCompleted ? const Color(0xFF00E5FF) : const Color(0xFFD946EF),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      mission['status'],
                      style: TextStyle(
                        color: isCompleted ? const Color(0xFF00E5FF) : const Color(0xFFD946EF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2열: 프로그레스 바 & 퍼센트
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: mission['progress'],
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        // 완료된 미션은 청록색(Teal), 진행 중은 핑크/퍼플색
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? const Color(0xFF00E5FF) : const Color(0xFFD946EF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${(mission['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      color: isCompleted ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3열: 보상 XP 텍스트
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    mission['xp'],
                    style: const TextStyle(
                      color: Color(0xFFFFB800), // 노란색 XP 보상 텍스트
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. "나만의 공간" 탭 선택 시 보여줄 임시 화면
  Widget _buildMySpacePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            '${widget.friend.nickname}님의 나만의 공간입니다.\n(기능 준비 중)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  // 천 단위 콤마 찍기 함수
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}