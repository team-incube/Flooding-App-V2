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
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/card_header.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../auth/presentation/bloc/me_bloc.dart';
import '../../../auth/presentation/bloc/me_state.dart';
import '../../../massage/presentation/widgets/massage_count_card.dart';
import '../../../study/presentation/widgets/study_count_card.dart';
import '../../data/repositories/neis_repository_impl.dart';
import '../../domain/usecases/get_next_period_usecase.dart';

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
  void initState() {
    super.initState();
    // TODO(#50): 서버가 NEIS 응답 예시를 아직 안 줘서, 실제 스키마를 확인하려고
    // 호출 + 로그만 찍어본다. 스키마 확정되면 GetNextPeriodUseCase 로 교체해
    // _ScheduleCard 에 실데이터를 연결한다.
    _debugLogNeisTimetable();
  }

  Future<void> _debugLogNeisTimetable() async {
    final meBloc = context.read<MeBloc>();
    var me = meBloc.state.whenOrNull(loaded: (me) => me);
    if (me == null) {
      // HomeView 진입 시점엔 MeBloc 조회가 아직 안 끝났을 수 있다 — 로드될
      // 때까지 기다린다(디버그 확인용이라 실패 시엔 그냥 무한 대기해도 무방).
      Logger.d('NEIS 확인 대기 — 내 정보(MeBloc) 로딩 중', tag: 'NEIS');
      me = await meBloc.stream
          .map((state) => state.whenOrNull(loaded: (me) => me))
          .firstWhere((me) => me != null);
    }
    try {
      final period = await GetNextPeriodUseCase(NeisRepositoryImpl.create())
          .call(grade: me!.grade, classNumber: me.classNumber);
      Logger.d('NEIS 다음 교시: $period', tag: 'NEIS');
    } catch (e, s) {
      // 원본 응답 스키마는 LoggingInterceptor 의 [API] 로그로 확인한다 —
      // 여기서는 GetNextPeriodUseCase 의 파싱 결과/실패만 남긴다.
      Logger.e('NEIS 시간표 호출 실패', tag: 'NEIS', error: e, stackTrace: s);
    }
  }

  @override
  void dispose() {
    _musicUrlController.dispose();
    super.dispose();
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
            _WakeMusicCard(controller: _musicUrlController, requestedCount: 12),
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
