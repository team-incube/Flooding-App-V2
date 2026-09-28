import 'package:freezed_annotation/freezed_annotation.dart';

part 'homebase_member.freezed.dart';
part 'homebase_member.g.dart';

@freezed
abstract class HomebaseMember with _$HomebaseMember {
  const factory HomebaseMember({
    required String studentNumber,
    required String name,
  }) = _HomebaseMember;

  factory HomebaseMember.fromJson(Map<String, dynamic> json) =>
      _$HomebaseMemberFromJson(json);
}
