import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';

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
    final myUserId = context.read<UserProvider>().userId;

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
                                _isManageMode = !_isManageMode; // 상태 토글
                              });
                            },
                            icon: Icon(
                              _isManageMode ? Icons.close : Icons.edit_note, // 모드에 따라 아이콘 변경
                              size: 20,
                            ),
                            label: Text(_isManageMode ? '관리 종료' : '미션 관리'), // 모드에 따라 텍스트 변경
                            style: OutlinedButton.styleFrom(
                              // 관리 모드일 때는 눈에 띄게 색상 반전
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
                              onPressed: () {},
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

                      // 리스트 헤더
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
                          const Text(
                            '총 3개',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Noto Sans KR',
                              color: Color(0xFF7C6FA0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. 동적으로 생성될 미션 리스트 영역
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return _buildMissionCard();
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
  Widget _buildMissionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // 우측 버튼 밸런스를 위해 패딩 약간 수정
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.67, color: Color(0x198E51FF)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '매일 아침 30분 달리기',
                  style: TextStyle(
                    color: Color(0xFFF0EAFF),
                    fontSize: 15,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '보상: 150 XP',
                  style: TextStyle(
                    color: Color(0xFF8E51FF),
                    fontSize: 12,
                    fontFamily: 'Noto Sans KR',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 💡 모드에 따라 우측 버튼 동적 렌더링 (핵심 변경점)
          _isManageMode
              ? // 1. 관리 모드일 때: 삭제 버튼
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFDB2777), size: 24),
            onPressed: () {
              // TODO: 삭제 로직
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          )
              : // 2. 일반 모드일 때: 달성 버튼
          ElevatedButton(
            onPressed: () {
              // TODO: 미션 달성(XP 획득) 로직
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E51FF).withValues(alpha: 0.2), // 배경은 연한 보라색
              foregroundColor: const Color(0xFFF0EAFF), // 글씨는 밝게
              elevation: 0,
              minimumSize: const Size(60, 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF8E51FF), width: 1), // 테두리로 포인트
              ),
            ),
            child: const Text(
              '달성',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}