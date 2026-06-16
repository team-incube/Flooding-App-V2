import 'package:flutter/material.dart';

import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/enum/gender.dart';

import '../models/member_model.dart';

typedef MemberSelectAction = void Function(int schoolNb);

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.model, required this.number})
    : onSelect = null,
      isSelected = false;

  const MemberCard.button({
    super.key,
    required this.model,
    required this.number,
    required this.onSelect,
    required this.isSelected,
  });

  static const Size fixedSize = Size(173, 165);

  final int number;
  final MemberModel model;
  final bool isSelected;
  final MemberSelectAction? onSelect;

  @override
  Widget build(BuildContext context) {
    //TODO : 남성 Icon 등록시 SizedBox 교체
    final genderIcon = model.gender == Gender.female
        ? AppIcon.female(size: AppSize.s12)
        : const SizedBox.shrink();

    final topLine = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$number", style: AppTextStyle.text3),
        if (onSelect != null)
          IconButton(
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => onSelect!(model.schoolNb),
            icon: isSelected
                ? AppIcon.check(size: AppSize.s16)
                : AppIcon.uncheck(size: AppSize.s16),
          ),
      ],
    );

    return Container(
      height: fixedSize.height,
      width: fixedSize.width,
      decoration: BoxDecoration(
        color: AppColors.lightSub4,
        borderRadius: BorderRadius.circular(AppRadius.s12),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Stack(
        children: [
          Align(alignment: Alignment.topLeft, child: topLine),

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
