class GroupMission {
  final String id;
  final String title;
  final String description;
  final int currentParticipants;
  final int maxParticipants;
  final String leaderName;
  final int xp;
  final String category;
  final String status; // '진행중', '모집중'
  final String remainingTime;
  final double progress; // 0.0 to 1.0

  final String gender;
  final bool isPublic;
  final int deposit;
  final int penalty;
  final int prize;

  final DateTime startDate;
  final DateTime endDate;
  final DateTime? recruitmentStartDate;
  final DateTime? recruitmentEndDate;

  GroupMission({
    required this.id,
    required this.title,
    required this.description,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.leaderName,
    required this.xp,
    required this.category,
    required this.status,
    required this.remainingTime,
    required this.progress,
    required this.startDate,
    required this.endDate,
    this.recruitmentStartDate,
    this.recruitmentEndDate,
    this.gender = '모두',
    this.isPublic = true,
    this.deposit = 0,
    this.penalty = 0,
    this.prize = 0,
  });

  // 파이어베이스 연동 전까지 데이터를 유지하기 위한 임시 저장소
  static List<GroupMission> globalMissions = [];
}
