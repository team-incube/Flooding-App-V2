import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/me.dart';

part 'me_state.freezed.dart';

@freezed
class MeState with _$MeState {
  const factory MeState.initial() = _Initial;

  const factory MeState.loading() = _Loading;

  const factory MeState.loaded({required Me me}) = _Loaded;

  const factory MeState.error({required String message}) = _Error;
}
