import 'package:flooding_v2/core/constants/app_size.dart';
import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/search_text_field.dart';
import 'package:flooding_v2/feature/dormitory/data/models/wake_up_music.dart';
import 'package:flooding_v2/feature/dormitory/presentation/bloc/music_bloc.dart';
import 'package:flooding_v2/feature/dormitory/presentation/bloc/music_event.dart';
import 'package:flooding_v2/feature/dormitory/presentation/bloc/music_state.dart';
import 'package:flooding_v2/feature/dormitory/presentation/widgets/song_request_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongDetailView extends StatefulWidget {
  const SongDetailView({super.key});

  @override
  State<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends State<SongDetailView> {
  final _songSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 셸 진입 시 이미 1회 로드되므로, 화면 진입의 재조회는 인디케이터 없이
    // 값만 갱신한다(refresh) — 홈에서 신청한 곡이 바로 반영되도록.
    context.read<MusicBloc>().add(const MusicEvent.listRequested(refresh: true));
  }

  @override
  void dispose() {
    _songSearchController.dispose();
    super.dispose();
  }

  /// 로드된 목록에 검색어(노래 제목·신청자 이름)를 클라이언트에서 필터링한다.
  List<WakeUpMusic> _filtered(List<WakeUpMusic> musics) {
    final q = _songSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return musics;
    return musics.where((m) {
      final title = (m.title ?? '').toLowerCase();
      final name = (m.userName ?? '').toLowerCase();
      return title.contains(q) || name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MusicBloc, MusicState>(
      // 조회 실패 시 화면은 기존 목록을 유지하고, 사유는 스낵바로만 안내한다.
      listenWhen: (prev, curr) =>
          curr.listStatus == MusicListStatus.error &&
          prev.listStatus != MusicListStatus.error,
      listener: (context, state) {
        final message = state.listError;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final isLoading =
            state.listStatus == MusicListStatus.initial ||
            state.listStatus == MusicListStatus.loading ||
        (state.listStatus == MusicListStatus.refreshing && state.musics.isEmpty);

        final musics = _filtered(state.musics);

        return Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: AppIcon.back(),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  '음악신청',
                  style: AppTextStyle.text2.copyWith(
                    color: AppColors.lightMainText,
                  ),
                ),
                const Spacer(flex: 1),
                IconButton(onPressed: () {}, icon: AppIcon.calendar()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: SearchTextField(
                textEditingController: _songSearchController,
                hintText: '학생 이름, 노래 제목을 입력해주세요',
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: _buildBody(
                isLoading: isLoading,
                hasAny: state.musics.isNotEmpty,
                musics: musics,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasAny,
    required List<WakeUpMusic> musics,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (musics.isEmpty) {
      // 전체가 비었는지, 검색 결과만 비었는지 구분해 안내한다.
      return _EmptyMessage(
        message: hasAny ? '검색된 결과가 없습니다.' : '기상음악을 신청한 인원이 없습니다.',
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        final music = musics[index];
        return SongRequestCard(
          song: music.title ?? music.musicUrl ?? '제목 없음',
          grade: music.studentNumber?.toString() ?? '',
          name: music.userName ?? '',
          requestedAt: music.appliedAt ?? DateTime.now(),
          thumbnailUrl: music.thumbnailUrl,
          isLiked: music.isLiked,
          onLikePressed: () {
            // TODO: 좋아요 API 연동 시 이벤트 추가
          },
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s16),
      itemCount: musics.length,
    );
  }
}

/// 목록이 비었을 때의 스피커 아이콘 + 안내 문구.
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon.speaker(size: AppSize.s100),
          const SizedBox(height: AppSpacing.s12),
          Text(
            message,
            style: AppTextStyle.text2.copyWith(color: AppColors.lightSub2),
          ),
        ],
      ),
    );
  }
}
