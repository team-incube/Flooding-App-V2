import 'package:flooding_v2/feature/song/presentation/bloc/music_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/route/route_path.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/card_header.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';

class WakeMusicCard extends StatefulWidget {
  const WakeMusicCard({super.key});

  @override
  State<WakeMusicCard> createState() => _WakeMusicCardState();
}

class _WakeMusicCardState extends State<WakeMusicCard> {
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
    return BlocConsumer<MusicBloc, MusicState>(
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
      builder: (context, state) {
        return AppCard(
          borderRadius: AppRadius.s16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CardHeader(icon: AppIcon.speaker, title: '기상음악 신청'),
                  SizedBox(width: AppSpacing.s6),
                  Text(
                    '신청 음악',
                    style: AppTextStyle.caption1.copyWith(
                      color: AppColors.lightSub1,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${state.totalCount}',
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
                        SizedBox(width: AppSpacing.s4),
                        AppIcon.chevronRight(
                          size: AppSize.s14,
                          color: AppColors.lightSub2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s8),
              Container(
                height: AppSize.s52,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.s8),
                  border: Border.all(color: AppColors.lightSub2),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _musicUrlController,
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
              SizedBox(height: AppSpacing.s8),
              // URL 이 입력돼야(그리고 처리 중이 아닐 때만) 버튼을 활성화한다.
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _musicUrlController,
                builder: (context, value, _) {
                  final canApply =
                      value.text.trim().isNotEmpty && !state.isSubmitting;
                  return PrimaryActionButton(
                    label: state.isSubmitting ? '신청 중...' : '신청하기',
                    enabled: canApply,
                    onPressed: _onApplyMusic,
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
      },
    );
  }
}
