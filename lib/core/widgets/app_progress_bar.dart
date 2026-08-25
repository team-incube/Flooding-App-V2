import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';

/// 진행률을 보여주는 막대 위젯.
///
/// 채워진 구간과 남은 구간이 2px 간격으로 분리된 라운드 막대로 표시된다.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.s8);
    final filledFlex = total <= 0 ? 0 : current.clamp(0, total);
    final emptyFlex = total <= 0 ? 1 : total - filledFlex;

    return SizedBox(
      height: AppSpacing.s32,
      child: Row(
        children: [
          if (filledFlex > 0)
            Expanded(
              flex: filledFlex,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightP1,
                  borderRadius: radius,
                ),
              ),
            ),
          if (filledFlex > 0 && emptyFlex > 0)
            SizedBox(width: AppSpacing.s2),
          if (emptyFlex > 0)
            Expanded(
              flex: emptyFlex,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightSub4,
                  borderRadius: radius,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
