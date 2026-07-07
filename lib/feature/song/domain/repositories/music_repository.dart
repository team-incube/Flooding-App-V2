import '../../data/models/wake_up_music.dart';
import '../enum/music_sort.dart';


abstract interface class MusicRepository {
  Future<List<WakeUpMusic>> fetchMusicList({
    DateTime? date,
    MusicSort sort = MusicSort.time,
  });

  Future<WakeUpMusic> applyMusic(String musicUrl);

  /// [musicId] 기상음악 신청을 취소한다(본인 신청 곡만 가능).
  Future<void> cancelMusic(int musicId);

  Future<void> likeMusic(int musicId);

  Future<void> unlikeMusic(int musicId);
}
