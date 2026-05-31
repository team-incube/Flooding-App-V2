import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';

/// 홈 카드 상단의 공통 `{아이콘} {타이틀}` 묶음.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconSize = AppSize.s24,
  });

  /// 헤더 아이콘 팩토리. 예) `AppIcon.calendar`.
  final AppIconBuilder icon;
  final String title;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon(size: iconSize),
        const SizedBox(width: AppSpacing.s4),
        Text(
          title,
          style: AppTextStyle.text1.copyWith(color: AppColors.lightMainText),
        ),
      ],
    );
  }
}
