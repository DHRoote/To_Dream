import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eh/providers/user_provider.dart';
import './mission_create_dialog.dart';

class MissionManagePage extends StatefulWidget {
  const MissionManagePage({super.key});

  @override
  State<MissionManagePage> createState() => _MissionManagePageState();
}

class _MissionManagePageState extends State<MissionManagePage> {
  // 미션 관리(삭제) 모드 활성화 여부를 추적하는 상태 변수
  bool _isManageMode = false;

  @override
  Widget build(BuildContext context) {
    // 공용 바구니(Provider)에서 현재 로그인된 유저의 ID를 실시간 감시(watch)
    final myUserId = context.watch<UserProvider>().userId;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, -0.8),
            end: Alignment(0.0, 1.0),
            colors: [
              Color(0xFF12083A),
              Color(0xFF0D0A1E),
              Color(0xFF081228)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 헤더: 뒤로가기 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF0EAFF)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '개인 미션 관리',
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Noto Sans KR',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF0EAFF),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. 관리(삭제) 및 생성 버튼 영역
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 미션 관리 모드 토글 버튼
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isManageMode = !_isManageMode;
                              });
                            },
                            icon: Icon(
                              _isManageMode ? Icons.close : Icons.edit_note,
                              size: 20,
                            ),
                            label: Text(_isManageMode ? '관리 종료' : '미션 관리'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _isManageMode ? Colors.white : const Color(0xFFDB2777),
                              backgroundColor: _isManageMode ? const Color(0xFFDB2777) : Colors.transparent,
                              side: const BorderSide(color: Color(0x66DB2777)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          // 미션 생성 버튼
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(0.00, 0.00),
                                end: Alignment(1.00, 1.00),
                                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x662563EB),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => const MissionCreateDialog(),
                                );

                                if (result == true) {
                                  print('새 미션 생성 완료!');
                                }
                              },
                              icon: const Icon(Icons.add, size: 20, color: Colors.white),
                              label: const Text(
                                '미션 생성',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 3. 파이어스토어 실시간 미션 데이터 연동 영역 (StreamBuilder)
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('personal_missions')
                              .where('user_id', isEqualTo: myUserId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: Color(0xFF8E51FF)),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('데이터를 불러오는데 실패했습니다.', style: TextStyle(color: Colors.redAccent)),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  '아직 진행 중인 미션이 없습니다.\n새로운 미션을 생성해 보세요!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 15, height: 1.5),
                                ),
                              );
                            }

                            final missionDocs = snapshot.data!.docs;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '진행 중인 미션',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Noto Sans KR',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFF0EAFF),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '총 ${missionDocs.length}개',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Noto Sans KR',
                                        color: Color(0xFF7C6FA0),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: missionDocs.length,
                                    itemBuilder: (context, index) {
                                      // 💡 내 유저 ID(myUserId)를 카드 빌더에 함께 넘겨줍니다.
                                      return _buildMissionCard(missionDocs[index], myUserId);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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

  // 동적 컨테이너 (미션 아이템 카드 UI)
  Widget _buildMissionCard(QueryDocumentSnapshot doc, String myUserId) {
    final data = doc.data() as Map<String, dynamic>;

    final String title = data['title'] ?? '제목 없음';
    final int points = data['points'] ?? 0;
    final int progress = data['progress'] ?? 0;
    final int maxProgress = data['max_progress'] ?? 1;
    final Timestamp? targetTimestamp = data['target_date'] as Timestamp?;

    // 1. 달성 완료 여부 계산
    final bool isCompleted = progress >= maxProgress;

    // 💡 2. 오늘 날짜 필터링 로직 추가 (연, 월, 일 비교)
    final DateTime now = DateTime.now();
    final bool isToday = targetTimestamp != null &&
        targetTimestamp.toDate().year == now.year &&
        targetTimestamp.toDate().month == now.month &&
        targetTimestamp.toDate().day == now.day;

    // 완료되지 않았고, '오늘' 목표인 미션만 버튼 활성화
    final bool buttonEnabled = !isCompleted && isToday;

    // 버튼 텍스트 동적 분기
    String buttonText = '달성';
    if (isCompleted) {
      buttonText = '완료됨';
    } else if (!isToday) {
      buttonText = '오늘 아님';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 0.67,
              color: isCompleted ? const Color(0x6610B981) : const Color(0x198E51FF)
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF7C6FA0) : const Color(0xFFF0EAFF),
                    fontSize: 15,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isCompleted ? '달성 완료 🎉' : '보상: $points XP ($progress/$maxProgress)',
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF8E51FF),
                    fontSize: 12,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          _isManageMode
              ? IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFDB2777), size: 24),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('personal_missions')
                    .doc(doc.id)
                    .delete();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('미션이 삭제되었습니다.'), backgroundColor: Colors.black),
                  );
                }
              } catch (e) {
                print('미션 삭제 실패: $e');
              }
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          )
              : ElevatedButton(
            // 💡 완료되었거나 오늘 날짜가 아니면 클릭 불가 처리 (null)
            onPressed: !buttonEnabled
                ? null
                : () async {
              try {
                final int nextProgress = progress + 1;
                final bool isNowDone = nextProgress >= maxProgress;

                // 💡 3. 트랜잭션/일괄 처리를 대신해 순차적으로 두 DB의 데이터를 업데이트합니다.
                // [작업 A]: 개인 미션 진행도 업그레이드
                await FirebaseFirestore.instance
                    .collection('personal_missions')
                    .doc(doc.id)
                    .update({
                  'progress': nextProgress,
                  if (isNowDone) 'completed_at': FieldValue.serverTimestamp(),
                });

                // [작업 B]: 유저 컬렉션의 내 계정 XP 증가 (current_xp, total_xp 동시 반영)
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(myUserId)
                    .update({
                  'current_xp': FieldValue.increment(points), // 💡 파이어베이스 점수 누적 내장 기능
                  'total_xp': FieldValue.increment(points),
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('🎉 미션 달성 성공! +$points XP가 적립되었습니다.'),
                        backgroundColor: const Color(0xFF7C3AED)
                    ),
                  );
                }
              } catch (e) {
                print('미션 달성 및 XP 업데이트 실패: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonEnabled
                  ? const Color(0xFF8E51FF).withValues(alpha: 0.2)
                  : Colors.white.withOpacity(0.05),
              foregroundColor: buttonEnabled ? const Color(0xFFF0EAFF) : Colors.white38,
              elevation: 0,
              minimumSize: const Size(60, 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                    color: buttonEnabled ? const Color(0xFF8E51FF) : Colors.transparent,
                    width: 1
                ),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}