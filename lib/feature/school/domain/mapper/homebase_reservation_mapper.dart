import '../../data/models/homebase_reservation.dart';
import '../../presentation/models/homebase_reservation_model.dart';
import '../homebase_seat.dart';

class HomebaseReservationMapper {
  static HomebaseReservationModel toModel(HomebaseReservation r) =>
      HomebaseReservationModel(
        id: r.id,
        floor: HomebaseSeat.floorOf(r.homebaseId),
        tableNumber: HomebaseSeat.tableNumberOf(r.homebaseId),
        students: [
          for (final member in r.members)
            HomebaseReservationStudent(
              // 학번은 서버에서 문자열로 내려온다 — 표시용 정수로 변환한다.
              schoolNb: int.tryParse(member.studentNumber) ?? 0,
              name: member.name,
            ),
        ],
        periods: [for (var p = r.startPeriod; p <= r.endPeriod; p++) p],
      );
}
