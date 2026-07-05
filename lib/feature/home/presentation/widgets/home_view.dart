import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/card_header.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../dormitory/presentation/bloc/music_bloc.dart';
import '../../../dormitory/presentation/bloc/music_event.dart';
import '../../../dormitory/presentation/bloc/music_state.dart';
import '../../../massage/presentation/widgets/massage_count_card.dart';
import '../../../study/presentation/widgets/study_count_card.dart';

/// 홈 섹션 본문(시간표·자습신청·안마의자·기상음악 카드).
///
/// [HomePage] 본문에 드로어로 갈아끼워지는 섹션. 기상음악 URL 입력 컨트롤러를
/// 직접 소유해, 호스트 페이지가 상태를 들고 있을 필요 없이 자기완결적으로 동작한다.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _musicUrlController = TextEditingController();

  @override
  void dispose() {
    _musicUrlController.dispose();
    super.dispose();
  }

  /// 입력한 URL 로 기상음악을 신청한다.
  void _onApplyMusic() {
    final url = _musicUrlController.text.trim();
    if (url.isEmpty) return;
    context.read<MusicBloc>().add(MusicEvent.applied(url));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _ScheduleCard(
              period: '3 교시',
              subject: 'SQL활용',
              teacher: '이주원',
            ),
            const SizedBox(height: AppSpacing.s16),
            const StudyCountCard(),
            const SizedBox(height: AppSpacing.s16),
            const MassageCountCard(),
            const SizedBox(height: AppSpacing.s16),
            BlocConsumer<MusicBloc, MusicState>(
              // 신청 결과(성공/실패)를 1회성 스낵바로 안내한다.
              listenWhen: (prev, curr) =>
                  !identical(prev.applyResult, curr.applyResult),
              listener: (context, state) {
                final result = state.applyResult;
                if (result == null) return;
                // 신청 성공 시 입력창을 비운다.
                if (result.success) _musicUrlController.clear();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(result.message)));
              },
              builder: (context, state) => _WakeMusicCard(
                controller: _musicUrlController,
                requestedCount: state.totalCount,
                submitting: state.isSubmitting,
                onApply: _onApplyMusic,
              ),
            ),
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

class _WakeMusicCard extends StatelessWidget {
  const _WakeMusicCard({
    required this.controller,
    required this.requestedCount,
    required this.submitting,
    required this.onApply,
  });

  final TextEditingController controller;
  final int requestedCount;

  /// 신청 요청 처리 중 여부 — true 면 버튼을 비활성화한다.
  final bool submitting;

  /// '신청하기' 탭 콜백.
  final VoidCallback onApply;

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
              const Spacer(flex: 1),
              GestureDetector(
                onTap: () {
                  context.push(RoutePath.songRequestDetail);
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체보기',
                      style: AppTextStyle.caption1.copyWith(
                        color: AppColors.lightHintText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    AppIcon.chevronRight(
                      size: AppSize.s14,
                      color: AppColors.lightSub2,
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
          // URL 이 입력돼야(그리고 처리 중이 아닐 때만) 버튼을 활성화한다.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canApply = value.text.trim().isNotEmpty && !submitting;
              return PrimaryActionButton(
                label: submitting ? '신청 중...' : '신청하기',
                enabled: canApply,
                onPressed: onApply,
                expand: true,
                verticalPadding: AppSpacing.s14,
                horizontalPadding: AppSpacing.s32,
                borderRadius: AppRadius.s8,
              );
            },
          ),
        ],
      ),
    );
  }
}
