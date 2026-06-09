import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_event.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_state.dart';

class MemberListBloc extends Bloc<MemberListEvent, MemberListState> {
  MemberListBloc() : super(const MemberListState.initial()) {
    on<MemberListEvent>((event, emit) {
      event.when<FutureOr<void>>(
        load: () => loadMemberList(emit),
        filter: () => filterMemberList(emit),
      );
    });
  }

  Future<void> loadMemberList(Emitter emit) async {}

  Future<void> filterMemberList(Emitter emit) async {}
}
