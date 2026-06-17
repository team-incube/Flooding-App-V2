import 'package:flooding_v2/feature/auth/data/models/me.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_event.freezed.dart';

@freezed
class MeEvent with _$MeEvent {
  const factory MeEvent.load() = _Load;

  const factory MeEvent.clear() = _Clear;
}
