import 'package:freezed_annotation/freezed_annotation.dart';

import 'study_applicant.dart';

part 'study_data.freezed.dart';
part 'study_data.g.dart';

/// `GET /dormitory/studies` 응답의 `data` 객체.
///
/// 신청 가능 여부·내 신청 상태·신청자 목록을 함께 내려준다.
/// (응답 래퍼는 [StudyListResponse], 신청자 1명은 [StudyApplicant].)
@freezed
abstract class StudyData with _$StudyData {
  const factory StudyData({
    /// 서버가 판정한 자습 신청 가능 시간대 여부.
    @Default(false) bool isApplicationOpen,

    /// 내 신청 상태 — 미신청이면 null. (서버 표기 문자열)
    String? myApplicationStatus,

    /// 자습 신청자 목록.
    @Default(<StudyApplicant>[]) List<StudyApplicant> applicants,
  }) = _StudyData;

  factory StudyData.fromJson(Map<String, dynamic> json) =>
      _$StudyDataFromJson(json);
}
