import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_event.freezed.dart';

@freezed
abstract class HomeEvent with _$HomeEvent {
  /// [grade]학년 [classNumber]반 기준으로 오늘 시간표에서 다음 교시를 조회한다.
  const factory HomeEvent.scheduleRequested({
    required int grade,
    required int classNumber,
  }) = _ScheduleRequested;
}
