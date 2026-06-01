import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../../core/widgets/sheet/sheet.dart';
import '../../../dormitory/presentation/widgets/dormitory_view.dart';
import '../../../ai/presentation/widgets/song_recommendation_sheet.dart';
import '../widgets/card_header.dart';
import '../widgets/home_floating_actions.dart';
import '../widgets/menu_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userName = '민솔', this.studentId = '2403'});

  /// 메뉴 드로어 인사말에 표시할 사용자 이름.
  final String userName;

  /// 메뉴 드로어에 표시할 학번.
  final String studentId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _musicUrlController = TextEditingController();

  /// 현재 본문에 표시 중인 섹션. 드로어에서 전환하며 페이지 이동 없이
  /// 같은 화면(앱바·드로어 유지)에서 본문만 교체한다.
  MenuDestination _section = MenuDestination.home;

  @override
  void dispose() {
    _musicUrlController.dispose();
    super.dispose();
  }

  /// 본문 섹션을 [section] 으로 교체한다. 드로어는 열린 채로 두고
  /// 뒤 본문만 바뀐다.
  void _selectSection(MenuDestination section) {
    if (_section == section) return;
    setState(() => _section = section);
  }

  /// 플로팅 AI 버튼 → 오늘의 노래 추천 팝업.
  Future<void> _openSongRecommendation() async {
    // Todo: 추천 곡 목록을 서버에서 받아오도록 교체.
    const songs = [
      SongRecommendation(
        title: 'Numb (Official Music Video) [4K UPGRADE] – Linkin Park',
        duration: '3:08',
      ),
      SongRecommendation(title: 'Viva La Vida – Coldplay', duration: '4:02'),
      SongRecommendation(title: 'Bohemian Rhapsody – Queen', duration: '5:55'),
    ];
    final song = await SongRecommendationSheet.show(context, songs: songs);
    if (!mounted || song == null) return;
    // Todo: 선택한 곡 신청 API 연동.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('신청: ${song.title}')));
  }

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
    return BaseScaffold(
      endDrawer: MenuDrawer(
        userName: widget.userName,
        studentId: widget.studentId,
        selected: _section,
        onProfileEdit: () {
          // Todo: 프로필 편집 기능 구현
        },
        onHomeTap: () => _selectSection(MenuDestination.home),
        onDormitoryTap: () => _selectSection(MenuDestination.dormitory),
        onLogout: _confirmLogout,
        onWithdraw: _confirmWithdraw,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          right: AppSpacing.s8,
          bottom: AppSpacing.s24,
        ),
        child: HomeFloatingActions(
          onAiTap: _openSongRecommendation,
          onChatTap: () {
            // Todo: 챗봇 기능 구현
          },
        ),
      ),
      body: switch (_section) {
        MenuDestination.home => _HomeBody(
          musicUrlController: _musicUrlController,
        ),
        MenuDestination.dormitory => const DormitoryView(),
      },
    );
  }
}

