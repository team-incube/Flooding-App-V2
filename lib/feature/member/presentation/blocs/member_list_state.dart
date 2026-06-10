import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/member_model.dart';

part 'member_list_state.freezed.dart';

@freezed
class MemberListState with _$MemberListState {
  const MemberListState._();

  const factory MemberListState.initial() = _Initial;

  const factory MemberListState.loading() = _Loading;

  const factory MemberListState.empty() = _Empty;

  const factory MemberListState.loaded({
    required List<MemberModel> memberList,
  }) = _Loaded;

  const factory MemberListState.filtered({
    required List<MemberModel> memberList,
  }) = _Filtered;
}
