import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/me.dart';

part 'me_event.freezed.dart';

@freezed
class MeEvent with _$MeEvent {
  const MeEvent._();

  /// 내 정보(`/users/me`) 로드 요청.
  const factory MeEvent.requested() = _Requested;

  /// 이미 받아온 내 정보로 곧장 채운다(추가 호출 없이).
  ///
  /// 앱 시작 시 세션 검사용 `/users/me` 가 받아온 본문을 재사용해, 같은
  /// 엔드포인트를 두 번 부르지 않도록 한다.
  const factory MeEvent.provided(Me me) = _Provided;

  /// 로그아웃 등으로 보관 중인 내 정보를 비운다.
  const factory MeEvent.cleared() = _Cleared;
}
