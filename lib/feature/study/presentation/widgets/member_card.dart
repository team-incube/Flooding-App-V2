import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../view_models/study_member_view_model.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.model, required this.number});

  static const Size fixedSize = Size(173, 165);

  final int number;
  final StudyMemberViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fixedSize.height,
      width: fixedSize.width,
      decoration: BoxDecoration(
        color: AppColors.lightSub4,
        borderRadius: BorderRadius.circular(AppRadius.s12),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Text("$number", style: AppTextStyle.text3),
            ),
          ),

          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcon.avatar(size: AppSize.s64),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        model.name,
                        style: AppTextStyle.text2.copyWith(
                          color: AppColors.lightMainText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.s2),
                        child: AppIcon.female(size: AppSize.s12),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    "${model.schoolNb}",
                    style: AppTextStyle.caption1.copyWith(
                      color: AppColors.lightSub1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
