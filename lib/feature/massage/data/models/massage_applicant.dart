import 'package:freezed_annotation/freezed_annotation.dart';

part 'massage_applicant.freezed.dart';
part 'massage_applicant.g.dart';

/// 안마의자를 신청한 학생 1명의 정보.
///
/// `GET /dormitory/massages` 응답의 `data.applicants` 항목.
/// 실제 응답 필드: order, name, studentNumber, profileImageUrl.
/// userId/grade/classNumber/sex 는 내려오지 않는다.
@freezed
abstract class MassageApplicant with _$MassageApplicant {
  const factory MassageApplicant({
    required String name,
    required int studentNumber,

    /// 대기 순번 — 서버 키: `order`.
    @JsonKey(name: 'order') int? waitOrder,

    String? profileImageUrl,
  }) = _MassageApplicant;

  factory MassageApplicant.fromJson(Map<String, dynamic> json) =>
      _$MassageApplicantFromJson(json);
}
