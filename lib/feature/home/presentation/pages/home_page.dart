import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spcing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/textStyle/app_font.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../widgets/card_header.dart';
import '../widgets/home_floating_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _musicUrlController = TextEditingController();

  @override
  void dispose() {
    _musicUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(
          right: AppSpacing.s8,
          bottom: AppSpacing.s24,
        ),
        child: HomeFloatingActions(),
      ),
      body: SafeArea(
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
              const _RequestCountCard(
                iconPath: AppIcon.book,
                title: '자습신청',
                current: 4,
                total: 50,
              ),
              const SizedBox(height: AppSpacing.s16),
              const _RequestCountCard(
                iconPath: AppIcon.chair,
                title: '안마의자 신청',
                current: 4,
                total: 5,
              ),
              const SizedBox(height: AppSpacing.s16),
              _WakeMusicCard(
                controller: _musicUrlController,
                requestedCount: 12,
              ),
            ],
          ),
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
          const CardHeader(iconPath: AppIcon.calendar, title: '시간표'),
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
                  style: AppFont.text2.copyWith(color: AppColors.lightSub1),
                ),
                const Spacer(),
                Text(
                  subject,
                  style: AppFont.text3.copyWith(color: AppColors.lightSub1),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  teacher,
                  style:
                      AppFont.caption1.copyWith(color: AppColors.lightSub2),
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
    required this.iconPath,
    required this.title,
    required this.current,
    required this.total,
  });

  final String iconPath;
  final String title;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardHeader(iconPath: iconPath, title: title),
              const SizedBox(width: AppSpacing.s6),
              AppIcon.asset(AppIcon.warning, size: AppSize.s18),
              const Spacer(),
              const _SeeAllLink(),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Center(
            child: Text(
              '$current/$total',
              style: AppFont.title1.copyWith(color: AppColors.lightMainText),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppProgressBar(current: current, total: total),
          const SizedBox(height: AppSpacing.s8),
          const Align(
            alignment: Alignment.centerRight,
            child: PrimaryActionButton(label: '신청 불가', enabled: false),
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
              const CardHeader(iconPath: AppIcon.speaker, title: '기상음악 신청'),
              const SizedBox(width: AppSpacing.s6),
              Text(
                '신청 음악',
                style: AppFont.caption1.copyWith(color: AppColors.lightSub1),
              ),
              const SizedBox(width: AppSpacing.s4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$requestedCount',
                      style: AppFont.caption1
                          .copyWith(color: AppColors.lightP1),
                    ),
                    TextSpan(
                      text: '개',
                      style: AppFont.caption1
                          .copyWith(color: AppColors.lightSub1),
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
              style: AppFont.text3.copyWith(color: AppColors.lightMainText),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'URL을 입력해주세요',
                hintStyle:
                    AppFont.text3.copyWith(color: AppColors.lightSub2),
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
  const _SeeAllLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '전체보기',
          style: AppFont.caption1.copyWith(color: AppColors.lightSub2),
        ),
        const SizedBox(width: AppSpacing.s4),
        AppIcon.asset(
          AppIcon.chevronRight,
          size: AppSize.s14,
          color: AppColors.lightSub2,
        ),
      ],
    );
  }
}

