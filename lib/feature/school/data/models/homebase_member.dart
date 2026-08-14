import 'package:freezed_annotation/freezed_annotation.dart';

part 'homebase_member.freezed.dart';
part 'homebase_member.g.dart';

/// 홈베이스 예약 인원 1명(`MemberDto`) — 요청·응답에 공통으로 쓰인다.
@freezed
abstract class HomebaseMember with _$HomebaseMember {
  const factory HomebaseMember({
    required String studentNumber,
    required String name,
  }) = _HomebaseMember;

  factory HomebaseMember.fromJson(Map<String, dynamic> json) =>
      _$HomebaseMemberFromJson(json);
}
