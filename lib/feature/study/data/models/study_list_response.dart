import 'package:freezed_annotation/freezed_annotation.dart';

import 'study_data.dart';

part 'study_list_response.freezed.dart';
part 'study_list_response.g.dart';

/// `GET /dormitory/studies` 응답 래퍼(`CommonApiResponse`).
///
/// 실제 페이로드는 [data]([StudyData]) 객체로, 그 안의 `applicants` 가
/// 신청자 목록이다. (서버가 `data` 를 배열이 아닌 객체로 내려준다.)
@freezed
abstract class StudyListResponse with _$StudyListResponse {
  const factory StudyListResponse({
    String? status,
    int? code,
    String? message,
    StudyData? data,
  }) = _StudyListResponse;

  factory StudyListResponse.fromJson(Map<String, dynamic> json) =>
      _$StudyListResponseFromJson(json);
}
