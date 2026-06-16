import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_selection_state.freezed.dart';

@freezed
abstract class MemberSelectionState with _$MemberSelectionState {
  const factory MemberSelectionState({@Default(<int>{}) Set<int> selected}) =
      _MemberSelectionState;
}
