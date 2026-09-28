import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_selection_state.freezed.dart';

@freezed
abstract class MemberSelectionState with _$MemberSelectionState {
  const factory MemberSelectionState({
    /// 선택된 학생들의 서버 ID(MemberModel.id) 집합.
    @Default(<int>{}) Set<int> checkList,
    @Default(false) bool isSending,

    /// 현재 선택된 항목들의 출석 상태(선택이 비어 있으면 null) — 선택은 항상
    /// 이 상태와 일치하는 항목으로만 채워진다(체크인/체크아웃 혼선 방지).
    bool? selectedAttendance,
  }) = _MemberSelectionState;
}
