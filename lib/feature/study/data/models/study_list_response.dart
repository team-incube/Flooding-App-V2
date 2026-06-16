import 'package:freezed_annotation/freezed_annotation.dart';

import 'study_applicant.dart';

part 'study_list_response.freezed.dart';
part 'study_list_response.g.dart';

/// `GET /dormitory/studies` 응답 래퍼(`CommonApiResponse`).
///
/// 자습 신청자 목록을 [data] 로 감싸 반환한다.
@freezed
abstract class StudyListResponse with _$StudyListResponse {
  const factory StudyListResponse({
    String? status,
    int? code,
    String? message,
    @Default(<StudyApplicant>[]) List<StudyApplicant> data,
  }) = _StudyListResponse;

  factory StudyListResponse.fromJson(Map<String, dynamic> json) =>
      _$StudyListResponseFromJson(json);
}
