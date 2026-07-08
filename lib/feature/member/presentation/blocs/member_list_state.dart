import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/member_model.dart';

part 'member_list_state.freezed.dart';

@freezed
class MemberListState with _$MemberListState {
  const MemberListState._();

  const factory MemberListState.initial() = _Initial;

  const factory MemberListState.loading() = _Loading;

  const factory MemberListState.loaded({
    required List<MemberModel> memberList,
    /// 서버에서 재조회한 결과면 true, 로컬 낙관적 업데이트면 false.
    @Default(false) bool fromServer,
  }) = _Loaded;

  const factory MemberListState.filtered({
    required List<MemberModel> memberList,
  }) = _Filtered;

  const factory MemberListState.error({required String message}) = _Error;
}
