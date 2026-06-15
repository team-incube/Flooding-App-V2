import 'package:flutter_bloc/flutter_bloc.dart';

import 'member_selection_state.dart';

/// 자습 인원 목록에서 (기숙사 자치회 권한으로) 선택한 인원을 관리하는 cubit.
class MemberSelectionCubit extends Cubit<MemberSelectionState> {
  MemberSelectionCubit() : super(const MemberSelectionState());

  void toggle(int schoolNb) {
    final selected = Set<int>.from(state.selected);
    if (!selected.remove(schoolNb)) selected.add(schoolNb);
    emit(state.copyWith(selected: selected));
  }

  void clear() => emit(const MemberSelectionState());
}
