import 'package:freezed_annotation/freezed_annotation.dart';

import 'homebase_reservation.dart';

part 'homebase_reservation_list_response.freezed.dart';
part 'homebase_reservation_list_response.g.dart';

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
