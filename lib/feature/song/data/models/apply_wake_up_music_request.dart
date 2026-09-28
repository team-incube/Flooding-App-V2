import 'package:freezed_annotation/freezed_annotation.dart';

part 'apply_wake_up_music_request.freezed.dart';
part 'apply_wake_up_music_request.g.dart';

/// `POST /dormitory/music` 요청 본문 — 음악 URL 로 기상음악을 신청한다.
@freezed
abstract class ApplyWakeUpMusicRequest with _$ApplyWakeUpMusicRequest {
  const factory ApplyWakeUpMusicRequest({required String musicUrl}) =
      _ApplyWakeUpMusicRequest;

  factory ApplyWakeUpMusicRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyWakeUpMusicRequestFromJson(json);
}