/// 홈 섹션 본문(시간표·자습신청·안마의자·기상음악 카드).
class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.musicUrlController});

  final TextEditingController musicUrlController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          0,
          AppSpacing.s24,
          AppSpacing.s24,
        ),
        child: Column(
          children: [
            const _ScheduleCard(
              period: '3 교시',
              subject: 'SQL활용',
              teacher: '이주원',
            ),
            const SizedBox(height: AppSpacing.s16),
            _RequestCountCard(
              icon: AppIcon.book,
              title: '자습신청',
              current: 4,
              total: 50,
              onWarningPressed: () {
                // Todo: 자습신청 안내 기능 구현
              },
              onSeeAllPressed: () {
                // Todo: 자습신청 전체보기 기능 구현
              },
              onActionPressed: () {
                // Todo: 자습신청 기능 구현
              },
            ),
            const SizedBox(height: AppSpacing.s16),
            _RequestCountCard(
              icon: AppIcon.chair,
              title: '안마의자 신청',
              current: 4,
              total: 5,
              onWarningPressed: () {
                // Todo: 안마의자 신청 안내 기능 구현
              },
              onSeeAllPressed: () {
                // Todo: 안마의자 신청 전체보기 기능 구현
              },
              onActionPressed: () {
                // Todo: 안마의자 신청 기능 구현
              },
            ),
            const SizedBox(height: AppSpacing.s16),
            _WakeMusicCard(controller: musicUrlController, requestedCount: 12),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.period,
    required this.subject,
    required this.teacher,
  });

  final String period;
  final String subject;
  final String teacher;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(icon: AppIcon.calendar, title: '시간표'),
          const SizedBox(height: AppSpacing.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s16,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightSub4,
              borderRadius: BorderRadius.circular(AppRadius.s8),
              border: Border.all(color: AppColors.lightP1),
            ),
            child: Row(
              children: [
                Text(
                  period,
                  style: AppTextStyle.text2.copyWith(
                    color: AppColors.lightSub1,
                  ),
                ),
                const Spacer(),
                Text(
                  subject,
                  style: AppTextStyle.text3.copyWith(
                    color: AppColors.lightSub1,
                  ),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  teacher,
                  style: AppTextStyle.caption1.copyWith(
                    color: AppColors.lightSub2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCountCard extends StatelessWidget {
  const _RequestCountCard({
    required this.icon,
    required this.title,
    required this.current,
    required this.total,
    required this.onWarningPressed,
    required this.onSeeAllPressed,
    required this.onActionPressed,
  });

  final AppIconBuilder icon;
  final String title;
  final int current;
  final int total;
  final VoidCallback onWarningPressed;
  final VoidCallback onSeeAllPressed;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardHeader(icon: icon, title: title),
              const SizedBox(width: AppSpacing.s6),
              IconButton(
                onPressed: onWarningPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: AppSize.s18,
                icon: AppIcon.warning(size: AppSize.s18),
              ),
              const Spacer(),
              _SeeAllLink(onPressed: onSeeAllPressed),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Center(
            child: Text(
              '$current/$total',
              style: AppTextStyle.title1.copyWith(
                color: AppColors.lightMainText,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppProgressBar(current: current, total: total),
          const SizedBox(height: AppSpacing.s8),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryActionButton(
              label: '신청 불가',
              enabled: false,
              onPressed: onActionPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _WakeMusicCard extends StatelessWidget {
  const _WakeMusicCard({
    required this.controller,
    required this.requestedCount,
  });

  final TextEditingController controller;
  final int requestedCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: AppRadius.s16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CardHeader(icon: AppIcon.speaker, title: '기상음악 신청'),
              const SizedBox(width: AppSpacing.s6),
              Text(
                '신청 음악',
                style: AppTextStyle.caption1.copyWith(
                  color: AppColors.lightSub1,
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$requestedCount',
                      style: AppTextStyle.caption1.copyWith(
                        color: AppColors.lightP1,
                      ),
                    ),
                    TextSpan(
                      text: '개',
                      style: AppTextStyle.caption1.copyWith(
                        color: AppColors.lightSub1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Container(
            height: AppSize.s52,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.lightBgSurface,
              borderRadius: BorderRadius.circular(AppRadius.s8),
              border: Border.all(color: AppColors.lightSub2),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              style: AppTextStyle.text3.copyWith(
                color: AppColors.lightMainText,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'URL을 입력해주세요',
                hintStyle: AppTextStyle.text3.copyWith(
                  color: AppColors.lightSub2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          const PrimaryActionButton(
            label: '신청하기',
            enabled: false,
            expand: true,
            verticalPadding: AppSpacing.s14,
            horizontalPadding: AppSpacing.s32,
            borderRadius: AppRadius.s8,
          ),
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '전체보기',
          style: AppTextStyle.caption1.copyWith(color: AppColors.lightSub2),
        ),
        const SizedBox(width: AppSpacing.s4),
        IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: AppSize.s14,
          icon: AppIcon.chevronRight(
            size: AppSize.s14,
            color: AppColors.lightSub2,
          ),
        ),
      ],
    );
  }
}
