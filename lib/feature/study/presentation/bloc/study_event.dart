import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enum/gender.dart';

part 'study_event.freezed.dart';

@freezed
class StudyEvent with _$StudyEvent {
  /// 자습 신청자 목록을 (재)조회한다.
  ///
  /// [refresh] 가 true 면 재조회로 간주해 로딩 인디케이터를 띄우지 않고
  /// 기존 목록을 유지한 채 값만 갱신한다(최초 조회만 인디케이터 노출).
  const factory StudyEvent.applicantsRequested({@Default(false) bool refresh}) =
      _ApplicantsRequested;

  /// 조회된 목록을 학년/반/성별로 필터링한다.
  const factory StudyEvent.filtered({
    int? grade,
    int? classNb,
    Gender? gender,
  }) = _Filtered;

  /// 현재 시각 기준으로 신청 버튼 활성 상태를 재평가한다.
  const factory StudyEvent.actionEvaluated() = _ActionEvaluated;

  /// 현재 상태에 따라 신청 또는 취소를 수행한다.
  const factory StudyEvent.actionSubmitted() = _ActionSubmitted;
}
