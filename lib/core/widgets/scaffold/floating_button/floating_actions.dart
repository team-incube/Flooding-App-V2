import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../feature/ai/presentation/widgets/song_recommendation_sheet.dart';
import '../../../constants/app_size.dart';
import '../../../constants/app_spacing.dart';
import '../../../route/route_path.dart';
import '../../../theme/color/app_colors.dart';
import '../../../theme/icon/app_icon.dart';


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
