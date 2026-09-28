import 'package:freezed_annotation/freezed_annotation.dart';

part 'wake_up_music.freezed.dart';
part 'wake_up_music.g.dart';

/// 기상음악으로 신청된 곡 1건.
///
/// `POST /dormitory/music` 응답의 `data`(`WakeUpMusicResponse`)이자,
/// `GET /dormitory/music` 목록의 항목이다.
///
/// 서버가 보장하는 식별자([id])만 required 로 두고, 나머지 표시용 필드는
/// 응답 누락에도 파싱이 깨지지 않도록 nullable/기본값으로 둔다.
@freezed
abstract class WakeUpMusic with _$WakeUpMusic {
  const factory WakeUpMusic({
    required int id,
    int? userId,
    String? userName,
    int? studentNumber,
    String? musicUrl,
    String? title,
    String? artist,
    String? duration,
    String? durationText,
    String? thumbnailUrl,
    String? videoUrl,

    /// 신청 시각. (서버 표기: ISO-8601 date-time)
    DateTime? appliedAt,
    @Default(0) int likeCount,
    @Default(false) bool isLiked,
  }) = _WakeUpMusic;

  factory WakeUpMusic.fromJson(Map<String, dynamic> json) =>
      _$WakeUpMusicFromJson(json);
}
