import 'package:flutter/material.dart';

class FriendRequestSheet extends StatelessWidget {
  const FriendRequestSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 더미 데이터 (추후 Firebase 연동 시 교체할 부분)
    final List<Map<String, dynamic>> requests = [
      {'nickname': '썬더썬', 'id': 'user_sun77', 'level': 8, 'icon': Icons.flash_on},
      {'nickname': '문워커', 'id': 'user_moo42', 'level': 5, 'icon': Icons.nightlight_round},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1435), // 피그마 다크 퍼플 배경
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 높이 차지
        children: [
          // 1. 헤더 (타이틀 + 닫기 버튼)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '요청 관리',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. 요청 리스트
          ListView.builder(
            shrinkWrap: true, // 바텀시트 안에서 스크롤 가능하도록 설정
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
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
                    // 아바타 & 레벨 뱃지
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(req['icon'], color: Colors.white),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB800),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${req['level']}',
                              style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // 닉네임 & 아이디
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req['nickname'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(req['id'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                        ],
                      ),
                    ),

                    // 수락 버튼 (밝은 보라/네온)
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 친구 수락 로직
                        print("${req['nickname']} 수락됨");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D4EDD),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('수락', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),

                    // 거절 버튼 (어두운 배경)
                    OutlinedButton(
                      onPressed: () {
                        // TODO: 친구 거절 로직
                        print("${req['nickname']} 거절됨");
                      },
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
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}