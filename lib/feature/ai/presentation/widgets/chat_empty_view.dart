import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';

class ChatEmptyView extends StatelessWidget {
  const ChatEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon.sparkle(size: AppSize.s24, color: AppColors.lightSub2),
          SizedBox(height: AppSpacing.s8),
          Text(
            '무엇이든 물어보세요!',
            style: AppTextStyle.text3.copyWith(color: AppColors.lightSub2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
