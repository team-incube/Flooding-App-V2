import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enum/role.dart';
import '../../data/models/datagsm_user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  void setUser(DatagsmUser user) {
    final student = user.student;
    emit(
      UserState(
        name: student?.name ?? '익명',
        studentId: student?.studentNumber ?? 0000,
        role: student?.role?.toRole,
      ),
    );
  }

  void clear() => emit(const UserState());
}

extension AccessRole on BuildContext {
  Role get role => watch<UserCubit>().state.role ?? Role.generalStudent;
}
