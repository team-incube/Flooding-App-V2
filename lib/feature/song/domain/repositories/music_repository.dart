import '../../data/models/wake_up_music.dart';
import '../enum/music_sort.dart';
import '../models/music_sse_event.dart';


abstract interface class MusicRepository {
  Future<List<WakeUpMusic>> fetchMusicList({
    DateTime? date,
    MusicSort sort = MusicSort.time,
  });

  /// 기상음악 실시간 이벤트(SSE)를 구독한다.
  ///
  /// 연결 직후 [MusicListInitialized] 로 오늘 전체 목록을 받고, 이후 신청·취소·
  /// 좋아요 변경을 순차 이벤트로 흘려보낸다. 구독을 멈추려면 스트림 구독을
  /// 취소하면 되고, 연결이 끊기면 스트림도 종료된다(재연결은 호출부 책임).
  Stream<MusicSseEvent> subscribeMusicEvents();

  Future<WakeUpMusic> applyMusic(String musicUrl);

  /// [musicId] 기상음악 신청을 취소한다(본인 신청 곡만 가능).
  Future<void> cancelMusic(int musicId);

  Future<void> likeMusic(int musicId);

  Future<void> unlikeMusic(int musicId);
}
