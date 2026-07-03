import 'package:freezed_annotation/freezed_annotation.dart';

import 'wake_up_music.dart';

part 'wake_up_music_response.freezed.dart';
part 'wake_up_music_response.g.dart';

/// `POST /dormitory/music` 응답 래퍼(`CommonApiResponse`).
///
/// 신청 성공 시 방금 등록된 곡([WakeUpMusic])을 [data]로 내려준다.
@freezed
abstract class WakeUpMusicResponse with _$WakeUpMusicResponse {
  const factory WakeUpMusicResponse({
    String? status,
    int? code,
    String? message,
    WakeUpMusic? data,
  }) = _WakeUpMusicResponse;

  factory WakeUpMusicResponse.fromJson(Map<String, dynamic> json) =>
      _$WakeUpMusicResponseFromJson(json);
}
