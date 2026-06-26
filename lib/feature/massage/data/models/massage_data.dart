import 'package:freezed_annotation/freezed_annotation.dart';

import 'massage_applicant.dart';

part 'massage_data.freezed.dart';
part 'massage_data.g.dart';

/// `GET /dormitory/massages` 응답의 `data` 객체.
///
/// 신청 가능 여부·내 신청 상태·신청자 목록을 함께 내려준다.
/// (응답 래퍼는 [MassageListResponse], 신청자 1명은 [MassageApplicant].)
@freezed
abstract class MassageData with _$MassageData {
  const factory MassageData({
    /// 서버가 판정한 안마의자 신청 가능 시간대 여부.
    @Default(false) bool isApplicationOpen,

    /// 내 신청 상태 — 미신청이면 null. (서버 표기 문자열)
    String? myApplicationStatus,

    /// 안마의자 신청자 목록.
    @Default(<MassageApplicant>[]) List<MassageApplicant> applicants,
  }) = _MassageData;

  factory MassageData.fromJson(Map<String, dynamic> json) =>
      _$MassageDataFromJson(json);
}
