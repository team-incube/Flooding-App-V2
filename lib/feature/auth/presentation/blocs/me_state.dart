import 'package:flooding_v2/core/enum/role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({String? name, int? studentId, Role? role}) =
      _UserState;
}
