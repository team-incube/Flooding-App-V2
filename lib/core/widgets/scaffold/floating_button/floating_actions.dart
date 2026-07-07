import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../feature/ai/domain/repositories/ai_repository.dart';
import '../../../../feature/ai/presentation/widgets/song_recommendation_sheet.dart';
import '../../../../feature/song/presentation/bloc/music_bloc.dart';
import '../../../../feature/song/presentation/bloc/music_event.dart';
import '../../../constants/app_size.dart';
import '../../../constants/app_spacing.dart';
import '../../../route/route_path.dart';
import '../../../theme/color/app_colors.dart';
import '../../../theme/icon/app_icon.dart';
import '../../../utils/youtube.dart';


/// 우측 하단에 세로로 쌓인 두 개의 원형 액션 버튼.
class FloatingActions extends StatefulWidget {
  const FloatingActions.aiChat({super.key})
    : showAiChat = true,
      showSongRecommend = false;

  const FloatingActions.songRecommend({super.key})
    : showAiChat = false,
      showSongRecommend = true;

  const FloatingActions.both({super.key})
    : showAiChat = true,
      showSongRecommend = true;

  const FloatingActions.none({super.key})
    : showAiChat = false,
      showSongRecommend = false;

  final bool showSongRecommend;
  final bool showAiChat;

  @override
  State<FloatingActions> createState() => _FloatingActionsState();
}

class _FloatingActionsState extends State<FloatingActions> {
  /// 플로팅 AI 버튼 → 오늘의 노래 추천 팝업.
  ///
  /// 팝업이 열리면 그 안에서 `POST /ai/song` 으로 추천 유튜브 링크를 받아
  /// (로딩 → 목록) 표시하고, 사용자가 고른 링크는 기존 기상음악 신청
  /// 흐름([MusicBloc])으로 신청한다.
  Future<void> _openSongRecommendation() async {
    final aiRepository = context.read<AiRepository>();
    final musicBloc = context.read<MusicBloc>();

    final selected = await SongRecommendationSheet.show(
      context,
      loadSongs: () async {
        final links = await aiRepository.recommendSongs();
        return [
          for (final url in links)
            SongRecommendation(title: url, thumbnail: youtubeThumbnail(url)),
        ];
      },
    );
    if (selected == null) return;

    // 선택한 링크로 기존 신청 흐름을 태운다 — 결과 스낵바는 MusicBloc 리스너가 안내.
    musicBloc.add(MusicEvent.applied(selected.title));
  }

  /// 플로팅 챗봇 버튼 → AI 챗봇 대화 페이지로 이동.
  void _openAiChat() => context.push(RoutePath.aiChat);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSongRecommend)
          _CircleAction(onTap: _openSongRecommendation, icon: AppIcon.sparkle),
        if (widget.showAiChat && widget.showSongRecommend)
          const SizedBox(height: AppSpacing.s12),
        if (widget.showAiChat)
          _CircleAction(onTap: _openAiChat, icon: AppIcon.chatBot),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, this.onTap});

  final AppIconBuilder icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightBgSurface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: AppSize.s60,
          height: AppSize.s60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightBgSurface,
          ),
          child: Align(alignment: Alignment.center, child: icon(size: 39)),
        ),
      ),
    );
  }
}
