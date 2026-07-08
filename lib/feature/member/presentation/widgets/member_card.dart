import 'package:flutter/material.dart';

import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/enum/gender.dart';

import '../models/member_model.dart';

typedef MemberSelectAction = void Function(int id, bool isAttended);

class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.model,
    required this.number,
    this.showAttendanceBadge = false,
    this.showMedal = false,
  }) : onSelect = null;

  const MemberCard.button({
    super.key,
    required this.model,
    required this.number,
    required this.onSelect,
    this.showAttendanceBadge = false,
    this.showMedal = false,
  });

  static const Size fixedSize = Size(173, 165);

  final int number;
  final MemberModel model;
  final MemberSelectAction? onSelect;

  /// 출석 완료 배지(체크 아이콘) 노출 여부 — 출석 개념이 없는 기능(안마의자
  /// 등)에서는 false 로 둬 의미 없는 언체크 아이콘이 뜨지 않게 한다.
  final bool showAttendanceBadge;

  /// 1~3등 메달 아이콘 노출 여부 — 등수 개념이 있는 자습 신청에서만 true.
  final bool showMedal;

  @override
  Widget build(BuildContext context) {
    final genderIcon = model.gender == Gender.female
        ? AppIcon.female(size: AppSize.s16)
        : AppIcon.male(size: AppSize.s16);

    final topLine = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$number", style: AppTextStyle.text3),
        // 체크 표시는 선택 여부가 아니라 출석(체크인) 완료 여부를 나타낸다.
        if (showAttendanceBadge)
          model.isAttended
              ? AppIcon.check(size: AppSize.s16)
              : AppIcon.uncheck(size: AppSize.s16),
      ],
    );

    final card = Container(
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

    final medal = showMedal ? _medal(number) : null;
    final cardWithMedal = medal == null
        ? card
        : Stack(
            clipBehavior: Clip.none,
            children: [
              card,
              Positioned(right: 0, bottom: 0, child: medal),
            ],
          );

    final onSelect = this.onSelect;
    if (onSelect == null) return cardWithMedal;

    return GestureDetector(
      onTap: () => onSelect(model.id, model.isAttended),
      behavior: HitTestBehavior.opaque,
      child: cardWithMedal,
    );
  }

  static Widget? _medal(int number) => switch (number) {
    1 => AppIcon.medalGold(width: 56, height: 80),
    2 => AppIcon.medalSilver(width: 56, height: 80),
    3 => AppIcon.medalBronze(width: 56, height: 80),
    _ => null,
  };
}
