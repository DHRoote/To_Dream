import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../widgets/friend_card.dart';
import '../widgets/friend_request_sheet.dart'; // 👈 요청 관리 팝업 창
import '../widgets/friend_add_sheet.dart';     // 👈 친구 추가 팝업 창
import '../screens/friend_detail_screen.dart'; // 👈 [최신 추가] 친구 클릭 시 넘어가는 상세 프로필 화면

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 피그마 UI에 있는 4명의 더미 데이터 (추후 Firebase 연동 시 교체 예정)
  final List<FriendModel> _friends = [
    FriendModel(id: '1', nickname: '별빛사냥꾼', realName: '이서연', title: '달빛 모험가', level: 18, currentXp: 2100, maxXp: 3000, lastActive: '방금 전'),
    FriendModel(id: '2', nickname: '달빛독서왕', realName: '김민준', title: '전설의 독서왕', level: 31, currentXp: 5800, maxXp: 6500, lastActive: '1시간 전'),
    FriendModel(id: '3', nickname: '새벽별', realName: '박지수', title: '새벽 탐험가', level: 11, currentXp: 900, maxXp: 1500, lastActive: '3시간 전'),
    FriendModel(id: '4', nickname: '등산왕', realName: '최현우', title: '산의 정복자', level: 22, currentXp: 3000, maxXp: 3500, lastActive: '어제'),
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
        title: const Text(
          '친구 목록',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // TODO: 메뉴 드로어 연결 필요 시 여기에 작성
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- 1. 친구 검색창 (Search Bar) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF19102E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                  hintText: '친구 검색...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // TODO: 검색어 필터링 로직 추가 가능
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. 리스트 헤더 (친구 수 & [요청관리] & [친구 추가]) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 좌측: 친구 카운트
                Text(
                  '친구 ${_friends.length}명',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // 우측: 요청관리 버튼 + 친구추가 버튼
                Row(
                  children: [
                    // 💡 [요청관리] 버튼 (알림 뱃지 2 포함)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // 🚀 클릭 시 하단에서 요청관리 바텀 시트 띄우기!
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const FriendRequestSheet(),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D2530), // 어두운 청록/네이비 배경
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            side: const BorderSide(color: Color(0xFF00E5FF), width: 1), // 네온 청록색 테두리
                          ),
                          child: const Text(
                            '요청관리',
                            style: TextStyle(
                              color: Color(0xFF00E5FF), // 네온 청록색 텍스트
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 🔴 우측 상단 빨간 알림 뱃지 (숫자 2)
                        Positioned(
                          right: -4,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF2D55), // 피그마 핑크/레드 뱃지 컬러
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10), // 버튼 사이 간격

                    // 💡 [친구 추가] 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        // 🚀 클릭 시 하단에서 친구추가 바텀 시트 띄우기!
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const FriendAddSheet(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        '친구 추가',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D1B54),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: const Color(0xFF8A2387).withOpacity(0.5)),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 3. 친구 카드 리스트 뷰 (ListView.builder 활용) ---
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  return FriendCard(
                    friend: _friends[index],
                    onTap: () {
                      // 🚀 카드를 탭하면 해당 친구의 정보를 담아서 프로필 상세 화면으로 이동!
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendDetailScreen(
                            friend: _friends[index],
                          ),
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
    );
  }
}