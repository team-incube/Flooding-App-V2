import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/homebase_member.dart';

part 'school_event.freezed.dart';

@freezed
class SchoolEvent with _$SchoolEvent {
  /// 오늘 홈베이스 예약 목록을 (재)조회한다.
  ///
  /// [refresh] 가 true 면 재조회로 간주해 로딩 인디케이터를 띄우지 않고
  /// 기존 목록을 유지한 채 값만 갱신한다(최초 조회만 인디케이터 노출).
  const factory SchoolEvent.reservationsRequested({
    @Default(false) bool refresh,
  }) = _ReservationsRequested;

  /// [floor]·[tableNumber] 좌석에 [periods] 교시로 홈베이스를 예약한다.
  ///
  /// 신청은 연속 교시만 가능하므로 [periods] 중 최소~최대를 시작~종료 교시로
  /// 서버에 보낸다.
  const factory SchoolEvent.reservationCreated({
    required int floor,
    required int tableNumber,
    required Set<int> periods,
    required String reason,
    required List<HomebaseMember> members,
  }) = _ReservationCreated;

  /// [reservationId] 예약을 삭제한다.
  const factory SchoolEvent.reservationDeleted({required int reservationId}) =
      _ReservationDeleted;
}
