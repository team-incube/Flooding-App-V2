import 'dart:io';

import 'package:flooding_v2/core/enum/role.dart';
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
    required this.name,
    required this.studentNumber,
    this.profileImageUrl,
    this.onProfileEdit,
    this.onLogout,
    this.onWithdraw,
  });

  final String name;
  final int studentNumber;

  /// 등록된 프로필 사진 URL. null/빈 값이면 기본 아바타를 표시한다.
  final String? profileImageUrl;
  final VoidCallback? onProfileEdit;

  /// 로그아웃 확인 후 실행할 동작. 미지정 시 로그아웃 항목은 동작하지 않는다.
  final Future<void> Function()? onLogout;
  final Future<void> Function()? onWithdraw;

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
    await widget.onLogout?.call();
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
    await widget.onWithdraw?.call();
    if (!mounted) return;
    //TODO : 회원 탈퇴 처리
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
                  name: widget.name,
                  studentNumber: widget.studentNumber,
                  profileImageUrl: widget.profileImageUrl,
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
    required this.name,
    required this.studentNumber,
    this.profileImageUrl,
    this.onEdit,
  });

  final String name;
  final int studentNumber;
  final String? profileImageUrl;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isDormManager = context.role == Role.dormitoryManager;

    return Row(
      children: [
        _ProfileAvatar(profileImageUrl: profileImageUrl, onEdit: onEdit),
        const SizedBox(width: AppSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '안녕하세요! $name님',
                style: AppTextStyle.text2.copyWith(
                  color: AppColors.lightMainText,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                spacing: AppSpacing.s4,
                children: [
                  Text(
                    '$studentNumber'.padLeft(4, '0'),
                    style: AppTextStyle.text3.copyWith(
                      color: AppColors.lightSub2,
                    ),
                  ),
                  if (isDormManager)
                    Text(
                      '관리자',
                      style: AppTextStyle.text3.copyWith(
                        color: AppColors.negative,
                      ),
                    ),
                ],
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
  const _ProfileAvatar({this.profileImageUrl, this.onEdit});

  final String? profileImageUrl;
  final VoidCallback? onEdit;

  // 디자인 고정 수치 (52px 아바타 + 우하단 24px 뱃지 오버랩)
  static const double _avatarSize = 52;
  static const double _badgeSize = 24;
  static const double _groupWidth = 60;

  @override
  Widget build(BuildContext context) {
    final url = profileImageUrl;
    // 서버 URL(http…) 은 네트워크에서, 낙관적 갱신으로 들어온 로컬 경로는
    // 파일에서 읽는다. 없거나 로드 실패 시 기본 아바타.
    final avatar = (url == null || url.isEmpty)
        ? AppIcon.avatar()
        : ClipOval(
            child: Image(
              image: url.startsWith('http')
                  ? NetworkImage(url)
                  : FileImage(File(url)) as ImageProvider,
              width: _avatarSize,
              height: _avatarSize,
              fit: BoxFit.cover,
              // 로드 중에는 기본 아바타를 보여줘 빈 화면을 막는다.
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : AppIcon.avatar(),
              errorBuilder: (_, _, _) => AppIcon.avatar(),
            ),
          );

    // 아바타 영역 전체를 탭하면 편집 동작이 실행되도록 한다.
    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _groupWidth,
        height: _avatarSize,
        child: Stack(
          children: [
            avatar,
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
