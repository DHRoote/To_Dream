import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../widgets/friend_card.dart';
import '../widgets/friend_request_sheet.dart';
import '../widgets/friend_add_sheet.dart';
import '../screens/friend_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 친구의 UID 목록을 받아와서 실제 유저 데이터를 조회하는 함수
  Future<List<FriendModel>> _fetchFriendsData(List<String> friendIds) async {
    if (friendIds.isEmpty) return [];

    List<FriendModel> friendsList = [];
    for (String uid in friendIds) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        friendsList.add(FriendModel.fromFirestore(doc));
      }
    }
    return friendsList;
  }

  // 💡 친구 추가 바텀 시트 열기
  void _openAddFriendSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 시트도 같이 올라가게 설정
      backgroundColor: Colors.transparent, // 시트 자체 배경을 투명하게 (내부 UI 둥근 모서리 적용을 위해)
      builder: (context) => const FriendAddSheet(),
    );
  }

  // 💡 요청 관리 바텀 시트 열기
  void _openRequestSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const FriendRequestSheet(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인된 내 UID 가져오기
    final myUserId = context.read<UserProvider>().userId;

    return Scaffold(
      backgroundColor: const Color(0xFF140C26), // 임의의 배경색 (기존 UI 맞춤)
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- 1. 상단 타이틀 & 버튼 영역 ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '친구 목록',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // 요청 관리 버튼
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: _openRequestSheet,
                        tooltip: '친구 요청 관리',
                      ),
                      // 친구 추가 버튼
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.cyanAccent),
                        onPressed: _openAddFriendSheet,
                        tooltip: '새로운 친구 추가',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- 2. 검색바 영역 ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '내 친구 검색',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 20),

              // --- 3. Firebase 연동 친구 카드 리스트 뷰 ---
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  // 내 유저 문서를 실시간 구독하여 friend_list 배열의 변화를 감지합니다.
                  stream: FirebaseFirestore.instance.collection('users').doc(myUserId).snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                    }

                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Center(child: Text('유저 정보를 불러올 수 없습니다.', style: TextStyle(color: Colors.white)));
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    // 💡 firestore에 저장될 배열 필드 이름 'friend_list'
                    final List<dynamic> rawFriendIds = userData['friend_list'] ?? [];
                    final List<String> friendIds = rawFriendIds.cast<String>();

                    if (friendIds.isEmpty) {
                      return const Center(
                        child: Text(
                          '아직 추가된 친구가 없습니다.\n우측 상단 아이콘을 눌러 새로운 친구를 추가해 보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, height: 1.5),
                        ),
                      );
                    }

                    // 친구 UID 목록이 있으면 실제 데이터를 FutureBuilder로 불러옵니다.
                    return FutureBuilder<List<FriendModel>>(
                      future: _fetchFriendsData(friendIds),
                      builder: (context, friendsSnapshot) {
                        if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                        }

                        final friends = friendsSnapshot.data ?? [];

                        // 로컬 검색어 필터링 적용
                        final searchQuery = _searchController.text.trim().toLowerCase();
                        final filteredFriends = friends.where((f) {
                          return f.nickname.toLowerCase().contains(searchQuery) ||
                              f.realName.toLowerCase().contains(searchQuery);
                        }).toList();

                        if (filteredFriends.isEmpty && searchQuery.isNotEmpty) {
                          return const Center(
                            child: Text('검색된 친구가 없습니다.', style: TextStyle(color: Colors.white54)),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredFriends.length,
                          itemBuilder: (context, index) {
                            final friend = filteredFriends[index];
                            return FriendCard(
                              friend: friend,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendDetailScreen(friend: friend),
                                  ),
                                );
                              },
                            );
                          },
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