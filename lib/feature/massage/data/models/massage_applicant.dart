import 'package:freezed_annotation/freezed_annotation.dart';

part 'massage_applicant.freezed.dart';
part 'massage_applicant.g.dart';

/// 안마의자를 신청한 학생 1명의 정보.
///
/// `GET /dormitory/massages` 응답의 `data` 항목.
///
/// 주의: 현재 Swagger 문서에 응답 `data` 스키마가 정의돼 있지 않아,
/// 자습([StudyApplicant])과 동일하게 공통 사용자 응답 기준으로 모델링했다.
/// 서버가 보장하는 필드(id/name/studentNumber)만 required 로 두고,
/// 학년·반·번호·대기 순번 등 부가 필드는 nullable 로 둔다. 실제 응답 확인 후 보정한다.
@freezed
abstract class MassageApplicant with _$MassageApplicant {
  const factory MassageApplicant({
    required int id,
    required String name,
    required int studentNumber,
    int? grade,
    int? classNumber,
    int? number,

    /// 대기 순번 — 서버가 신청 순서대로 부여한다(있으면).
    int? waitOrder,

    /// 성별 — 백엔드 표기: `MAN` / `WOMAN`.
    String? sex,
    String? profileImageUrl,
  }) = _MassageApplicant;

  factory MassageApplicant.fromJson(Map<String, dynamic> json) =>
      _$MassageApplicantFromJson(json);
}
