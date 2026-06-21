import 'package:flutter_bloc/flutter_bloc.dart';

import 'member_selection_event.dart';
import 'member_selection_state.dart';

class MemberSelectionBloc
    extends Bloc<MemberSelectionEvent, MemberSelectionState> {
  MemberSelectionBloc() : super(const MemberSelectionState()) {
    on<MemberSelectionEvent>((event, emit) {
      event.whenOrNull(
        check: (schoolNb) => _onCheck(schoolNb, emit),
        send: () => _onSend(emit),
      );
    });
  }

  void _onCheck(int schoolNb, Emitter<MemberSelectionState> emit) {
    final selected = Set<int>.from(state.checkList);
    if (!selected.remove(schoolNb)) selected.add(schoolNb);
    emit(state.copyWith(checkList: selected));
  }

  Future<void> _onSend(Emitter<MemberSelectionState> emit) async {}
}
