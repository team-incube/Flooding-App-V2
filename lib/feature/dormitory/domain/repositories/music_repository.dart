import '../../data/models/wake_up_music.dart';
import '../enum/music_sort.dart';


abstract interface class MusicRepository {
  Future<List<WakeUpMusic>> fetchMusicList({
    DateTime? date,
    MusicSort sort = MusicSort.time,
  });

  Future<WakeUpMusic> applyMusic(String musicUrl);

  Future<void> likeMusic(int musicId);

  Future<void> unlikeMusic(int musicId);
}
