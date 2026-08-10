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
    this.borderRadius = AppRadius.s8,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s20,
      vertical: AppSpacing.s8,
    ),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.lightP1 : Colors.transparent;
    final textColor = selected ? AppColors.lightBgSurface : AppColors.lightSub1;
    final border = selected ? null : Border.all(color: AppColors.lightSub2);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
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
