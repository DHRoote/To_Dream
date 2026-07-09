import 'package:flutter/material.dart';

class FriendAddSheet extends StatefulWidget {
  const FriendAddSheet({super.key});

  @override
  State<FriendAddSheet> createState() => _FriendAddSheetState();
}

class _FriendAddSheetState extends State<FriendAddSheet> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        // 💡 키보드가 올라왔을 때 바텀 시트가 가려지지 않도록 패딩 추가
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1435),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '친구 추가',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. 안내 텍스트
          Text(
            '상대방의 ID를 입력해주세요',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 16),

          // 3. ID 입력 텍스트 필드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF281C46), // 디자인의 어두운 인풋박스 색상
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _idController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixText: '@  ',
                prefixStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
                hintText: '예) user_dreamer123',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. 친구 요청 보내기 버튼
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final inputId = _idController.text.trim();
                if (inputId.isNotEmpty) {
                  // TODO: Firebase 친구 요청 전송 로직
                  print("친구 요청 보냄: $inputId");
                  Navigator.pop(context); // 시트 닫기
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D2E8C), // 피그마 보라색 메인 버튼
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                '친구 요청 보내기',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}