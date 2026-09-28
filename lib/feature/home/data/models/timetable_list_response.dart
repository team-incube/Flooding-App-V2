import 'package:freezed_annotation/freezed_annotation.dart';

import 'timetable_data.dart';

part 'timetable_list_response.freezed.dart';
part 'timetable_list_response.g.dart';

/// `GET /v2/neis/timetables` 응답 래퍼(`CommonApiResponse`).
@freezed
abstract class TimetableListResponse with _$TimetableListResponse {
  const factory TimetableListResponse({
    String? status,
    int? code,
    String? message,
    TimetableData? data,
  }) = _TimetableListResponse;

  factory TimetableListResponse.fromJson(Map<String, dynamic> json) =>
      _$TimetableListResponseFromJson(json);
}
