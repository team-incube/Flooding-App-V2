import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_font.dart';

/// 햄버거 버튼으로 우측에서 열리는 메뉴 사이드 드로어.
///
/// 프로필 영역(아바타·이름·학번), 네비게이션 항목(홈/기숙사),
/// 하단 항목(로그아웃/회원탈퇴)으로 구성된다. 표시 데이터와 동작은
/// 외부에서 주입하며, 디자인 고정 수치는 본문 상수로 둔다.
class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    super.key,
    required this.userName,
    required this.studentId,
    this.onProfileEdit,
    this.onHomeTap,
    this.onDormitoryTap,
    this.onLogout,
    this.onWithdraw,
  });

  /// 인사말에 표시할 사용자 이름.
  final String userName;

  /// 프로필에 표시할 학번.
  final String studentId;

  final VoidCallback? onProfileEdit;
  final VoidCallback? onHomeTap;
  final VoidCallback? onDormitoryTap;
  final VoidCallback? onLogout;
  final VoidCallback? onWithdraw;

  // 디자인 고정 수치 (Figma node 3287-16554)
  static const double _width = 301;
  static const double _cornerRadius = 20;
  static const double _verticalPadding = 40;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: _width,
      backgroundColor: AppColors.lightBgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(_cornerRadius),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileCard(
                userName: userName,
                studentId: studentId,
                onEdit: onProfileEdit,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: Column(
                  children: [
                    _NavItem(
                      iconPath: AppIcon.navHome,
                      label: '홈',
                      selected: true,
                      onTap: onHomeTap,
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    _NavItem(
                      iconPath: AppIcon.navDormitory,
                      label: '기숙사',
                      onTap: onDormitoryTap,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _BottomItem(
                iconPath: AppIcon.logout,
                label: '로그아웃',
                onTap: onLogout,
              ),
              _BottomItem(
                iconPath: AppIcon.withdraw,
                label: '회원탈퇴',
                onTap: onWithdraw,
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(AppRadius.s16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12)],
      ),
      child: Row(
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
                  style: AppFont.text2.copyWith(color: AppColors.lightMainText),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  studentId,
                  style: AppFont.text3.copyWith(color: AppColors.lightSub2),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return SizedBox(
      width: _groupWidth,
      height: _avatarSize,
      child: Stack(
        children: [
          Container(
            width: _avatarSize,
            height: _avatarSize,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.lightSub3,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 5.07,
                  top: 31.71,
                  child: SvgPicture.asset(
                    AppIcon.avatarBody,
                    width: 36.78,
                    height: 21.56,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: 14.58,
                  top: 11.41,
                  child: SvgPicture.asset(
                    AppIcon.avatarHead,
                    width: 17.76,
                    height: 17.76,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: AppIcon.asset(AppIcon.profileEdit, size: _badgeSize),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상단 네비게이션 항목(좌측 아이콘 + 라벨, 선택 시 배경 강조).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconPath,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String iconPath;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.lightP1 : AppColors.lightSub2;

    return Material(
      color: selected ? AppColors.lightP2 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.s8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              AppIcon.asset(iconPath, size: AppSize.s24, color: color),
              const SizedBox(width: AppSpacing.s24),
              Text(label, style: AppFont.text2.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하단 항목(중앙 정렬 아이콘 + 라벨).
class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.iconPath, required this.label, this.onTap});

  final String iconPath;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon.asset(
              iconPath,
              size: AppSize.s24,
              color: AppColors.lightSub2,
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              label,
              style: AppFont.text2.copyWith(color: AppColors.lightSub2),
            ),
          ],
        ),
      ),
    );
  }
}
