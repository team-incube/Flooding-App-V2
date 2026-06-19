import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/user_service.dart';
import 'me_event.dart';
import 'me_state.dart';

/// 로그인한 사용자(`GET /users/me`) 정보를 보관하는 Bloc.
///
/// 메뉴 드로어의 이름·학번 표시에 사용한다. 인증되면 [MeEvent.requested] 로
/// 불러오고, 로그아웃·세션 만료 시 [MeEvent.cleared] 로 비운다.
class MeBloc extends Bloc<MeEvent, MeState> {
  MeBloc({UserService? userService})
    : _userService = userService ?? UserService(),
      super(const MeState.initial()) {
    on<MeEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        requested: () => _onRequested(emit),
        cleared: () async => emit(const MeState.initial()),
      );
    });
  }

  final UserService _userService;

  Future<void> _onRequested(Emitter<MeState> emit) async {
    emit(const MeState.loading());
    try {
      final me = await _userService.fetchMe();
      if (me == null) {
        emit(const MeState.error(message: '내 정보를 불러오지 못했어요.'));
        return;
      }
      emit(MeState.loaded(me: me));
    } on Exception catch (_) {
      emit(const MeState.error(message: '내 정보를 불러오지 못했어요.'));
    }
  }
}
