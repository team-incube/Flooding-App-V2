import 'package:flooding_v2/feature/auth/data/models/me.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enum/role.dart';
import '../../data/models/student_role.dart';
import 'user_state.dart';

class MeCubit extends Cubit<UserState> {
  MeCubit() : super(const UserState());

  void setUser(Me user) {
    final studentRole = StudentRole.values.where((e) => e.name == _toCamel(user.role)).firstOrNull;
    emit(
      UserState(
        name: user.name,
        studentId: user.studentNumber,
        role: studentRole?.toRole,
      ),
    );
  }

  String _toCamel(String snakeCase) => snakeCase
      .toLowerCase()
      .replaceAllMapped(RegExp(r'_([a-z])'), (m) => m[1]!.toUpperCase());

  void clear() => emit(const UserState());
}

extension AccessRole on BuildContext {
  Role get role => watch<MeCubit>().state.role ?? Role.generalStudent;
}
