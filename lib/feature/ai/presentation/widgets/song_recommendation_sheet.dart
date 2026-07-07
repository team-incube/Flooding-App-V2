import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/api_exception.dart';
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

/// 추천 곡을 받아 하나를 골라 신청하는 팝업.
///
/// 팝업이 열리면 [loadSongs]로 추천을 불러온다(로딩 → 목록/오류). 카드를 눌러
/// 곡을 선택하고, 선택 전에는 '신청'이 비활성 상태다. '신청'으로 선택한
/// [SongRecommendation]을 반환한다.
class SongRecommendationSheet extends StatefulWidget {
  const SongRecommendationSheet({super.key, required this.loadSongs});

  /// 추천 곡 목록을 비동기로 불러오는 콜백. 실패 시 예외를 던지면 오류 상태로
  /// 표시하고 '다시 시도'를 제공한다.
  final Future<List<SongRecommendation>> Function() loadSongs;

  /// 노래 추천 팝업을 띄우고 신청한 곡을 반환한다.
  /// 뒤로가기·바깥 탭으로 닫으면 null을 반환한다.
  static Future<SongRecommendation?> show(
    BuildContext context, {
    required Future<List<SongRecommendation>> Function() loadSongs,
  }) {
    return showAppFormDialog<SongRecommendation>(
      context,
      builder: (_) => SongRecommendationSheet(loadSongs: loadSongs),
    );
  }

  @override
  State<SongRecommendationSheet> createState() =>
      _SongRecommendationSheetState();
}

/// 추천 로딩 진행 상태.
enum _RecommendStatus { loading, loaded, error }

class _SongRecommendationSheetState extends State<SongRecommendationSheet> {
  // 리스트 영역의 최대 높이(디자인 기준).
  static const double _listMaxHeight = 376;

  // 로딩·오류 표시 영역의 고정 높이(팝업 크기가 급변하지 않도록).
  static const double _statusHeight = 200;

  _RecommendStatus _status = _RecommendStatus.loading;
  List<SongRecommendation> _songs = const [];
  String? _error;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _status = _RecommendStatus.loading;
      _error = null;
      _selected = null;
    });
    try {
      final songs = await widget.loadSongs();
      if (!mounted) return;
      setState(() {
        _songs = songs;
        _status = _RecommendStatus.loaded;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _status = _RecommendStatus.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '노래 추천을 불러오지 못했어요.';
        _status = _RecommendStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        _status == _RecommendStatus.loaded && _selected != null;
    return AppFormSheet(
      header: const _Header(),
      body: _buildBody(),
      confirmLabel: '신청',
      onConfirm: canConfirm
          ? () => Navigator.of(context).pop(_songs[_selected!])
          : null,
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _RecommendStatus.loading:
        return const SizedBox(
          height: _statusHeight,
          child: Center(child: CircularProgressIndicator()),
        );
      case _RecommendStatus.error:
        return SizedBox(
          height: _statusHeight,
          child: _ErrorView(
            message: _error ?? '노래 추천을 불러오지 못했어요.',
            onRetry: _load,
          ),
        );
      case _RecommendStatus.loaded:
        if (_songs.isEmpty) {
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
            itemCount: _songs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s24),
            itemBuilder: (context, index) => _SongCard(
              song: _songs[index],
              selected: _selected == index,
              onTap: () =>
                  setState(() => _selected = _selected == index ? null : index),
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
