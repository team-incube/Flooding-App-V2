import 'package:freezed_annotation/freezed_annotation.dart';

import 'homebase_member.dart';

part 'homebase_reservation.freezed.dart';
part 'homebase_reservation.g.dart';

/// 홈베이스 예약 1건(`GetHomebaseResponse`).
///
/// `reservationDate` 는 서버가 `yyyy-MM-dd` 문자열로 내려준다.
@freezed
abstract class HomebaseReservation with _$HomebaseReservation {
  const factory HomebaseReservation({
    required int id,
    required String reservationDate,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required int homebaseId,
    @Default(<HomebaseMember>[]) List<HomebaseMember> members,
  }) = _HomebaseReservation;

  factory HomebaseReservation.fromJson(Map<String, dynamic> json) =>
      _$HomebaseReservationFromJson(json);
}
