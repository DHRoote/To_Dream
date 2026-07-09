import 'package:flutter/material.dart';

class DynamicCalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DynamicCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DynamicCalendarWidget> createState() => _DynamicCalendarWidgetState();
}

class _DynamicCalendarWidgetState extends State<DynamicCalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

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
        color: Colors.white.withValues(alpha: 0.03),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.67, color: Color(0x268E51FF)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          _buildDaysOfWeek(),
          const SizedBox(height: 12),

          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = [
      {'label': '일', 'color': const Color(0xB2FF6467)},
      {'label': '월', 'color': const Color(0xFF7C6FA0)},
      {'label': '화', 'color': const Color(0xFF7C6FA0)},
      {'label': '수', 'color': const Color(0xFF7C6FA0)},
      {'label': '목', 'color': const Color(0xFF7C6FA0)},
      {'label': '금', 'color': const Color(0xFF7C6FA0)},
      {'label': '토', 'color': const Color(0xB251A2FF)},
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

  Widget _buildCalendarGrid() {
    final int year = _currentMonth.year;
    final int month = _currentMonth.month;

    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekday = firstDayOfMonth.weekday;

    final int leadingDays = firstWeekday == 7 ? 0 : firstWeekday;
    final int totalCells = leadingDays + daysInMonth;
    final int trailingDays = (7 - (totalCells % 7)) % 7;
    final int totalGridSize = totalCells + trailingDays;

    final DateTime previousMonth = DateTime(year, month - 1);
    final int daysInPrevMonth = DateTime(year, month, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalGridSize,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        DateTime cellDate;
        bool isCurrentMonth = false;

        if (index < leadingDays) {
          int day = daysInPrevMonth - leadingDays + index + 1;
          cellDate = DateTime(previousMonth.year, previousMonth.month, day);
        } else if (index >= leadingDays && index < leadingDays + daysInMonth) {
          int day = index - leadingDays + 1;
          cellDate = DateTime(year, month, day);
          isCurrentMonth = true;
        } else {
          int day = index - (leadingDays + daysInMonth) + 1;
          cellDate = DateTime(year, month + 1, day);
        }

        return _buildDateCell(cellDate, isCurrentMonth);
      },
    );
  }

  // 💡 [수정] 터치 영역 극대화 작업 적용된 데이트 셀
  Widget _buildDateCell(DateTime date, bool isCurrentMonth) {
    bool isSelected = date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;

    return GestureDetector(
      // 💡 opaque 설정으로 투명한 여백 공간을 눌러도 hit-test가 통과되어 터치가 인식됩니다!
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onDateSelected(date);

        setState(() {
          if (date.month != _currentMonth.month) {
            _currentMonth = DateTime(date.year, date.month, 1);
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        child: Container(
          width: 28,
          height: 28,
          decoration: isSelected
              ? ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFF8E51FF), Color(0xFFE12AFB)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            shadows: const [
              BoxShadow(color: Color(0x7F4D179A), blurRadius: 3, offset: Offset(0, 1)),
              BoxShadow(color: Color(0xFFED6AFF), blurRadius: 0, spreadRadius: 3),
            ],
          )
              : null,
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isCurrentMonth ? const Color(0xFFF0EAFF) : const Color(0x4C7C6FA0)),
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