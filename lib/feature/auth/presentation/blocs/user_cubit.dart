import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enum/role.dart';
import '../../data/models/datagsm_user.dart';
import '../../data/models/student_role.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  void setUser(DatagsmUser user) {
    final student = user.student;
    final role = switch (student?.role) {
      StudentRole.dormitoryManager => Role.dormitoryManager,
      _ => Role.genderalStudent,
    };
    emit(
      UserState(
        name: student?.name ?? '익명',
        studentId: student?.studentNumber ?? 0000,
        role: role,
      ),
    );
  }

  void clear() => emit(const UserState());
}

extension AccessRole on BuildContext {
  Role get role => watch<UserCubit>().state.role ?? Role.genderalStudent;
}
