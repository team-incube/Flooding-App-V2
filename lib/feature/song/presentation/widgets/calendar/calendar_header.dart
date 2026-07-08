import 'package:flutter/material.dart';

import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_utils.dart';

/// ‹ 26.07.08(수) › — 뒤로 아이콘과 그 반전 아이콘으로 월을 이동하는 헤더.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPreviousMonth,
          icon: AppIcon.back(),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          formatCalendarHeaderDate(focusedDay),
          style: AppTextStyle.text3.copyWith(color: AppColors.lightSub1),
        ),
        const SizedBox(width: AppSpacing.s8),
        IconButton(
          onPressed: onNextMonth,
          icon: Transform.flip(flipX: true, child: AppIcon.back()),
        ),
      ],
    );
  }
}
