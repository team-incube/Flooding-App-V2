import 'package:flutter_bloc/flutter_bloc.dart';

import 'member_selection_event.dart';
import 'member_selection_state.dart';

class MemberSelectionBloc
    extends Bloc<MemberSelectionEvent, MemberSelectionState> {
  MemberSelectionBloc() : super(const MemberSelectionState()) {
    on<MemberSelectionEvent>((event, emit) {
      event.whenOrNull(
        check: (id, isAttended) => _onCheck(id, isAttended, emit),
        clear: () => emit(const MemberSelectionState()),
      );
    });
  }

  void _onCheck(int id, bool isAttended, Emitter<MemberSelectionState> emit) {
    final selected = Set<int>.from(state.checkList);
    if (selected.remove(id)) {
      emit(
        state.copyWith(
          checkList: selected,
          selectedAttendance: selected.isEmpty
              ? null
              : state.selectedAttendance,
        ),
      );
      return;
    }
    // 이미 다른 출석 상태를 선택 중이면 무시한다(체크인/체크아웃 혼선 방지).
    // UI(MemberCard)가 먼저 막지만, 방어적으로 한 번 더 확인한다.
    if (state.selectedAttendance != null &&
        state.selectedAttendance != isAttended) {
      return;
    }
    selected.add(id);
    emit(state.copyWith(checkList: selected, selectedAttendance: isAttended));
  }
}
