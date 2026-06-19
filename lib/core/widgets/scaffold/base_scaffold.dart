import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feature/auth/presentation/bloc/me_bloc.dart';
import '../../../feature/auth/presentation/bloc/me_state.dart';
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
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
    this.appBar,
    this.showDefaultAppBar = true,
    this.onMenuTap,
    this.onLogout,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  final Widget body;
  final EdgeInsets padding;
  final PreferredSizeWidget? appBar;
  final bool showDefaultAppBar;

  /// 햄버거 버튼 탭 동작. 미지정 시 [MenuDrawer] 를 연다.
  final VoidCallback? onMenuTap;

  /// 메뉴 드로어의 로그아웃 동작.
  final Future<void> Function()? onLogout;

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
      body: Padding(padding: padding, child: body),
      // 기본 앱바의 햄버거 버튼으로 여는 공통 메뉴 드로어.
      endDrawer: BlocBuilder<MeBloc, MeState>(
        builder: (context, state) {
          String drawerName = '익명';
          int studentNumber = 0;

          state.whenOrNull(
            loaded: (me) {
              drawerName = me.name;
              studentNumber = me.studentNumber;
            },
          );

          return MenuDrawer(
            name: drawerName,
            studentNumber: studentNumber,
            onLogout: onLogout,
          );
        },
      ),
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
    // body 와 동일하게 좌우 24 패딩을 적용한다. 로고는 titleSpacing 을 0 으로 두어
    // 패딩 끝(24)에서 시작하고, 햄버거 아이콘은 우측 정렬해 글리프가 정확히 24 에
    // 맞도록 한다(탭 영역은 기본 크기 유지).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        title: AppIcon.logo(),
        actions: [
          IconButton(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.zero,
            // 탭 시 리플/스플래시 이펙트 제거.
            style: IconButton.styleFrom(
              overlayColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: onMenuTap ?? () => Scaffold.of(context).openEndDrawer(),
            icon: AppIcon.dehaze(color: AppColors.lightMainText),
          ),
        ],
      ),
    );
  }
}
