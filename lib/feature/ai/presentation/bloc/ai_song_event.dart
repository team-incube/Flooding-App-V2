import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_song_event.freezed.dart';

/// 노래 추천 팝업에서 발생하는 이벤트.
@freezed
sealed class AiSongEvent with _$AiSongEvent {
  /// 추천을 요청한다(최초 로드·'다시 시도' 공용).
  const factory AiSongEvent.requested() = _AiSongRequested;

  /// [index] 곡을 선택/해제(토글)한다.
  const factory AiSongEvent.songSelected(int index) = _AiSongSongSelected;
}
