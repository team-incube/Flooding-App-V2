import 'package:flutter/material.dart';

import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_actions.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_day_grid.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_header.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_weekday_row.dart';

/// 음악신청 화면의 캘린더 아이콘에서 띄우는 날짜 선택 다이얼로그.
///
/// 선택 후 "적용" 을 누르면 선택한 날짜를, "뒤로가기" 를 누르면 null 을 돌려준다.
class SongCalendarDialog extends StatefulWidget {
  const SongCalendarDialog({super.key, this.initialDate});

  final DateTime? initialDate;

  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => SongCalendarDialog(initialDate: initialDate),
    );
  }

  @override
  State<SongCalendarDialog> createState() => _SongCalendarDialogState();
}

class _SongCalendarDialogState extends State<SongCalendarDialog> {
  // 화면에 보이는 달(_focusedDay 의 연·월) 과 선택된 날짜.
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    // 기본으로 오늘 날짜에 네모가 떠 있고, 다른 날짜를 고르면 그쪽으로 옮겨진다.
    final initial = widget.initialDate ?? DateTime.now();
    _focusedDay = initial;
    _selectedDay = initial;
  }

  void _moveMonth(int delta) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + delta,
        _focusedDay.day,
      );
    });
  }

  void _selectDay(DateTime date) {
    setState(() {
      _selectedDay = date;
      _focusedDay = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // 가로: 전체 너비에서 좌우 24 씩 인셋 → 화면 너비 - 48.
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: AppColors.lightBgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        // 세로: 471 고정.
        height: 471,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
          child: Column(
            children: [
              // 6주 달에도 넘치지 않게 스크롤 허용, 버튼은 하단 고정.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CalendarHeader(
                        focusedDay: _focusedDay,
                        onPreviousMonth: () => _moveMonth(-1),
                        onNextMonth: () => _moveMonth(1),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const CalendarWeekdayRow(),
                      const SizedBox(height: AppSpacing.s8),
                      CalendarDayGrid(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        onDaySelected: _selectDay,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: CalendarActions(
                  onCancel: () => Navigator.pop(context),
                  onApply: () => Navigator.pop(context, _selectedDay),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
