import 'package:flutter/material.dart';
import '../models/group_mission.dart';

class CreateMissionScreen extends StatefulWidget {
  const CreateMissionScreen({super.key});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  String _description = '';
  String _category = '운동';
  double _maxParticipants = 20;
  String _gender = '모두';
  bool _isPublic = true;
  int _deposit = 10000;
  int _penalty = 5000;
  int _prize = 15000;
  DateTime _startDate = DateTime.now().add(const Duration(days: 16));
  DateTime _endDate = DateTime.now().add(const Duration(days: 23));
  DateTime _recruitmentStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _recruitmentEndDate = DateTime(DateTime.now().year, DateTime.now().month, 15);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.grey, size: 14),
              Text('미션 목록으로', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        leadingWidth: 120,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '새 그룹 미션 만들기',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Text(
                '함께할 멤버들과 목표를 달성하세요',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              _buildSectionTitle('기본 정보'),
              _buildLabel('미션 제목'),
              _buildTextField('예) 30일 아침 운동 챌린지', (val) => _title = val!),
              const SizedBox(height: 16),
              _buildLabel('미션 설명'),
              _buildTextField('미션에 대한 자세한 설명을 작성하세요', (val) => _description = val!, maxLines: 4),
              const SizedBox(height: 16),
              _buildLabel('카테고리'),
              _buildDropdown(['운동', '취미', '공부', '식습관', '기타'], _category, (val) => setState(() => _category = val!)),
              
              const SizedBox(height: 16),
              _buildLabel('모집 기간'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _recruitmentStartDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _recruitmentStartDate = picked);
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                      child: Text('시작: ${_recruitmentStartDate.year}.${_recruitmentStartDate.month}.${_recruitmentStartDate.day}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _recruitmentEndDate,
                          firstDate: _recruitmentStartDate,
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _recruitmentEndDate = picked);
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                      child: Text('종료: ${_recruitmentEndDate.year}.${_recruitmentEndDate.month}.${_recruitmentEndDate.day}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildLabel('미션 기간'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                      child: Text('시작: ${_startDate.year}.${_startDate.month}.${_startDate.day}', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                      child: Text('종료: ${_endDate.year}.${_endDate.month}.${_endDate.day}', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              _buildSectionTitle('참여 조건'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최대 인원: ${_maxParticipants.toInt()}명', style: const TextStyle(color: Colors.white)),
                  const Text('5명부터 100명까지 설정 가능', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Slider(
                value: _maxParticipants,
                min: 5,
                max: 100,
                divisions: 95,
                activeColor: Colors.purpleAccent,
                onChanged: (val) => setState(() => _maxParticipants = val),
              ),
              const SizedBox(height: 16),
              _buildLabel('참여 가능 성별'),
              _buildDropdown(['모두', '남성', '여성'], _gender, (val) => setState(() => _gender = val!)),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('공개 미션', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('비공개 시 초대받은 사람만 참여 가능', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                    activeThumbColor: Colors.purpleAccent,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              _buildSectionTitle('금액 설정'),
              Row(
                children: [
                  Expanded(child: _buildAmountField('예치금 (원)', _deposit.toString(), (val) => _deposit = int.tryParse(val!) ?? 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAmountField('벌금 (원)', _penalty.toString(), (val) => _penalty = int.tryParse(val!) ?? 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAmountField('상금 (원)', _prize.toString(), (val) => _prize = int.tryParse(val!) ?? 0)),
                ],
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('미션 생성하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white24, thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }

  Widget _buildTextField(String hint, Function(String?) onSaved, {int maxLines = 1}) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E1E2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.isEmpty ? '내용을 입력해주세요' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildAmountField(String label, String initialValue, Function(String?) onSaved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E2C),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1E2C),
          style: const TextStyle(color: Colors.white),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newMission = GroupMission(
        id: DateTime.now().toString(),
        title: _title,
        description: _description,
        currentParticipants: 1,
        maxParticipants: _maxParticipants.toInt(),
        leaderName: '나',
        xp: 500,
        category: _category,
        status: '모집중',
        remainingTime: '${_recruitmentEndDate.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays}일 남음',
        progress: 0.0,
        gender: _gender,
        isPublic: _isPublic,
        deposit: _deposit,
        penalty: _penalty,
        prize: _prize,
        startDate: _startDate,
        endDate: _endDate,
        recruitmentStartDate: _recruitmentStartDate,
        recruitmentEndDate: _recruitmentEndDate,
      );
      Navigator.pop(context, newMission);
    }
  }
}
