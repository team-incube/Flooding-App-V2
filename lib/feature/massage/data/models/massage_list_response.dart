import 'package:freezed_annotation/freezed_annotation.dart';

import 'massage_data.dart';

part 'massage_list_response.freezed.dart';
part 'massage_list_response.g.dart';

/// `GET /dormitory/massages` 응답 래퍼(`CommonApiResponse`).
///
/// 실제 페이로드는 [data]([MassageData]) 객체로, 그 안의 `applicants` 가
/// 신청자 목록이다. (서버가 `data` 를 배열이 아닌 객체로 내려준다.)
@freezed
abstract class MassageListResponse with _$MassageListResponse {
  const factory MassageListResponse({
    String? status,
    int? code,
    String? message,
    MassageData? data,
  }) = _MassageListResponse;

  factory MassageListResponse.fromJson(Map<String, dynamic> json) =>
      _$MassageListResponseFromJson(json);
}
