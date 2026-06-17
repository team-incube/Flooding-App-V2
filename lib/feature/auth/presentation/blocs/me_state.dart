import 'package:flooding_v2/core/enum/role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_state.freezed.dart';

@freezed
abstract class MeState with _$MeState {
  const MeState._();

  const factory MeState.initial() = _Initial;

  const factory MeState.loading() = _Loading;

  const factory MeState.loaded({
    required String name,
    required int studentNumber,
    required Role role,
  }) = _Loaded;

  const factory MeState.failure() = _Failure;
}
