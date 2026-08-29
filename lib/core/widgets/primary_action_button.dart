import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';
import '../theme/text_style/app_text_style.dart';

/// 메인 컬러 톤의 액션 버튼.
///
/// [enabled]가 false면 lightP3, true면 lightP1 배경을 사용한다.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.expand = false,
    this.horizontalPadding = AppSpacing.s16,
    this.verticalPadding = AppSpacing.s10,
    this.borderRadius = AppRadius.s6,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool expand;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  /// 배경색을 [enabled] 여부와 무관하게 강제 지정한다. 미지정 시 기존처럼
  /// [enabled]에 따라 lightP1/lightP3 중 하나를 쓴다.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final background =
        backgroundColor ?? (enabled ? AppColors.lightP1 : AppColors.lightP3);

    Widget content = Text(
      label,
      style: AppTextStyle.caption1.copyWith(color: AppColors.lightSub4),
    );
    if (expand) {
      content = Center(child: content);
    }

    final button = Material(
      color: background,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: content,
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
