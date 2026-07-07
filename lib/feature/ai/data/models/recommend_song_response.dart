import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommend_song_response.freezed.dart';
part 'recommend_song_response.g.dart';

/// `POST /ai/song` 응답 래퍼(`CommonApiResponse`).
///
/// 실제 추천 결과는 [data]([RecommendSongData])의 유튜브 링크 목록이다.
@freezed
abstract class RecommendSongResponse with _$RecommendSongResponse {
  const factory RecommendSongResponse({
    String? status,
    int? code,
    String? message,
    RecommendSongData? data,
  }) = _RecommendSongResponse;

  factory RecommendSongResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongResponseFromJson(json);
}

/// `POST /ai/song` 응답의 `data` — AI 가 추천한 유튜브 링크(최대 3개).
///
/// 서버 스키마가 snake_case(`youtube_links`)이므로 직렬화 키를 맞춘다.
@freezed
abstract class RecommendSongData with _$RecommendSongData {
  const factory RecommendSongData({
    @JsonKey(name: 'youtube_links')
    @Default(<String>[]) List<String> youtubeLinks,
  }) = _RecommendSongData;

  factory RecommendSongData.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongDataFromJson(json);
}
