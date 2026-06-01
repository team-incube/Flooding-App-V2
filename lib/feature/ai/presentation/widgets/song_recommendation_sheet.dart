import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/sheet/sheet.dart';

/// 추천 곡 한 개.
class SongRecommendation {
  const SongRecommendation({
    required this.title,
    this.thumbnail,
    this.duration,
  });

  final String title;

  /// 곡 썸네일. null이면 회색 플레이스홀더를 보여준다.
  final ImageProvider? thumbnail;

  /// 영상 길이 표기(예: '3:08'). null이면 표시하지 않는다.
  final String? duration;
}

/// 추천된 곡 목록에서 하나를 골라 신청하는 팝업.
///
/// 카드를 눌러 곡을 선택하고, 선택 전에는 '신청'이 비활성 상태다.
/// '신청'으로 선택한 [SongRecommendation]을 반환한다.
class SongRecommendationSheet extends StatefulWidget {
  const SongRecommendationSheet({super.key, required this.songs});

  final List<SongRecommendation> songs;

  /// 노래 추천 팝업을 띄우고 신청한 곡을 반환한다.
  /// 뒤로가기·바깥 탭으로 닫으면 null을 반환한다.
  static Future<SongRecommendation?> show(
    BuildContext context, {
    required List<SongRecommendation> songs,
  }) {
    return showAppFormDialog<SongRecommendation>(
      context,
      builder: (_) => SongRecommendationSheet(songs: songs),
    );
  }

  @override
  State<SongRecommendationSheet> createState() =>
      _SongRecommendationSheetState();
}

class _SongRecommendationSheetState extends State<SongRecommendationSheet> {
  // 리스트 영역의 최대 높이(디자인 기준).
  static const double _listMaxHeight = 376;

  int? _selected;

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      header: const _Header(),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _listMaxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.songs.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s24),
          itemBuilder: (context, index) => _SongCard(
            song: widget.songs[index],
            selected: _selected == index,
            onTap: () =>
                setState(() => _selected = _selected == index ? null : index),
          ),
        ),
      ),
      confirmLabel: '신청',
      onConfirm: _selected == null
          ? null
          : () => Navigator.of(context).pop(widget.songs[_selected!]),
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
