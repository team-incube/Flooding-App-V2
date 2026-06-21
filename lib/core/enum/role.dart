import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/auth/presentation/bloc/me_bloc.dart';
import '../../feature/auth/presentation/bloc/me_state.dart';

enum Role {
  admin('ADMIN'),
  dormitoryManager('DORMITORY_MANAGER'),
  generalStudent('GENERAL_STUDENT');

  final String value;

  const Role(this.value);
}

extension AccessRole on BuildContext {
  Role get role => watch<MeBloc>().state.maybeWhen(
    loaded: (me) =>
        Role.values.where((r) => r.value == me.role).firstOrNull ??
        Role.generalStudent,
    orElse: () => Role.generalStudent,
  );
}
