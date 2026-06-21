import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_selection_event.freezed.dart';

@freezed
class MemberSelectionEvent with _$MemberSelectionEvent {
  const factory MemberSelectionEvent.check({required int schoolNb}) = _Check;

  const factory MemberSelectionEvent.send() = _Send;
}
