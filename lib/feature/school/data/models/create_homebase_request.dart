import 'package:freezed_annotation/freezed_annotation.dart';

import 'homebase_member.dart';

part 'create_homebase_request.freezed.dart';
part 'create_homebase_request.g.dart';

/// [reservationDate] 는 `yyyy-MM-dd` 문자열로 보낸다.
@freezed
abstract class CreateHomebaseRequest with _$CreateHomebaseRequest {
  const factory CreateHomebaseRequest({
    required String reservationDate,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required List<HomebaseMember> members,
  }) = _CreateHomebaseRequest;

  factory CreateHomebaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateHomebaseRequestFromJson(json);
}
