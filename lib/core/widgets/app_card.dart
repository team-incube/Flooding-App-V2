import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';

/// 라운드 + 그림자가 적용된 공통 카드 컨테이너.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s16,
          ),
      decoration: BoxDecoration(
        color: AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.s12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: AppSpacing.s12,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}
