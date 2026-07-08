import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enum/gender.dart';

part 'member_list_event.freezed.dart';

@freezed
class MemberListEvent with _$MemberListEvent {
  MemberListEvent._();

  factory MemberListEvent.load() = _Load;

  factory MemberListEvent.filter({
    int? grade,
    int? classNb,
    Gender? gender,
  }) = _Filter;

  /// 특정 멤버의 출석 상태를 로컬에서 즉시 토글한다(낙관적 업데이트용).
  factory MemberListEvent.toggleAttendance({required int userId}) =
      _ToggleAttendance;
}
