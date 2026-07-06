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
  }) : onSelect = null,
       isSelected = false,
       enabled = true;

  const MemberCard.button({
    super.key,
    required this.model,
    required this.number,
    required this.onSelect,
    required this.isSelected,
    this.enabled = true,
    this.showAttendanceBadge = false,
  });

  static const Size fixedSize = Size(173, 165);

  final int number;
  final MemberModel model;

  /// 체크인/체크아웃 대상으로 선택됐는지 — 테두리·그림자로 강조 표시한다.
  final bool isSelected;

  /// false 면 다른 출석 상태가 이미 선택 중이라는 뜻(혼합 선택 방지) — 흐리게
  /// 표시하고 탭을 막는다.
  final bool enabled;
  final MemberSelectAction? onSelect;

  /// 출석 완료 배지(체크 아이콘) 노출 여부 — 출석 개념이 없는 기능(안마의자
  /// 등)에서는 false 로 둬 의미 없는 언체크 아이콘이 뜨지 않게 한다.
  final bool showAttendanceBadge;

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
        border: Border.all(
          color: isSelected ? AppColors.lightP1 : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.lightP1.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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

    final onSelect = this.onSelect;
    if (onSelect == null) return card;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? () => onSelect(model.id, model.isAttended) : null,
        behavior: HitTestBehavior.opaque,
        child: card,
      ),
    );
  }
}
