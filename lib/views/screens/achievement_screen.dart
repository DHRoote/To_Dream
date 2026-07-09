import 'package:flutter/material.dart';
import '../mainapp/main_drawer.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MainEndDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.32, 0.00),
            end: Alignment(0.68, 1.00),
            colors: [
              Color(0xFF1A1040),
              Color(0xFF0F0C2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      _buildAchievementItem(
                        icon: '🌟',
                        title: '첫 미션 완료',
                        description: '생애 첫 미션을 완료했습니다',
                        isCompleted: false,
                        iconBgColor: Colors.orange.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '🔥',
                        title: '7일 연속 달성',
                        description: '7일 동안 미션을 연속으로 완료했습니다',
                        isCompleted: false,
                        iconBgColor: Colors.deepOrange.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '📚',
                        title: '독서왕',
                        description: '독서 관련 미션 10개 완료',
                        isCompleted: false,
                        iconBgColor: Colors.green.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '🏃',
                        title: '운동 마스터',
                        description: '운동 관련 미션 20개 완료',
                        isCompleted: false,
                        iconBgColor: Colors.blue.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '💯',
                        title: '100개 미션',
                        description: '총 100개 미션 완료',
                        isCompleted: false,
                        iconBgColor: Colors.redAccent.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '⚡',
                        title: '레벨 50',
                        description: '레벨 50 달성',
                        isCompleted: false,
                        iconBgColor: Colors.amber.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '👥',
                        title: '그룹 리더',
                        description: '그룹 미션 생성 및 완료',
                        isCompleted: false,
                        iconBgColor: Colors.purple.withValues(alpha: 0.1),
                      ),
                      _buildAchievementItem(
                        icon: '🏆',
                        title: '30일 연속',
                        description: '30일 연속 미션 완료',
                        isCompleted: false,
                        iconBgColor: Colors.yellow.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const Text(
            '업적',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 24),
                  SizedBox(width: 10),
                  Text(
                    '업적',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '0/8',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' 달성',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '도전하고 성취하며 성장하세요',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.0,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required String icon,
    required String title,
    required String description,
    String? date,
    required bool isCompleted,
    required Color iconBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF1E1E3A) : const Color(0xFF16162A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCompleted ? Colors.white10 : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 28,
                color: isCompleted ? null : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isCompleted ? Colors.white : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted)
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text(
                            '달성',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isCompleted ? Colors.grey : Colors.grey.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
