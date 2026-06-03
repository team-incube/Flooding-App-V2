import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flooding_v2/core/widgets/sheet/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_size.dart';
import '../../../constants/app_spacing.dart';
import '../../../theme/color/app_colors.dart';
import '../../../theme/icon/app_icon.dart';
import '../../../theme/text_style/app_text_style.dart';

/// 햄버거 버튼으로 우측에서 열리는 메뉴 사이드 드로어.
class MenuDrawer extends StatefulWidget {
  const MenuDrawer({
    super.key,
    required this.userName,
    required this.studentId,
    this.onProfileEdit,
  });

  final String userName;
  final String studentId;
  final VoidCallback? onProfileEdit;

  static const double _cornerRadius = 20;

  /// 드로어가 차지할 화면 너비 비율(화면의 3/4).
  static const double _widthFactor = 0.75;

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  /// 드로어 로그아웃 → 확인 후 로그아웃.
  Future<void> _confirmLogout() async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '로그아웃',
      message: '정말로 로그아웃 하시겠습니까?',
      confirmLabel: '로그아웃',
    );
    if (!mounted || ok != true) return;
    // Todo: 로그아웃 처리.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('로그아웃되었어요')));
  }

  /// 드로어 회원탈퇴 → 확인 후 탈퇴.
  Future<void> _confirmWithdraw() async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '회원 탈퇴',
      message: '정말로 회원을 탈퇴하시겠습니까?',
      confirmLabel: '탈퇴 하기',
    );
    if (!mounted || ok != true) return;
    // Todo: 회원탈퇴 처리.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('회원탈퇴되었어요')));
  }

  @override
  Widget build(BuildContext context) {
    /// 현재 경로를 불러와 비교
    final location = GoRouterState.of(context).uri.path;

    return Drawer(
      width: MediaQuery.sizeOf(context).width * MenuDrawer._widthFactor,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.lightBgSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MenuDrawer._cornerRadius),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileCard(
                  userName: widget.userName,
                  studentId: widget.studentId,
                  onEdit: widget.onProfileEdit,
                ),
                const SizedBox(height: AppSpacing.s24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _NavItem(
                      icon: AppIcon.navHome,
                      label: '홈',
                      selected: RoutePath.home == location,
                      onTap: () => context.go(RoutePath.home),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    _NavItem(
                      icon: AppIcon.dormitoryOutline,
                      selectedIcon: AppIcon.dormitoryFill,
                      label: '기숙사',
                      selected: RoutePath.dormitory == location,
                      onTap: () => context.go(RoutePath.dormitory),
                    ),
                  ],
                ),
                const Spacer(),
                _BottomItem(
                  icon: AppIcon.logout,
                  label: '로그아웃',
                  onTap: _confirmLogout,
                ),
                _BottomItem(
                  icon: AppIcon.withdraw,
                  label: '회원탈퇴',
                  onTap: _confirmWithdraw,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 프로필 카드: 아바타(편집 뱃지 포함) + 이름 + 학번.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.userName,
    required this.studentId,
    this.onEdit,
  });

  final String userName;
  final String studentId;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProfileAvatar(onEdit: onEdit),
        const SizedBox(width: AppSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '안녕하세요! $userName님',
                style: AppTextStyle.text2.copyWith(
                  color: AppColors.lightMainText,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                studentId,
                style: AppTextStyle.text3.copyWith(color: AppColors.lightSub2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 기본 아바타(원형 실루엣) 위에 편집 뱃지를 겹친 위젯.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.onEdit});

  final VoidCallback? onEdit;

  // 디자인 고정 수치 (52px 아바타 + 우하단 24px 뱃지 오버랩)
  static const double _avatarSize = 52;
  static const double _badgeSize = 24;
  static const double _groupWidth = 60;

  @override
  Widget build(BuildContext context) {
    // 아바타 영역 전체를 탭하면 편집 동작이 실행되도록 한다.
    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _groupWidth,
        height: _avatarSize,
        child: Stack(
          children: [
            AppIcon.avatar(),
            Positioned(
              right: 0,
              bottom: 0,
              child: AppIcon.profileEdit(size: _badgeSize),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상단 네비게이션 항목(좌측 아이콘 + 라벨, 선택 시 배경 강조).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.selected = false,
    this.onTap,
  });

  /// 기본(비선택) 아이콘.
  final AppIconBuilder icon;

  /// 선택 시 사용할 아이콘. 미지정 시 [icon] 을 그대로 쓴다.
  final AppIconBuilder? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.lightP1 : AppColors.lightSub2;
    final iconBuilder = selected ? (selectedIcon ?? icon) : icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            iconBuilder(size: AppSize.s24, color: color),
            const SizedBox(width: AppSpacing.s24),
            Text(label, style: AppTextStyle.text2.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// 하단 항목(중앙 정렬 아이콘 + 라벨).
class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.icon, required this.label, this.onTap});

  final AppIconBuilder icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon(size: AppSize.s24, color: AppColors.lightSub2),
            const SizedBox(width: AppSpacing.s8),
            Text(
              label,
              style: AppTextStyle.text2.copyWith(color: AppColors.lightSub2),
            ),
          ],
        ),
      ),
    );
  }
}
