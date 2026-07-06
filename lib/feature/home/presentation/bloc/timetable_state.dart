import 'package:flooding_v2/feature/home/data/models/period_data.dart';
import 'package:flooding_v2/feature/home/domain/usecases/get_next_period_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_state.freezed.dart';

enum ScheduleStatus { initial, loading, loaded, error }

@freezed
abstract class TimetableState with _$TimetableState {
  const factory TimetableState({
    @Default(ScheduleStatus.initial) ScheduleStatus scheduleStatus,

    /// 현재 진행 중이거나 다음으로 시작하는 교시. [scheduleStatus] 가 `loaded` 이고
    /// [periodStatus] 가 `found` 일 때만 값이 있다.
    PeriodData? period,

    /// [period] 가 없는 이유(하교 이후/공강 등)까지 구분한다.
    /// [scheduleStatus] 가 `loaded` 일 때만 의미가 있다.
    NextPeriodStatus? periodStatus,

    /// 시간표 조회 실패 메시지.
    String? scheduleError,
  }) = _TimetableState;
}
