import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/wake_up_music.dart';

part 'music_sse_event.freezed.dart';

/// 기상음악 SSE(`/dormitory/music/subscribe`)로 수신하는 실시간 이벤트.
///
/// 서버 이벤트 이름 매핑:
/// - `init`               → [MusicSseEvent.listInitialized] (구독 직후 오늘 전체 목록)
/// - `music-applied`      → [MusicSseEvent.applied]         (신청 1건)
/// - `music-cancelled`    → [MusicSseEvent.cancelled]       (취소 1건)
/// - `music-like-updated` → [MusicSseEvent.likeUpdated]     (좋아요 수 변경)
@freezed
class MusicSseEvent with _$MusicSseEvent {
  /// 구독 직후 서버가 보내는 오늘의 전체 신청 목록(init).
  const factory MusicSseEvent.listInitialized(List<WakeUpMusic> musics) =
      _ListInitialized;

  /// 곡이 새로 신청됨(music-applied) — 다른 사용자의 신청도 실시간 반영한다.
  const factory MusicSseEvent.applied(WakeUpMusic music) = _Applied;

  /// 곡 신청이 취소됨(music-cancelled).
  const factory MusicSseEvent.cancelled(int musicId) = _Cancelled;

  /// 곡의 좋아요 수가 변경됨(music-like-updated).
  ///
  /// 서버는 좋아요 총계만 내려주므로 개인별 [WakeUpMusic.isLiked] 는 건드리지 않고
  /// [likeCount] 만 갱신한다.
  const factory MusicSseEvent.likeUpdated({
    required int musicId,
    required int likeCount,
  }) = _LikeUpdated;
}
