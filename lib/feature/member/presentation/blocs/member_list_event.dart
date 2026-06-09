import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_list_event.freezed.dart';

@freezed
class MemberListEvent with _$MemberListEvent {
  MemberListEvent._();

  factory MemberListEvent.load() = _Load;

  factory MemberListEvent.filter() = _Filter;
}
