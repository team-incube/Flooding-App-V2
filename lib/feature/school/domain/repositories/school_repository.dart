import '../../data/models/homebase_member.dart';
import '../../data/models/homebase_reservation.dart';

abstract interface class SchoolRepository {
  Future<List<HomebaseReservation>> fetchReservations(DateTime date);

  Future<void> createReservation({
    required int homebaseId,
    required DateTime date,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required List<HomebaseMember> members,
  });

  Future<void> deleteReservation(int reservationId);
}
