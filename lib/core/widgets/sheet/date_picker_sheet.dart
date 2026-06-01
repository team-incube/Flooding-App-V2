import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/icon/app_icon.dart';
import '../../theme/text_style/app_text_style.dart';
import 'app_form_sheet.dart';

/// 월 단위 달력에서 날짜 하나를 고르는 팝업.
///
/// 상단 네비게이터의 화살표로 선택 날짜를 하루씩 옮기고, 달력 셀을 눌러 해당
/// 월의 날짜를 바로 고른다. '적용'으로 선택한 [DateTime](자정 기준)을 반환한다.
class DatePickerSheet extends StatefulWidget {
  const DatePickerSheet({super.key, this.initialDate});

  /// 처음 선택되어 있을 날짜. 미지정 시 오늘 날짜.
  final DateTime? initialDate;

  /// 날짜 선택 팝업을 띄우고 선택된 날짜를 반환한다.
  /// 뒤로가기·바깥 탭으로 닫으면 null을 반환한다.
  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    return showAppFormDialog<DateTime>(
      context,
      builder: (_) => DatePickerSheet(initialDate: initialDate),
    );
  }

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  static const List<String> _weekdayLabels = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  late DateTime _selected = _dateOnly(widget.initialDate ?? DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _stepDay(int delta) {
    setState(() {
      _selected = DateTime(
        _selected.year,
        _selected.month,
        _selected.day + delta,
      );
    });
  }

  String get _headerLabel {
    final yy = (_selected.year % 100).toString().padLeft(2, '0');
    final mm = _selected.month.toString().padLeft(2, '0');
    final dd = _selected.day.toString().padLeft(2, '0');
    final weekday = _weekdayLabels[_selected.weekday - 1];
    return '$yy.$mm.$dd ($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s24,
        AppSpacing.s12,
        0,
      ),
      header: _MonthNavigator(
        label: _headerLabel,
        onPrev: () => _stepDay(-1),
        onNext: () => _stepDay(1),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _WeekdayRow(labels: _weekdayLabels),
          const SizedBox(height: AppSpacing.s8),
          _CalendarGrid(
            month: _selected,
            selected: _selected,
            onSelect: (date) => setState(() => _selected = date),
          ),
        ],
      ),
      confirmLabel: '적용',
      onConfirm: () => Navigator.of(context).pop(_selected),
    );
  }
}

/// 좌우 화살표 + 선택 날짜 라벨로 구성된 헤더 네비게이터.
class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Chevron(onTap: onPrev, flip: true),
        const SizedBox(width: AppSpacing.s8),
        Text(
          label,
          style: AppTextStyle.text2.copyWith(color: AppColors.lightSub1),
        ),
        const SizedBox(width: AppSpacing.s8),
        _Chevron(onTap: onNext),
      ],
    );
  }
}

/// 방향 화살표(오른쪽 셰브론을 좌우 반전해 왼쪽으로도 쓴다).
class _Chevron extends StatelessWidget {
  const _Chevron({required this.onTap, this.flip = false});

  final VoidCallback onTap;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    Widget icon = AppIcon.chevronRight(color: AppColors.lightSub2);
    if (flip) {
      icon = Transform.flip(flipX: true, child: icon);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: icon,
    );
  }
}

/// 요일 헤더 한 줄(월~일).
class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final label in labels)
          SizedBox(
            width: _DayCell.size,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyle.caption1.copyWith(
                color: AppColors.lightSub2,
                fontWeight: AppTextStyle.semiBold,
              ),
            ),
          ),
      ],
    );
  }
}

/// 한 달치 날짜 격자(월요일 시작, 앞뒤 달 날짜는 흐리게).
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
  });

  /// 표시할 달(연·월만 사용).
  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    // 월요일을 0으로 두는 시작 오프셋.
    final leading = firstDay.weekday - 1;
    final gridStart = firstDay.subtract(Duration(days: leading));

    // 6주(42칸)를 채워 달의 모든 날짜를 포함한다.
    final weeks = <Widget>[];
    for (var week = 0; week < 6; week++) {
      final cells = <Widget>[];
      for (var day = 0; day < 7; day++) {
        final date = gridStart.add(Duration(days: week * 7 + day));
        cells.add(
          _DayCell(
            date: date,
            inMonth: date.month == month.month,
            selected: _isSameDay(date, selected),
            onTap: () => onSelect(date),
          ),
        );
      }
      weeks.add(
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: cells),
      );
      if (week < 5) weeks.add(const SizedBox(height: AppSpacing.s12));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppRadius.s8),
      ),
      padding: const EdgeInsets.all(AppSpacing.s8),
      child: Column(mainAxisSize: MainAxisSize.min, children: weeks),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 날짜 한 칸(40×40, 선택 시 메인 컬러 채움).
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.onTap,
  });

  static const double size = 40;

  final DateTime date;
  final bool inMonth;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (selected) {
      textColor = AppColors.lightSub4;
    } else if (inMonth) {
      textColor = AppColors.lightSub1;
    } else {
      textColor = AppColors.lightSub2;
    }

    return Material(
      color: selected ? AppColors.lightP1 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.s8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s8),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              '${date.day}',
              style: AppTextStyle.caption1.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
