import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 1. 파이어스토어 패키지 추가됨
import 'package:eh/providers/user_provider.dart'; // 본인의 실제 프로바이더 경로에 맞게 확인하세요

class MissionCreateDialog extends StatefulWidget {
  const MissionCreateDialog({super.key});

  @override
  State<MissionCreateDialog> createState() => _MissionCreateDialogState();
}

class _MissionCreateDialogState extends State<MissionCreateDialog> {
  // 사전 정의된 임의의 미션 리스트
  final List<Map<String, dynamic>> _presetMissions = [
    {'id': 1, 'title': '아침 물 한 잔 마시기', 'points': 10},
    {'id': 2, 'title': '알고리즘 1문제 풀기', 'points': 50},
    {'id': 3, 'title': '30분 가벼운 산책', 'points': 30},
    {'id': -1, 'title': '직접 입력하기 (Custom)', 'points': 0}, // 커스텀 식별용 ID
  ];

  int? _selectedMissionId;
  DateTime? _selectedDate;

  // 커스텀 미션용 컨트롤러
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _customDescController = TextEditingController();

  @override
  void dispose() {
    _customTitleController.dispose();
    _customDescController.dispose();
    super.dispose();
  }

  // 일주일 날짜 생성 함수
  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    // 공용 바구니에서 유저 ID 꺼내기
    final myUserId = context.read<UserProvider>().userId;
    final isCustomMode = _selectedMissionId == -1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1543), Color(0xFF12083A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x338E51FF), width: 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타이틀
              const Text(
                '새로운 미션 생성',
                style: TextStyle(
                  color: Color(0xFFF0EAFF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 1. 미션 선택 드롭다운
              const Text('미션 선택', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x338E51FF)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMissionId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1543),
                    hint: const Text('수행할 미션을 선택하세요', style: TextStyle(color: Colors.white54)),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8E51FF)),
                    items: _presetMissions.map((mission) {
                      return DropdownMenuItem<int>(
                        value: mission['id'],
                        child: Text(
                          mission['title'],
                          style: const TextStyle(color: Color(0xFFF0EAFF)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMissionId = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. 커스텀 입력 필드 (직접 입력 선택 시에만 렌더링)
              if (isCustomMode) ...[
                _buildTextField('미션 제목', _customTitleController, '예: 나만의 특별한 운동'),
                const SizedBox(height: 16),
                _buildTextField('상세 설명 (선택)', _customDescController, '미션에 대한 규칙이나 설명을 적어주세요.'),
                const SizedBox(height: 16),
              ],

              // 3. 날짜 선택 (일주일)
              const Text('수행할 날짜', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 14)),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = _getWeekDays()[index];
                    final isSelected = _selectedDate?.day == date.day;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 52,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8E51FF) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8E51FF) : const Color(0x338E51FF),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E', 'ko_KR').format(date), // 요일 (월, 화...)
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF7C6FA0),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFF0EAFF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 4. 취소 / 생성 버튼
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소', style: TextStyle(color: Color(0xFF7C6FA0))),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _submitMission(myUserId),
                        child: const Text(
                          '미션 생성',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드 빌더 (커스텀 폼 용)
  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7C6FA0), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x338E51FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8E51FF)),
            ),
          ),
        ),
      ],
    );
  }

  // 💡 2. 파이어베이스 파이어스토어 실제 연동 완료된 함수 로직
  Future<void> _submitMission(String userId) async {
    if (_selectedMissionId == null) {
      _showError('미션을 선택해주세요.');
      return;
    }
    if (_selectedDate == null) {
      _showError('수행할 날짜를 선택해주세요.');
      return;
    }
    if (_selectedMissionId == -1 && _customTitleController.text.trim().isEmpty) {
      _showError('커스텀 미션 제목을 입력해주세요.');
      return;
    }

    Map<String, dynamic> missionDataToSave = {};

    if (_selectedMissionId == -1) {
      // [커스텀 미션인 경우 데이터 구조]
      missionDataToSave = {
        'user_id': userId,
        'is_custom': true,
        'title': _customTitleController.text.trim(),
        'description': _customDescController.text.trim(),
        'target_date': Timestamp.fromDate(_selectedDate!), // 구글 타임스탬프 객체로 변환
        'progress': 0,
        'max_progress': 1,
        'points': 0,
        'created_at': FieldValue.serverTimestamp(), // 구글 서버 시간 저장
        'completed_at': null,
      };
    } else {
      // [사전 정의된 미션인 경우 데이터 구조]
      final presetMission = _presetMissions.firstWhere((m) => m['id'] == _selectedMissionId);

      missionDataToSave = {
        'user_id': userId,
        'is_custom': false,
        'mission_id': _selectedMissionId,
        'title': presetMission['title'],
        'description': '',
        'target_date': Timestamp.fromDate(_selectedDate!),
        'progress': 0,
        'max_progress': 1,
        'points': presetMission['points'],
        'created_at': FieldValue.serverTimestamp(),
        'completed_at': null,
      };
    }

    try {
      // 💡 실제 파이어스토어의 'personal_missions' 컬렉션에 문서를 추가(저장)합니다.
      await FirebaseFirestore.instance
          .collection('personal_missions')
          .add(missionDataToSave);

      // 성공적으로 저장이 끝나면 팝업창을 닫고 부모창에 새로고침 신호(true)를 전달합니다.
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ DB 저장 실패: $e');
      if (mounted) {
        _showError('미션을 저장하는 중 오류가 발생했습니다.');
      }
    }
  }

  // 간단한 스낵바 에러 메시지
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}