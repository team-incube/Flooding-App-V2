import 'package:flutter/material.dart';

import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/calendar/calendar_utils.dart';

/// 한국어 요일 헤더(월~일). 각 요일 8/10 패딩, 요일 간격 6.
class CalendarWeekdayRow extends StatelessWidget {
  const CalendarWeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 아래 날짜 그리드(가로 8 패딩)와 열을 맞추기 위한 좌우 인셋.
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    kCalendarWeekdays[i],
                    style: AppTextStyle.caption3.copyWith(
                      color: AppColors.lightSub2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
