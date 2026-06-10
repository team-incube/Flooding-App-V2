import 'package:flutter/material.dart';

import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/icon/app_icon.dart';
import 'drawer/menu_drawer.dart';

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

  /// 햄버거 버튼 탭 동작. 미지정 시 [MenuDrawer] 를 연다.
  final VoidCallback? onMenuTap;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar =
        appBar ??
        (showDefaultAppBar ? _FloodingLogoAppBar(onMenuTap: onMenuTap) : null);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.lightBackground,
      appBar: resolvedAppBar,
      body: Padding(padding: const EdgeInsets.all(AppSpacing.s24), child: body),
      // 기본 앱바의 햄버거 버튼으로 여는 공통 메뉴 드로어.
      // TODO: controller에서 접속 중인 유저 정보 불러오기
      endDrawer: const MenuDrawer(userName: '민솔', studentId: '2403'),
      // 드로어가 열리면 뒤 홈 화면이 옅게 비치도록 반투명 흰색 scrim 적용
      // (디자인: BackGroundColor #F7F7F9 50%).
      drawerScrimColor: Colors.transparent,
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
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: AppSpacing.s24,
      title: AppIcon.logo(),
      actions: [
        IconButton(
          onPressed: onMenuTap ?? () => Scaffold.of(context).openEndDrawer(),
          icon: AppIcon.dehaze(color: AppColors.lightMainText),
        ),
        const SizedBox(width: AppSpacing.s16),
      ],
    );
  }
}
