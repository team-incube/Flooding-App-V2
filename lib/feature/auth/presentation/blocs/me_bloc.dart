import 'package:flooding_v2/feature/auth/data/user_service.dart';
import 'package:flooding_v2/feature/auth/presentation/blocs/me_event.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enum/role.dart';
import 'me_state.dart';

class MeBloc extends Bloc<MeEvent, MeState> {
  MeBloc(this._userService) : super(const MeState.initial()) {
    on<MeEvent>((event, emit) async {
      await event.whenOrNull(load: () => _onLoad(emit), clear: () => _onClear(emit));
    });
  }

  final UserService _userService;

  Future<void> _onLoad(Emitter<MeState> emit) async {
    emit(const MeState.loading());
    try {
      final me = await _userService.fetchMe();
      if (me == null) {
        emit(const MeState.failure());
        return;
      }
      emit(
        MeState.loaded(
          name: me.name,
          studentNumber: me.studentNumber,
          role:
              Role.values.where((r) => r.value == me.role).firstOrNull ??
              Role.generalStudent,
        ),
      );
    } catch (_) {
      emit(const MeState.failure());
    }
  }

  void _onClear(Emitter<MeState> emit) => emit(const MeState.initial());
}

extension AccessRole on BuildContext {
  Role get role => watch<MeBloc>().state.maybeWhen(
    loaded: (_, __, role) => role,
    orElse: () => Role.generalStudent,
  );
}
