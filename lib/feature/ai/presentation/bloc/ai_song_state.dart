import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/song_recommendation.dart';

part 'ai_song_state.freezed.dart';

/// 노래 추천 로딩 상태.
enum AiSongStatus { initial, loading, loaded, error }

@freezed
abstract class AiSongState with _$AiSongState {
  const factory AiSongState({
    @Default(AiSongStatus.initial) AiSongStatus status,

    /// 추천 곡 목록(로드 완료 시 채워진다).
    @Default(<SongRecommendation>[]) List<SongRecommendation> songs,

    /// 현재 선택된 곡의 인덱스(미선택 시 null). '신청'은 이 값이 있을 때만 활성.
    int? selectedIndex,

    /// 로딩 실패 사유(오류 상태에서만 설정).
    String? error,
  }) = _AiSongState;
}
