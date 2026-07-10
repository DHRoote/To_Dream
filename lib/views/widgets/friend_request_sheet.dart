import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';

class FriendRequestSheet extends StatelessWidget {
  const FriendRequestSheet({super.key});

  // 유저 UID를 바탕으로 실제 유저 정보(Future)를 가져오는 함수
  Future<Map<String, dynamic>> _fetchUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  // 💡 수락 버튼 클릭 시 로직
  Future<void> _acceptRequest(String myUserId, String targetUserId) async {
    final firestore = FirebaseFirestore.instance;
    // 1. 내 friend_list에 상대방 추가, friend_requests에서 제거
    await firestore.collection('users').doc(myUserId).update({
      'friend_list': FieldValue.arrayUnion([targetUserId]),
      'friend_requests': FieldValue.arrayRemove([targetUserId]),
    });
    // 2. 상대방의 friend_list에도 내 UID 추가 (맞팔 구조)
    await firestore.collection('users').doc(targetUserId).update({
      'friend_list': FieldValue.arrayUnion([myUserId]),
    });
  }

  // 💡 거절 버튼 클릭 시 로직
  Future<void> _declineRequest(String myUserId, String targetUserId) async {
    // 내 friend_requests 목록에서만 제거
    await FirebaseFirestore.instance.collection('users').doc(myUserId).update({
      'friend_requests': FieldValue.arrayRemove([targetUserId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = context.read<UserProvider>().userId;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1435),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('요청 관리', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),

          // StreamBuilder로 내 문서의 friend_requests 배열을 실시간 구독
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(myUserId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final List<dynamic> requests = data['friend_requests'] ?? [];

              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('대기 중인 친구 요청이 없습니다.', style: TextStyle(color: Colors.white54)),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final targetUserId = requests[index] as String;

                  // FutureBuilder로 상대방의 닉네임/레벨 정보 조회
                  return FutureBuilder<Map<String, dynamic>>(
                    future: _fetchUser(targetUserId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) return const SizedBox();

                      final targetData = userSnapshot.data!;
                      final targetNickname = targetData['nickname'] ?? '알 수 없음';
                      final targetLevel = targetData['level'] ?? 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF8A2387), Color(0xFFE94057)]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                Positioned(
                                  right: -4, bottom: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(10)),
                                    child: Text('$targetLevel', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(targetNickname, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _acceptRequest(myUserId, targetUserId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9D4EDD),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('수락', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _declineRequest(myUserId, targetUserId),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.05),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Text('거절', style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}