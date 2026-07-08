import 'package:flutter/material.dart';

import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_utils.dart';

/// 날짜 그리드. 전체를 볼더 8 박스로 감싸고, 선택 날짜엔 볼더 8·lightP1 네모를
/// 그린다. 날짜를 탭하면 [onDaySelected] 로 해당 날짜를 알린다.
class CalendarDayGrid extends StatelessWidget {
  const CalendarDayGrid({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
    final firstOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final leading = firstOfMonth.weekday - 1; // 월요일 시작 기준 앞쪽 빈 칸 수.
    final rowCount = ((leading + daysInMonth) / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int r = 0; r < rowCount; r++) ...[
            if (r > 0) const SizedBox(height: 12),
            Row(
              children: [
                for (int c = 0; c < 7; c++) ...[
                  if (c > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _buildDayCell(
                      dayNumber: r * 7 + c - leading + 1,
                      daysInMonth: daysInMonth,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 날짜 숫자 하나. 선택 시 볼더 8 · lightP1 네모(높이 40).
  Widget _buildDayCell({required int dayNumber, required int daysInMonth}) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      // 빈 칸도 행 높이(40)를 유지하도록 둔다.
      return const SizedBox(height: 40);
    }

    final date = DateTime(focusedDay.year, focusedDay.month, dayNumber);
    final isSelected = selectedDay != null && isSameDate(selectedDay!, date);

    final Color textColor =
        isSelected ? AppColors.lightBgSurface : AppColors.lightMainText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onDaySelected(date),
      // 폭은 칸에 맞춰 넘침을 막는다.
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.lightP1,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          '$dayNumber',
          style: AppTextStyle.caption1.copyWith(color: textColor),
        ),
      ),
    );
  }
}
