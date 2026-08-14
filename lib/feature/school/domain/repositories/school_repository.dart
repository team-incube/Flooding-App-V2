import '../../data/models/homebase_member.dart';
import '../../data/models/homebase_reservation.dart';

/// 홈베이스 예약 도메인 계약.
abstract interface class SchoolRepository {
  /// [date] 하루치 홈베이스 예약 목록을 조회한다.
  Future<List<HomebaseReservation>> fetchReservations(DateTime date);

  /// [homebaseId] 좌석에 [date] 날짜로 홈베이스를 예약한다.
  Future<void> createReservation({
    required int homebaseId,
    required DateTime date,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required List<HomebaseMember> members,
  });

  /// [reservationId] 예약을 삭제한다.
  Future<void> deleteReservation(int reservationId);
}
