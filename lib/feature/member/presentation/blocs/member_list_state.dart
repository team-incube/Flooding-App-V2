import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_list_state.freezed.dart';

@freezed
class MemberListState with _$MemberListState {
  const MemberListState._();

  const factory MemberListState.initial() = _Initial;

  const factory MemberListState.loading() = _Loading;

  const factory MemberListState.empty() = _Empty;
}
