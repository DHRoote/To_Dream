import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String id;
  final String nickname;     // 예: 별빛사냥꾼
  final String realName;     // 예: 이서연
  final int level;           // 예: 18
  final int currentXp;       // 예: 2100
  final int maxXp;           // 예: 3000
  final String lastActive;   // 예: 방금 전, 1시간 전

  FriendModel({
    required this.id,
    required this.nickname,
    required this.realName,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.lastActive,
  });

  // XP 달성률 (0.0 ~ 1.0 사이 값 반환)
  double get xpProgress => maxXp > 0 ? currentXp / maxXp : 0.0;

  // 💡 Firestore 문서를 FriendModel 객체로 변환해 주는 헬퍼 메서드 추가
  factory FriendModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FriendModel(
      id: doc.id,
      nickname: data['nickname'] ?? '알 수 없음',
      realName: data['realName'] ?? '',
      level: data['level'] ?? 1,
      currentXp: data['currentXp'] ?? 0,
      maxXp: data['maxXp'] ?? 100,
      // DB에 Timestamp로 저장된다면 추후 변환 로직 추가 필요 (일단은 String으로 처리)
      lastActive: data['lastActive'] ?? '접속 정보 없음',
    );
  }
}