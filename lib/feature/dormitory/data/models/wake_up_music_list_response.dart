import 'package:freezed_annotation/freezed_annotation.dart';

import 'wake_up_music.dart';

part 'wake_up_music_list_response.freezed.dart';
part 'wake_up_music_list_response.g.dart';

/// `GET /dormitory/music` 응답 래퍼(`CommonApiResponse`).
///
/// 실제 페이로드는 [data]로, 날짜별 기상음악 신청 목록이다.
///
/// 주의: 현재 Swagger 문서에 GET 응답 `data` 스키마가 정의돼 있지 않아,
/// POST 응답([WakeUpMusic])의 목록으로 모델링했다. 실제 응답 확인 후 보정한다.
@freezed
abstract class WakeUpMusicListResponse with _$WakeUpMusicListResponse {
  const factory WakeUpMusicListResponse({
    String? status,
    int? code,
    String? message,
    @Default(<WakeUpMusic>[]) List<WakeUpMusic> data,
  }) = _WakeUpMusicListResponse;

  factory WakeUpMusicListResponse.fromJson(Map<String, dynamic> json) =>
      _$WakeUpMusicListResponseFromJson(json);
}
