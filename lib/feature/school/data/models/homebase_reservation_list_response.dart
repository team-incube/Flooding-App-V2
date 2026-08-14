import 'package:freezed_annotation/freezed_annotation.dart';

import 'homebase_reservation.dart';

part 'homebase_reservation_list_response.freezed.dart';
part 'homebase_reservation_list_response.g.dart';

/// `GET /homebase` 응답 래퍼(`CommonApiResponse`).
///
/// 실제 페이로드는 [data] — 조회한 날짜의 홈베이스 예약 목록이다.
@freezed
abstract class HomebaseReservationListResponse
    with _$HomebaseReservationListResponse {
  const factory HomebaseReservationListResponse({
    String? status,
    int? code,
    String? message,
    @Default(<HomebaseReservation>[]) List<HomebaseReservation> data,
  }) = _HomebaseReservationListResponse;

  factory HomebaseReservationListResponse.fromJson(Map<String, dynamic> json) =>
      _$HomebaseReservationListResponseFromJson(json);
}
