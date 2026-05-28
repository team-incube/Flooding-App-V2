import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spcing.dart';
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
    final ratio = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    final radius = BorderRadius.circular(AppRadius.s8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final filledWidth = constraints.maxWidth * ratio;
        final emptyWidth = constraints.maxWidth - filledWidth;

        return SizedBox(
          height: AppSpacing.s32,
          child: Row(
            children: [
              if (filledWidth > 0)
                Container(
                  width: filledWidth,
                  decoration: BoxDecoration(
                    color: AppColors.lightP1,
                    borderRadius: radius,
                  ),
                ),
              if (filledWidth > 0 && emptyWidth > 0)
                const SizedBox(width: AppSpacing.s2),
              if (emptyWidth > 0)
                Expanded(
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
      },
    );
  }
}
