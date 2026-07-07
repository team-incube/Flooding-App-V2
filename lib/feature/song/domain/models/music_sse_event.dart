import '../../data/models/wake_up_music.dart';

/// 기상음악 SSE(`/dormitory/music/subscribe`)로 수신하는 실시간 이벤트.
///
/// 서버 이벤트 이름 매핑:
/// - `init`               → [MusicListInitialized] (구독 직후 오늘 전체 목록)
/// - `music-applied`      → [MusicApplied]         (신청 1건)
/// - `music-cancelled`    → [MusicCancelled]       (취소 1건)
/// - `music-like-updated` → [MusicLikeUpdated]     (좋아요 수 변경)
sealed class MusicSseEvent {
  const MusicSseEvent();
}

/// 구독 직후 서버가 보내는 오늘의 전체 신청 목록(init).
class MusicListInitialized extends MusicSseEvent {
  const MusicListInitialized(this.musics);

  final List<WakeUpMusic> musics;
}

/// 곡이 새로 신청됨(music-applied) — 다른 사용자의 신청도 실시간 반영한다.
class MusicApplied extends MusicSseEvent {
  const MusicApplied(this.music);

  final WakeUpMusic music;
}

/// 곡 신청이 취소됨(music-cancelled).
class MusicCancelled extends MusicSseEvent {
  const MusicCancelled(this.musicId);

  final int musicId;
}

/// 곡의 좋아요 수가 변경됨(music-like-updated).
///
/// 서버는 좋아요 총계만 내려주므로 개인별 [WakeUpMusic.isLiked] 는 건드리지 않고
/// [likeCount] 만 갱신한다.
class MusicLikeUpdated extends MusicSseEvent {
  const MusicLikeUpdated({required this.musicId, required this.likeCount});

  final int musicId;
  final int likeCount;
}
