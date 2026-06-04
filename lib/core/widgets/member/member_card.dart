import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/icon/app_icon.dart';
import '../../theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/member/view_models/member_view_model.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.model, required this.number});

  static const Size fixedSize = Size(173, 165);

  final int number;
  final MemberViewModel model;

  @override
  Widget build(BuildContext context) {
    //TODO : 남성 Icon 등록시 SizedBox 교체
    final genderIcon = model.gender == Gender.female
        ? AppIcon.female(size: AppSize.s12)
        : const SizedBox.shrink();

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
                        child: genderIcon,
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
