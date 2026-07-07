import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/sheet/sheet.dart';
import '../../domain/repositories/ai_repository.dart';
import '../bloc/ai_song_bloc.dart';
import '../bloc/ai_song_event.dart';
import '../bloc/ai_song_state.dart';
import '../models/song_recommendation.dart';

/// 추천 곡을 받아 하나를 골라 신청하는 팝업.
///
/// 열리면 [AiSongBloc] 이 추천을 불러온다(로딩 → 목록/오류). 카드를 눌러 곡을
/// 선택하고, 선택 전에는 '신청'이 비활성 상태다. '신청'으로 선택한
/// [SongRecommendation]을 반환한다.
class SongRecommendationSheet extends StatelessWidget {
  const SongRecommendationSheet({super.key});

  // 리스트 영역의 최대 높이(디자인 기준).
  static const double _listMaxHeight = 376;

  // 로딩·오류 표시 영역의 고정 높이(팝업 크기가 급변하지 않도록).
  static const double _statusHeight = 200;

  /// 노래 추천 팝업을 띄우고 신청한 곡을 반환한다.
  ///
  /// 팝업 수명 동안만 사는 [AiSongBloc] 을 [repository] 로 만들어 주입하고,
  /// 열리자마자 추천을 요청한다. 뒤로가기·바깥 탭으로 닫으면 null을 반환한다.
  static Future<SongRecommendation?> show(
    BuildContext context, {
    required AiRepository repository,
  }) {
    return showAppFormDialog<SongRecommendation>(
      context,
      builder: (_) => BlocProvider(
        create: (_) =>
            AiSongBloc(repository: repository)
              ..add(const AiSongEvent.requested()),
        child: const SongRecommendationSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiSongBloc, AiSongState>(
      builder: (context, state) {
        final selected = state.selectedIndex;
        final canConfirm =
            state.status == AiSongStatus.loaded &&
            selected != null &&
            selected < state.songs.length;
        return AppFormSheet(
          header: const _Header(),
          body: _buildBody(context, state),
          confirmLabel: '신청',
          onConfirm: canConfirm
              ? () => Navigator.of(context).pop(state.songs[selected])
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AiSongState state) {
    switch (state.status) {
      case AiSongStatus.initial:
      case AiSongStatus.loading:
        return const SizedBox(
          height: _statusHeight,
          child: Center(child: CircularProgressIndicator()),
        );
      case AiSongStatus.error:
        return SizedBox(
          height: _statusHeight,
          child: _ErrorView(
            message: state.error ?? '노래 추천을 불러오지 못했어요.',
            onRetry: () =>
                context.read<AiSongBloc>().add(const AiSongEvent.requested()),
          ),
        );
      case AiSongStatus.loaded:
        if (state.songs.isEmpty) {
          return const SizedBox(
            height: _statusHeight,
            child: Center(child: Text('추천할 곡을 찾지 못했어요.')),
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _listMaxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: state.songs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s24),
            itemBuilder: (context, index) => _SongCard(
              song: state.songs[index],
              selected: state.selectedIndex == index,
              onTap: () => context.read<AiSongBloc>().add(
                AiSongEvent.songSelected(index),
              ),
            ),
          ),
        );
    }
  }
}

/// 추천 로딩 실패 시 안내 + '다시 시도'.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.text3.copyWith(color: AppColors.lightSub1),
          ),
          const SizedBox(height: AppSpacing.s12),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: Text(
              '다시 시도',
              style: AppTextStyle.text3.copyWith(color: AppColors.lightP1),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✨ 아이콘 + 제목 + 안내 부제로 구성된 헤더.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon.sparkle(color: AppColors.lightSub2),
            const SizedBox(width: AppSpacing.s4),
            Text(
              '오늘의 노래 추천',
              style: AppTextStyle.title3.copyWith(
                color: AppColors.lightMainText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          '※ 이전에 신청한 곡을 기반으로 노래를 추천해요',
          style: AppTextStyle.caption1.copyWith(color: AppColors.lightSub2),
        ),
      ],
    );
  }
}

/// 추천 곡 카드(썸네일 + 제목, 선택 시 메인 컬러 테두리).
class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.song,
    required this.selected,
    required this.onTap,
  });

  final SongRecommendation song;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(song: song, selected: selected),
          const SizedBox(height: AppSpacing.s10),
          Text(
            song.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.text3.copyWith(color: AppColors.lightMainText),
          ),
        ],
      ),
    );
  }
}

/// 16:9 썸네일(영상 길이 배지·선택 표시 포함).
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.song, required this.selected});

  final SongRecommendation song;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.s4);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightSub3,
          borderRadius: radius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (song.thumbnail != null)
              Image(image: song.thumbnail!, fit: BoxFit.cover),
            if (song.duration != null)
              Positioned(
                right: AppSpacing.s8,
                bottom: AppSpacing.s8,
                child: _DurationBadge(text: song.duration!),
              ),
            Positioned(
              right: AppSpacing.s8,
              top: AppSpacing.s8,
              child: selected ? AppIcon.check() : AppIcon.uncheck(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 영상 길이 배지(어두운 반투명 배경).
class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMainText.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.s4),
      ),
      child: Text(
        text,
        style: AppTextStyle.caption3.copyWith(color: AppColors.lightSub4),
      ),
    );
  }
}
