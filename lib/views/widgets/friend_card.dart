import 'package:flutter/material.dart';
import '../models/friend_model.dart';

class FriendCard extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onTap;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1435), // 카드 배경 (어두운 보라색)
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 아바타 & 레벨 뱃지
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.pets, color: Colors.white, size: 32), // 캐릭터 아바타 임시 아이콘
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800), // 레벨 노란색 뱃지
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${friend.level}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // 2. 친구 이름, 칭호, XP 게이지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임 + 본명
                  Row(
                    children: [
                      Text(
                        friend.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${friend.realName})',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 칭호 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
                    ),
                    child: Text(
                      friend.title,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // XP 프로그레스 바 & 수치
                  Row(
                    children: [
                      Expanded(
                        child: ClipReredirect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: friend.xpProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)), // 핑크/퍼플 게이지
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_formatNumber(friend.currentXp)} / ${_formatNumber(friend.maxXp)} XP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. 최근 활동 시간 & 화살표
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  friend.lastActive,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 천 단위 콤마(,) 찍어주는 함수
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}

// ClipReredirect 대체 (오타 방지용 표준 Safe ClipRRect)
class ClipReredirect extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;
  const ClipReredirect({super.key, required this.borderRadius, required this.child});
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: borderRadius, child: child);
}