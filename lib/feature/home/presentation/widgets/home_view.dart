import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/card_header.dart';
import '../../../massage/presentation/widgets/massage_count_card.dart';
import '../../../song/presentation/widgets/wake_music_card.dart';
import '../../../study/presentation/widgets/study_count_card.dart';
import '../../domain/usecases/get_next_period_usecase.dart';
import '../bloc/timetable_bloc.dart';
import '../bloc/timetable_state.dart';

/// 홈 섹션 본문(시간표·자습신청·안마의자·기상음악 카드).
///
/// [HomePage] 본문에 드로어로 갈아끼워지는 섹션. 기상음악 URL 입력 컨트롤러를
/// 직접 소유해, 호스트 페이지가 상태를 들고 있을 필요 없이 자기완결적으로 동작한다.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<TimetableBloc, TimetableState>(
              builder: (context, state) => _ScheduleCard(state: state),
            ),
            SizedBox(height: AppSpacing.s16),
            const StudyCountCard(),
            SizedBox(height: AppSpacing.s16),
            const MassageCountCard(),
            SizedBox(height: AppSpacing.s16),
            const WakeMusicCard(),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.state});

  final TimetableState state;

  @override
  Widget build(BuildContext context) {
    final period = state.period;
    final (
      String periodLabel,
      String subject,
      String? teacher,
    ) = switch (state.scheduleStatus) {
      ScheduleStatus.initial ||
      ScheduleStatus.loading => ('', '불러오는 중...', null),
      ScheduleStatus.error => (
        '',
        state.scheduleError ?? '시간표를 불러오지 못했어요.',
        null,
      ),
      ScheduleStatus.loaded => switch (state.periodStatus) {
        NextPeriodStatus.found when period != null => (
          '${period.period} 교시',
          period.subject,
          // 담당 교사 미배정 시 NEIS 응답에 teacher 가 없을 수 있다.
          period.teacher,
        ),
        NextPeriodStatus.dayOver => ('', '오늘 일과가 끝났어요', null),
        _ => ('', '오늘 예정된 수업이 없어요', null),
      },
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(icon: AppIcon.calendar, title: '시간표'),
          SizedBox(height: AppSpacing.s8),
          Container(
            padding: EdgeInsets.symmetric(
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
                  periodLabel,
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
                if (teacher != null) ...[
                  SizedBox(width: AppSpacing.s4),
                  Text(
                    teacher,
                    style: AppTextStyle.caption1.copyWith(
                      color: AppColors.lightSub2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
