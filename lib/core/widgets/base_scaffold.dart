import 'package:flutter/material.dart';

import '../constants/app_size.dart';
import '../constants/app_spcing.dart';
import '../theme/color/app_colors.dart';
import '../theme/icon/app_icon.dart';

/// 앱 전반에서 사용하는 기본 Scaffold.
///
/// 기본 [AppBar]는 좌측 `flooding` 로고와 우측 햄버거 버튼으로 구성되어 있으며,
/// 페이지에서 자체 AppBar가 필요한 경우 [appBar]를 지정하여 대체할 수 있다.
class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.showDefaultAppBar = true,
    this.onMenuTap,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showDefaultAppBar;
  final VoidCallback? onMenuTap;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = appBar ??
        (showDefaultAppBar
            ? _FloodingLogoAppBar(onMenuTap: onMenuTap)
            : null);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.lightBackground,
      appBar: resolvedAppBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class _FloodingLogoAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _FloodingLogoAppBar({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(AppSize.s57);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppSpacing.s24,
      title: AppIcon.asset(AppIcon.logo, size: AppSize.s24),
      actions: [
        IconButton(
          onPressed: onMenuTap,
          icon: AppIcon.asset(
            AppIcon.dehaze,
            color: AppColors.lightMainText,
          ),
        ),
        const SizedBox(width: AppSpacing.s16),
      ],
    );
  }
}
