import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';

class FriendAddSheet extends StatefulWidget {
  const FriendAddSheet({super.key});

  @override
  State<FriendAddSheet> createState() => _FriendAddSheetState();
}

class _FriendAddSheetState extends State<FriendAddSheet> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  // 💡 파이어베이스 친구 검색 및 추가 핵심 로직
  Future<void> _searchAndAddFriend() async {
    final searchName = _nicknameController.text.trim();
    if (searchName.isEmpty) return;

    setState(() => _isLoading = true);
    final myUserId = context.read<UserProvider>().userId;

    try {
      // 1. users 컬렉션에서 입력한 닉네임과 일치하는 유저 검색
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: searchName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar('해당 닉네임의 유저를 찾을 수 없습니다.');
        setState(() => _isLoading = false);
        return;
      }

      final targetUserDoc = querySnapshot.docs.first;
      final targetUserId = targetUserDoc.id;

      // 2. 자기 자신을 친구로 추가하는 것 방지
      if (targetUserId == myUserId) {
        _showSnackBar('자기 자신은 친구로 추가할 수 없습니다.');
        setState(() => _isLoading = false);
        return;
      }

      final targetNickname = targetUserDoc.data()['nickname'] ?? '알 수 없음';

      // 3. 내 문서의 friend_list 배열에 상대방 UID 추가 (arrayUnion 사용)
      // * arrayUnion은 배열에 값이 없으면 새로 넣고, 이미 있으면 중복 추가를 방지합니다.
      await FirebaseFirestore.instance.collection('users').doc(myUserId).update({
        'friend_list': FieldValue.arrayUnion([targetUserId])
      });

      // 💡 [선택 사항] 서로 100% 맞팔(서로 친구) 구조를 원하신다면 아래 코드의 주석을 해제하세요!
      // 상대방의 문서에도 내 UID를 넣어줍니다. (단방향 팔로우 구조면 생략)
      /*
      await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({
        'friend_list': FieldValue.arrayUnion([myUserId])
      });
      */

      _showSnackBar('$targetNickname님을 친구로 추가했습니다! 🎉');

      if (mounted) {
        Navigator.pop(context); // 추가 성공 시 바텀 시트 닫기
      }
    } catch (e) {
      _showSnackBar('친구 추가 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 바텀 시트 UI 구성
    return Padding(
      // 키보드가 올라올 때 시트가 가려지지 않도록 padding 조절
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('새로운 친구 추가', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nicknameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '친구의 닉네임을 정확히 입력하세요',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.cyanAccent),
                onPressed: _isLoading ? null : _searchAndAddFriend,
              ),
            ),
            onSubmitted: (_) => _isLoading ? null : _searchAndAddFriend(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _searchAndAddFriend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E51FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('친구 추가하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}