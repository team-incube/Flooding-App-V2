import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/member_model.dart';

part 'member_list_state.freezed.dart';

@freezed
sealed class MemberListState with _$MemberListState {
  const MemberListState._();

  const factory MemberListState.initial() = MemberListInitial;

  const factory MemberListState.loading() = MemberListLoading;

  const factory MemberListState.loaded({
    required List<MemberModel> memberList,
    /// 서버에서 재조회한 결과면 true, 로컬 낙관적 업데이트면 false.
    @Default(false) bool fromServer,
  }) = MemberListLoaded;

  const factory MemberListState.filtered({
    required List<MemberModel> memberList,
  }) = MemberListFiltered;

  const factory MemberListState.error({required String message}) =
      MemberListError;
}
