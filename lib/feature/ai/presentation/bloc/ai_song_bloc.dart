import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/youtube.dart';
import '../../domain/repositories/ai_repository.dart';
import '../models/song_recommendation.dart';
import 'ai_song_event.dart';
import 'ai_song_state.dart';

/// 노래 추천(`POST /ai/song`)을 담당하는 Bloc.
///
/// [AiSongEvent.requested] 를 받으면 [AiRepository] 로 추천 유튜브 링크를
/// 불러와 표시용 [SongRecommendation] 으로 변환한다. 실패 시 [AiSongStatus.error]
/// 로 두어 팝업이 '다시 시도'를 노출한다.
class AiSongBloc extends Bloc<AiSongEvent, AiSongState> {
  AiSongBloc({required AiRepository repository})
    : _repository = repository,
      super(const AiSongState()) {
    on<AiSongEvent>((event, emit) async {
      await event.when(
        requested: () => _onRequested(emit),
        songSelected: (index) async {
          // 같은 카드를 다시 누르면 선택 해제(토글).
          emit(
            state.copyWith(
              selectedIndex: state.selectedIndex == index ? null : index,
            ),
          );
        },
      );
    });
  }

  final AiRepository _repository;

  Future<void> _onRequested(Emitter<AiSongState> emit) async {
    // 재요청 시 이전 선택을 비운다.
    emit(
      state.copyWith(
        status: AiSongStatus.loading,
        error: null,
        selectedIndex: null,
      ),
    );
    try {
      final links = await _repository.recommendSongs();
      if (isClosed) return;
      // 링크만 오므로 제목엔 URL 을, 썸네일은 영상 ID 로 생성한다.
      final songs = [
        for (final url in links)
          SongRecommendation(title: url, thumbnail: youtubeThumbnail(url)),
      ];
      emit(state.copyWith(status: AiSongStatus.loaded, songs: songs));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: AiSongStatus.error, error: e.message));
    } catch (e, s) {
      // 파싱 오류 등 ApiException 이 아닌 실패에도 로딩을 풀어준다.
      Logger.e('AI 음악추천 실패', tag: 'AI', error: e, stackTrace: s);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AiSongStatus.error,
          error: '노래 추천을 불러오지 못했어요.',
        ),
      );
    }
  }
}
