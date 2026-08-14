import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/homebase_reservation_model.dart';

part 'school_state.freezed.dart';

/// 홈베이스 예약 목록 조회 상태.
///
/// [loading] 은 최초 조회(인디케이터 노출), [refreshing] 은 기존 목록을 유지한
/// 채 백그라운드로 다시 불러오는 재조회 상태(인디케이터 미노출)다.
enum SchoolListStatus { initial, loading, refreshing, loaded, error }

/// 예약 생성/삭제 1회 결과 — 호출자가 SnackBar 등으로 안내한다.
///
/// 매번 새 인스턴스로 생성해 동일 메시지라도 상태 변화를 구분할 수 있게 한다
/// (BlocListener 가 결과 식별자로 중복 안내를 거른다).
class SchoolActionResult {
  SchoolActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

@freezed
abstract class SchoolState with _$SchoolState {
  const factory SchoolState({
    @Default(SchoolListStatus.initial) SchoolListStatus listStatus,
    @Default(<HomebaseReservationModel>[])
    List<HomebaseReservationModel> reservations,
    String? listError,
    @Default(false) bool isSubmitting,
    SchoolActionResult? result,
  }) = _SchoolState;
}
