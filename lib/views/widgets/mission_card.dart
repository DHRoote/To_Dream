import 'package:flutter/material.dart';
import '../models/group_mission.dart';

class MissionCard extends StatelessWidget {
  final GroupMission mission;
  final VoidCallback onJoin;
  final VoidCallback? onDelete;
  final bool isJoined;

  const MissionCard({
    super.key,
    required this.mission,
    required this.onJoin,
    this.onDelete,
    this.isJoined = false,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '운동':
        return Icons.fitness_center;
      case '취미':
        return Icons.palette;
      case '공부':
        return Icons.book;
      case '식습관':
        return Icons.restaurant;
      default:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '운동':
        return Colors.orange;
      case '취미':
        return Colors.pinkAccent;
      case '공부':
        return Colors.blueAccent;
      case '식습관':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMoneyInfo(String label, int amount, Color color) {
    final isXP = label == '상금';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        Text(
          isXP 
              ? '+${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} XP'
              : '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Dark theme from image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(mission.category),
                  color: _getCategoryColor(mission.category),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mission.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StatusBadge(status: mission.status),
                        const SizedBox(width: 8),
                        _TimeBadge(time: mission.remainingTime),
                        if (onDelete != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            tooltip: '미션 삭제',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${mission.currentParticipants}/${mission.maxParticipants}명',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '리더: ${mission.leaderName}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildMoneyInfo('예치금', mission.deposit, Colors.blueAccent)),
                        Expanded(child: _buildMoneyInfo('벌금', mission.penalty, Colors.redAccent)),
                        Expanded(child: _buildMoneyInfo('상금', mission.prize, Colors.amber)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: mission.progress,
            backgroundColor: Colors.grey[800],
            color: Colors.lightBlueAccent,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.yellow, size: 16),
              const SizedBox(width: 4),
              Text(
                '+${mission.prize} XP',
                style: const TextStyle(color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  mission.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '기간: ${mission.startDate.month}.${mission.startDate.day} ~ ${mission.endDate.month}.${mission.endDate.day}',
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isJoined 
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : const Color(0xFF2A4E5E),
                            foregroundColor: isJoined 
                                ? const Color(0xFF10B981)
                                : Colors.lightBlueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isJoined ? const Color(0xFF10B981) : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            isJoined ? '참가됨' : '참가하기',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = status == '진행중' ? Colors.purple : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String time;
  const _TimeBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: const TextStyle(color: Colors.tealAccent, fontSize: 10),
      ),
    );
  }
}
