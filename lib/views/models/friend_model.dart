class FriendModel {
  final String id;
  final String nickname;     // 예: 별빛사냥꾼
  final String realName;     // 예: 이서연
  final String title;        // 예: 달빛 모험가
  final int level;           // 예: 18
  final int currentXp;       // 예: 2100
  final int maxXp;           // 예: 3000
  final String lastActive;   // 예: 방금 전, 1시간 전

  FriendModel({
    required this.id,
    required this.nickname,
    required this.realName,
    required this.title,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.lastActive,
  });

  // XP 달성률 (0.0 ~ 1.0 사이 값 반환)
  double get xpProgress => maxXp > 0 ? currentXp / maxXp : 0.0;
}