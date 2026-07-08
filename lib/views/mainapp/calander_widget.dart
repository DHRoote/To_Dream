import 'package:flutter/material.dart';

class DynamicCalendarWidget extends StatefulWidget {
  const DynamicCalendarWidget({super.key});

  @override
  State<DynamicCalendarWidget> createState() => _DynamicCalendarWidgetState();
}

class _DynamicCalendarWidgetState extends State<DynamicCalendarWidget> {
  DateTime _currentMonth = DateTime.now(); // 현재 화면에 보이는 달
  DateTime? _selectedDate = DateTime.now(); // 유저가 선택한 날짜

  // 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.03), // 유저 기존 코드의 0.03 반영
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.67, color: Color(0x268E51FF)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 달력 헤더 (연도/월 및 이동 화살표)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentMonth.year}년 ${_currentMonth.month}월',
                style: const TextStyle(
                  color: Color(0xFFF0EAFF),
                  fontSize: 16,
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF7C6FA0)),
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF7C6FA0)),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),

          // 2. 요일 라벨 (일~토)
          _buildDaysOfWeek(),

          const SizedBox(height: 12),

          // 3. 달력 일자 그리드 (GridView)
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  // 요일 라벨 생성 위젯 (디자인 파일의 색상 수치 정확히 반영)
  Widget _buildDaysOfWeek() {
    final days = [
      {'label': '일', 'color': const Color(0xB2FF6467)}, // 빨간색
      {'label': '월', 'color': const Color(0xFF7C6FA0)},
      {'label': '화', 'color': const Color(0xFF7C6FA0)},
      {'label': '수', 'color': const Color(0xFF7C6FA0)},
      {'label': '목', 'color': const Color(0xFF7C6FA0)},
      {'label': '금', 'color': const Color(0xFF7C6FA0)},
      {'label': '토', 'color': const Color(0xB251A2FF)}, // 파란색
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        return Expanded(
          child: Text(
            day['label'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: day['color'] as Color,
              fontSize: 10,
              fontFamily: 'Noto Sans KR',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        );
      }).toList(),
    );
  }

  // 달력 내부 날짜 그리드 생성 로직
  Widget _buildCalendarGrid() {
    final int year = _currentMonth.year;
    final int month = _currentMonth.month;

    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekday = firstDayOfMonth.weekday; // 1(월) ~ 7(일)

    // 이번 달 1일 앞의 빈 칸(이전 달 날짜) 개수 계산 (일요일 시작 기준)
    final int leadingDays = firstWeekday == 7 ? 0 : firstWeekday;

    // 전체 출력해야 할 칸 수 = 앞 빈칸 + 이번 달 일수
    final int totalCells = leadingDays + daysInMonth;

    // 7열 맞춤을 위해 뒤에 추가해야 할 다음 달 날짜 개수
    final int trailingDays = (7 - (totalCells % 7)) % 7;
    final int totalGridSize = totalCells + trailingDays;

    final DateTime previousMonth = DateTime(year, month - 1);
    final int daysInPrevMonth = DateTime(year, month, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 방지
      itemCount: totalGridSize,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7일 체제
        childAspectRatio: 1.2, // 셀 비율 미세조정
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        DateTime cellDate;
        bool isCurrentMonth = false;

        if (index < leadingDays) {
          // 1. 이전 달 날짜 계산
          int day = daysInPrevMonth - leadingDays + index + 1;
          cellDate = DateTime(previousMonth.year, previousMonth.month, day);
        } else if (index >= leadingDays && index < leadingDays + daysInMonth) {
          // 2. 현재 달 날짜 계산
          int day = index - leadingDays + 1;
          cellDate = DateTime(year, month, day);
          isCurrentMonth = true;
        } else {
          // 3. 다음 달 날짜 계산
          int day = index - (leadingDays + daysInMonth) + 1;
          cellDate = DateTime(year, month + 1, day);
        }

        return _buildDateCell(cellDate, isCurrentMonth);
      },
    );
  }

  // 개별 날짜 1칸의 디자인 처리
  Widget _buildDateCell(DateTime date, bool isCurrentMonth) {
    bool isSelected = _selectedDate != null &&
        date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          // 선택한 날짜가 이전/다음 달이면 자동으로 해당 달력으로 페이지 전환
          if (date.month != _currentMonth.month) {
            _currentMonth = DateTime(date.year, date.month, 1);
          }
        });
      },
      child: Center(
        child: Container(
          width: 28, // 디자인 파일 크기 반영
          height: 28,
          decoration: isSelected
              ? ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFF8E51FF), Color(0xFFE12AFB)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100), // 원형 디자인
            ),
            shadows: const [
              BoxShadow(color: Color(0x7F4D179A), blurRadius: 3, offset: Offset(0, 1)),
              BoxShadow(color: Color(0xFFED6AFF), blurRadius: 0, spreadRadius: 3), // 은은한 핑크 외곽선 효과
            ],
          )
              : null,
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isCurrentMonth ? const Color(0xFFF0EAFF) : const Color(0x4C7C6FA0)), // 현재 달이 아니면 투명도 부여
              fontSize: 11,
              fontFamily: 'Noto Sans KR',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        ),
      ),
    );
  }
}