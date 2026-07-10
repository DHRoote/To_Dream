import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> participants;

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
    this.participants = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'currentParticipants': currentParticipants,
      'maxParticipants': maxParticipants,
      'leaderName': leaderName,
      'xp': xp,
      'category': category,
      'status': status,
      'remainingTime': remainingTime,
      'progress': progress,
      'gender': gender,
      'isPublic': isPublic,
      'deposit': deposit,
      'penalty': penalty,
      'prize': prize,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'recruitmentStartDate': recruitmentStartDate != null ? Timestamp.fromDate(recruitmentStartDate!) : null,
      'recruitmentEndDate': recruitmentEndDate != null ? Timestamp.fromDate(recruitmentEndDate!) : null,
      'participants': participants,
    };
  }

  factory GroupMission.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupMission(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      currentParticipants: data['currentParticipants'] ?? 0,
      maxParticipants: data['maxParticipants'] ?? 0,
      leaderName: data['leaderName'] ?? '',
      xp: data['xp'] ?? 0,
      category: data['category'] ?? '',
      status: data['status'] ?? '',
      remainingTime: data['remainingTime'] ?? '',
      progress: (data['progress'] ?? 0.0).toDouble(),
      gender: data['gender'] ?? '모두',
      isPublic: data['isPublic'] ?? true,
      deposit: data['deposit'] ?? 0,
      penalty: data['penalty'] ?? 0,
      prize: data['prize'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      recruitmentStartDate: data['recruitmentStartDate'] != null ? (data['recruitmentStartDate'] as Timestamp).toDate() : null,
      recruitmentEndDate: data['recruitmentEndDate'] != null ? (data['recruitmentEndDate'] as Timestamp).toDate() : null,
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  // 파이어베이스 연동 전까지 데이터를 유지하기 위한 임시 저장소
  static List<GroupMission> globalMissions = [];
  static Map<String, List<Map<String, dynamic>>> globalFeeds = {};
}
