import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_event.freezed.dart';

@freezed
class MeEvent with _$MeEvent {
  const MeEvent._();

  /// 내 정보(`/users/me`) 로드 요청.
  const factory MeEvent.requested() = _Requested;

  /// 로그아웃 등으로 보관 중인 내 정보를 비운다.
  const factory MeEvent.cleared() = _Cleared;
}
