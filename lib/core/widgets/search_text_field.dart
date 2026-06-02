import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_size.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';
import '../theme/text_style/app_text_style.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
  });

  final TextEditingController textEditingController;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(AppRadius.s8),
        border: Border.all(color: AppColors.lightSub2),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: textEditingController,
        style: AppTextStyle.text3.copyWith(color: AppColors.lightMainText),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTextStyle.text3.copyWith(color: AppColors.lightSub2),
        ),
      ),
    );
  }
}
