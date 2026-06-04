import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/color/app_colors.dart';
import '../../../core/theme/text_style/app_text_style.dart';


class NoMemberIcon extends StatelessWidget {
  const NoMemberIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  final Widget icon;
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: AppSpacing.s12),
        Text(
          title,
          style: AppTextStyle.text1.copyWith(color: AppColors.lightSub2),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          subTitle,
          style: AppTextStyle.caption2.copyWith(color: AppColors.lightSub1),
        ),
      ],
    );
  }
}
