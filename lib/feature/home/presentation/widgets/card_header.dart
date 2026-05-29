import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_font.dart';


/// 홈 카드 상단의 공통 `{아이콘} {타이틀}` 묶음.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.iconPath,
    required this.title,
    this.iconSize = AppSize.s24,
  });

  final String iconPath;
  final String title;
  final double iconSize;


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon.asset(iconPath, size: iconSize),
        const SizedBox(width: AppSpacing.s4),
        Text(
          title,
          style: AppFont.text1.copyWith(color: AppColors.lightMainText),
        ),
      ],
    );
  }
}
