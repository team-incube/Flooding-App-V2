import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';

/// 우측 하단에 세로로 쌓인 두 개의 원형 액션 버튼.
class HomeFloatingActions extends StatelessWidget {
  const HomeFloatingActions({super.key, this.onAiTap, this.onChatTap});

  final VoidCallback? onAiTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleAction(onTap: onAiTap, iconPath: AppIcon.sparkle),
        const SizedBox(height: AppSpacing.s12),
        _CircleAction(onTap: onChatTap, iconPath: AppIcon.chatBot),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.iconPath, this.onTap});

  final String iconPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightBgSurface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: AppSize.s60,
          height: AppSize.s60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightBgSurface,
          ),
          child: Align(
            alignment: Alignment.center,
            child: AppIcon.asset(iconPath, size: 39),
          ),
        ),
      ),
    );
  }
}
