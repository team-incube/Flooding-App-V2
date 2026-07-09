import 'package:flooding_v2/core/constants/app_size.dart';
import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/enum/role.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/search_text_field.dart';
import 'package:flooding_v2/core/widgets/sheet/sheet.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_state.dart';
import 'package:flooding_v2/feature/song/data/models/wake_up_music.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_bloc.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_event.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_state.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/song_request_card.dart';
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

  /// 달력 팝업으로 조회 날짜를 바꾼다. 취소(바깥 탭·뒤로가기)하면 그대로 둔다.
  ///
  /// 다른 날짜의 목록은 기존 목록과 무관하므로 refresh 가 아닌 최초 조회로
  /// 처리해(인디케이터 노출) 이전 날짜의 곡이 잠시 남아 보이지 않게 한다.
  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final bloc = context.read<MusicBloc>();
    final picked = await DatePickerSheet.show(
      context,
      initialDate: current ?? DateTime.now(),
    );
    if (picked == null) return;
    bloc.add(MusicEvent.listRequested(date: picked));
  }

  /// [date] 가 오늘(또는 미지정 — 서버 기본이 당일)인지 여부.
  static bool _isToday(DateTime? date) {
    if (date == null) return true;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 헤더에 표시할 `MM.dd` 라벨.
  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month.$day';
  }

  void _showSnack(BuildContext context, String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // 로그인한 사용자 id — 신청자 userId 가 이 값과 같은 곡에 취소 버튼을 노출한다.
    final myUserId = context.select<MeBloc, int?>(
      (bloc) => bloc.state.maybeWhen(loaded: (me) => me.id, orElse: () => null),
    );
    return MultiBlocListener(
      listeners: [
        // 목록 조회 실패 — 화면은 기존 목록을 유지하고 사유만 스낵바로 안내한다.
        BlocListener<MusicBloc, MusicState>(
          listenWhen: (prev, curr) =>
              curr.listStatus == MusicListStatus.error &&
              prev.listStatus != MusicListStatus.error,
          listener: (context, state) => _showSnack(context, state.listError),
        ),
        // 좋아요 토글 실패 — 낙관적 변경을 롤백하고 사유를 스낵바로 안내한다.
        BlocListener<MusicBloc, MusicState>(
          listenWhen: (prev, curr) =>
              !identical(prev.likeResult, curr.likeResult) &&
              curr.likeResult != null,
          listener: (context, state) =>
              _showSnack(context, state.likeResult?.message),
        ),
        // 신청 취소 결과 — 성공·실패 모두 스낵바로 안내한다.
        BlocListener<MusicBloc, MusicState>(
          listenWhen: (prev, curr) =>
              !identical(prev.cancelResult, curr.cancelResult) &&
              curr.cancelResult != null,
          listener: (context, state) =>
              _showSnack(context, state.cancelResult?.message),
        ),
      ],
      child: BlocBuilder<MusicBloc, MusicState>(
        builder: (context, state) {
        final isLoading =
            state.listStatus == MusicListStatus.initial ||
            state.listStatus == MusicListStatus.loading ||
            (state.listStatus == MusicListStatus.refreshing &&
                state.totalCount == 0);

        final musics = state.musics;

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
                // 오늘이 아닌 날짜를 보고 있을 때만, 어느 날짜인지 함께 알린다.
                if (!_isToday(state.date))
                  Text(
                    _formatDate(state.date!),
                    style: AppTextStyle.caption1.copyWith(
                      color: AppColors.lightSub2,
                    ),
                  ),
                IconButton(
                  onPressed: () => _pickDate(context, state.date),
                  icon: AppIcon.calendar(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: SearchTextField(
                textEditingController: _songSearchController,
                hintText: '학생 이름, 노래 제목을 입력해주세요',
                onChanged: (value) =>
                    context.read<MusicBloc>().add(MusicEvent.searched(value)),
              ),
            ),
            Expanded(
              child: _buildBody(
                isLoading: isLoading,
                hasAny: state.totalCount > 0,
                musics: musics,
                myUserId: myUserId,
                // 기숙사 관리자·어드민은 모든 사용자의 곡을 삭제할 수 있다.
                canManageAll: context.isManager,
              ),
            ),
          ],
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasAny,
    required List<WakeUpMusic> musics,
    required int? myUserId,
    required bool canManageAll,
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
        // 관리자는 모든 곡을, 일반 사용자는 본인 신청 곡만 삭제할 수 있다.
        final canDelete =
            canManageAll || (myUserId != null && music.userId == myUserId);
        return SongRequestCard(
          song: music.title ?? music.musicUrl ?? '제목 없음',
          grade: music.studentNumber?.toString() ?? '',
          name: music.userName ?? '',
          requestedAt: music.appliedAt ?? DateTime.now(),
          thumbnailUrl: music.thumbnailUrl,
          isLiked: music.isLiked,
          onLikePressed: () =>
              context.read<MusicBloc>().add(MusicEvent.likeToggled(music.id)),
          canDelete: canDelete,
          onDeletePressed: () =>
              context.read<MusicBloc>().add(MusicEvent.cancelRequested(music.id)),
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
