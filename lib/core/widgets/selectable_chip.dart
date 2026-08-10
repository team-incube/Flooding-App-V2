import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';
import '../theme/text_style/app_text_style.dart';

/// 선택 가능한 칩(미선택: 테두리, 선택: 메인 컬러 채움).
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.borderRadius = AppRadius.s8,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s20,
      vertical: AppSpacing.s8,
    ),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// 마감 등으로 더 이상 고를 수 없는 항목 — sub2 배경으로 채우고 탭이 먹지 않는다.
  final bool disabled;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final background = disabled
        ? AppColors.lightSub2
        : selected
        ? AppColors.lightP1
        : Colors.transparent;
    final textColor = disabled || selected
        ? AppColors.lightBgSurface
        : AppColors.lightSub1;
    final border = disabled || selected
        ? null
        : Border.all(color: AppColors.lightSub2);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        // 탭 시 리플/스플래시 이펙트 제거 — 눌렀을 때 오그라드는 것처럼
        // 보이는 것을 막는다.
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          child: Text(label, style: AppTextStyle.text3.copyWith(color: textColor)),
        ),
      ),
    );
  }
}
