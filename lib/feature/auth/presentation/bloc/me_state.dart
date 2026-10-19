import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/me.dart';

part 'me_state.freezed.dart';

@freezed
sealed class MeState with _$MeState {
  const factory MeState.initial() = MeInitial;

  const factory MeState.loading() = MeLoading;

  const factory MeState.loaded({required Me me}) = MeLoaded;

  const factory MeState.error({required String message}) = MeError;
}
